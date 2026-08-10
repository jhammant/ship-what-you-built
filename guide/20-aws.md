# Track B — AWS

**You'll end with:** your project live on your own domain, over HTTPS, served by
CloudFront, deploying itself from GitHub with **no AWS key stored anywhere**.

**Time:** ~90 minutes, much of it waiting for DNS and CloudFront.
**Cost:** the domain, plus ~$0.50/month for the DNS zone. Everything else rounds
to zero at personal-project scale. Route 53 charges a little more for the domain
itself than a budget registrar — about $16/yr for a `.com` against roughly $11
elsewhere — in exchange for registration and DNS being wired together for you.

> **Everything below was run start-to-finish while writing this**, on a
> newly-registered domain, and the guide was corrected wherever reality
> disagreed with it. The site you're reading this on is hosted exactly this way.

**Before you start:** [the three layers](04-three-layers.md) and
[your code on GitHub](05-github.md).

> **This track has a real failure mode that Track A doesn't: money.** A leaked
> AWS key gets used for crypto mining, and the bills reach five figures within
> hours. Part 1 is not optional throat-clearing — it's the seatbelt. Do it
> first, in order.

---

## Part 1 — Not getting a surprise bill

### 1.1 Create the account

[aws.amazon.com](https://aws.amazon.com). You need a card even though you'll
spend almost nothing.

The email and password you just used are the **root account**. It can do
anything, including close the account and run up unlimited charges. Treat it
like the deed to your house.

### 1.2 MFA on root — now, not later

Console → your account name (top right) → **Security credentials** →
**Multi-factor authentication** → assign an authenticator app.

Two minutes, and it removes the entire category of disaster above.

### 1.3 A budget alarm — also now

Console → **Billing and Cost Management** → **Budgets** → **Create budget** →
**Zero spend budget**, or a monthly cost budget of $5. Give it your email.

This is your smoke detector. Everything in this guide should keep you under
$1/month, so a $5 alarm means *something is wrong*, not *you're being frugal*.

Do this in the console — the CLI version wants JSON files and you have no
credentials yet anyway.

### 1.4 Never create an access key for root

If you're offered one, decline. Part 2 makes a separate identity. This is the
most common beginner mistake on AWS and it's the one that costs money.

---

## Part 2 — Credentials

An access key is two strings: an **access key ID** (`AKIA…`, semi-public) and a
**secret access key** (shown exactly once). Together they let the AWS CLI — and
therefore Claude Code — act as you.

### 2.1 An IAM user

Console → **IAM** → **Users** → **Create user**.

1. Name it something like `myname-cli`.
2. **Don't** tick "Provide user access to the AWS Management Console" — this
   identity is for the CLI only.
3. Permissions → **Attach policies directly** → **AdministratorAccess**.
4. Create.

> **On AdministratorAccess:** more power than this project needs, and in a work
> account you'd scope it down. For a personal account where you're the only user
> and you're about to touch six services, the alternative is fighting permission
> errors all afternoon. Accept it, and let the budget alarm and MFA be the real
> guardrails.

### 2.2 The key

Click into the user → **Security credentials** → **Create access key** →
**Command Line Interface (CLI)** → acknowledge → **Create**.

The secret is shown **once**. Lose it and you delete the key and make another —
there's no recovery.

### 2.3 Store it properly

```bash
# macOS
brew install awscli jq

aws configure
```

```text
AWS Access Key ID     : AKIA................
AWS Secret Access Key : ....................
Default region name   : eu-west-2      # London. us-east-1 if you're in the US
Default output format : json
```

That writes `~/.aws/credentials`, which is the correct home for it.

**The rules:**

- **Never** put the key in your project folder or a `.env` file you might commit.
- **Never** paste it into a chat with Claude. Claude reads it from `~/.aws/` via
  the CLI — it never needs to see the string. If something asks you to paste a
  secret, something is set up wrong.
- Suspect a leak? IAM → user → Security credentials → deactivate, delete, create
  a new one. Thirty seconds. Do it **on suspicion, not proof**.

### 2.4 Check it, and save your account ID

```bash
aws sts get-caller-identity
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo $ACCOUNT_ID
```

`InvalidClientTokenId` means the key was mistyped — rerun `aws configure`.

> **Longer term:** access keys are long-lived secrets, and AWS's own advice is
> IAM Identity Center (`aws sso login`, nothing durable on disk). Better, and
> more moving parts than a first project needs. Start here, upgrade later.

### 2.5 Keep your variables somewhere that survives

The rest of this track builds up a set of shell variables — `$DOMAIN`,
`$ZONE_ID`, `$CERT_ARN`, `$BUCKET`, `$DIST_ID` — and each step uses the ones
before it.

**`export` only lasts as long as that one terminal window.** Close it, reboot,
or open a second tab, and they're all gone. Half of them are then genuinely
annoying to look up again. This catches people out constantly, because it
happens between sessions and the error you get is a command silently running
against an empty string.

So put them in a file from the start:

```bash
mkdir -p ~/.config/myproject
touch ~/.config/myproject/env
chmod 600 ~/.config/myproject/env
```

Save each value **as you create it**, with this helper:

```bash
remember() {
  local file="$HOME/.config/myproject/env"
  grep -v "^export $1=" "$file" > "$file.tmp" 2>/dev/null || true
  echo "export $1='$2'" >> "$file.tmp"
  mv "$file.tmp" "$file"
  export "$1=$2"
}
```

```bash
remember DOMAIN yourthing.com
remember ACCOUNT_ID "$(aws sts get-caller-identity --query Account --output text)"
```

**The command blocks below all say `export`,** because that's the idiom you'll
see everywhere else and it's what you should recognise. Wherever one appears,
`remember FOO bar` does the same thing to your current shell *and* survives
closing it. Use whichever you like — just be consistent.

And at the start of any new terminal:

```bash
source ~/.config/myproject/env
```

**This file holds identifiers, not credentials** — bucket names, ARNs, zone IDs.
Your actual key stays in `~/.aws/credentials` where the CLI put it. Don't put
secrets in here, and don't put this file in your project folder where it could
get committed.

If you'd rather not bother, that's fine — just know that when a command three
sections from now fails with something like `Invalid length for parameter`, the
first thing to check is `echo $ZONE_ID` and whether it's empty.

---

## Part 3 — The domain

### 3.1 Buy it

Console → **Route 53** → **Registered domains** → **Register domains**.

Registering inside Route 53 means AWS handles both registration and DNS and
wires them together automatically. A pound or two more per year than a budget
registrar; for a first project, take the simplicity.

Leave **privacy protection enabled** (free, keeps your home address out of
public WHOIS). Registration takes minutes to a few hours.

**Click the verification email.** ICANN requires it, and an unverified domain
gets suspended after 15 days. This genuinely catches people out.

> **Free premium-price detector.** Some names are flagged *premium* by the
> registry and cost 10–100× normal. Route 53 refuses to register premium domains
> at all — so if Route 53 offers you the name at ~$12–16/yr, it isn't premium,
> buy it. If Route 53 says it can't while other registrars show it available,
> that's your signal. Check the real number elsewhere before falling in love.

### 3.2 Find your hosted zone

Registering creates a **hosted zone** automatically — the container for this
domain's DNS records, and the thing that costs $0.50/month.

```bash
export DOMAIN=yourthing.com                          # <-- change this
export ZONE_ID=$(aws route53 list-hosted-zones \
  --query "HostedZones[?Name=='${DOMAIN}.'].Id" --output text | cut -d/ -f3)
echo $ZONE_ID
```

> **If you bought a `.dev` domain:** the whole `.dev` TLD is on the browser HSTS
> preload list, so browsers *refuse* plain HTTP — there's no "click through the
> warning" escape hatch. A half-finished setup looks completely broken rather
> than partly working. This guide sets up a real certificate anyway.

---

## Part 4 — Hosting your files (Shape 1)

Static files live in an **S3 bucket**; **CloudFront** puts them on your domain
with HTTPS. The bucket stays completely private — only CloudFront can read it.

> ### About the `cat > file <<EOF` blocks below
>
> Several steps write a configuration file using a shape that looks like this:
>
> ```text
> cat > example.json <<EOF
> { "some": "config" }
> EOF
> ```
>
> That is **one command**, not three. Copy and paste the *whole block at once*,
> including the closing `EOF` and the newline after it. If you paste it line by
> line you'll end up staring at a bare `>` prompt with no output and no error —
> the shell is waiting for the `EOF` that ends the file. Press `Ctrl-C` and
> paste the whole thing again.
>
> These blocks also write scratch files into whatever folder you're in. Keep
> them out of your repo and off your website:
>
> ```bash
> mkdir -p .aws-setup && cd .aws-setup
> printf '.aws-setup/\n' >> ../.gitignore
> ```
>
> Run the rest of this track from there. One of those files contains your AWS
> account ID, which Part 6 rightly tells you to keep out of a public repo.

### 4.1 The bucket

```bash
# Globally unique, and NO DOTS — see the warning below.
export BUCKET=$(printf '%s' "$DOMAIN" | tr '.' '-')-site   # yourthing-com-site
export REGION=$(aws configure get region)

aws s3api create-bucket --bucket $BUCKET --region $REGION \
  --create-bucket-configuration LocationConstraint=$REGION

# Keep it private. CloudFront will be given its own way in.
aws s3api put-public-access-block --bucket $BUCKET \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

> **Don't put dots in the bucket name.** It's tempting to name it after the
> domain — `yourthing.com-site` — and it will create fine. But CloudFront reaches
> the bucket at `<bucket>.s3.<region>.amazonaws.com` over HTTPS, and AWS's
> certificate for that endpoint is `*.s3.<region>.amazonaws.com`. A wildcard
> covers exactly **one** label, so any dot in the bucket name adds a label the
> certificate doesn't cover and the origin connection fails TLS validation. The
> error surfaces much later as a confusing 502 from CloudFront. Hyphens
> throughout, always.

> `us-east-1` is a special case: **omit** the `--create-bucket-configuration`
> flag entirely there, or the call fails with `InvalidLocationConstraint`.

Upload your site:

```bash
# From the folder holding your built files (dist/, build/, or the HTML itself).
# Check you're in the right place before running anything:
pwd && ls index.html

aws s3 sync . s3://$BUCKET/ --delete \
  --exclude ".*" --exclude ".*/*" --exclude "node_modules/*"
```

> **Why the `--exclude` flags matter more than they look.** If you have no build
> step, the folder holding your HTML *is* your project folder — the one with
> `.git/` and possibly `.env` in it. **`aws s3 sync` does not read
> `.gitignore`.** Without those excludes you would publish your entire commit
> history and your API keys to a bucket that CloudFront then serves to the
> world, having spent all of [page 02](05-github.md) learning not to.

`--delete` removes files from the bucket that no longer exist locally. Powerful
and unforgiving — **always check you're in the right folder first**, which is
what the `pwd && ls` line is for.

### 4.2 The certificate — `us-east-1`, always

**This must be in `us-east-1`.** Not your region. CloudFront is global and only
reads certificates from that one region. This is the single most common failure
in the whole setup, and the error you get is unhelpfully vague.

```bash
export CERT_ARN=$(aws acm request-certificate \
  --domain-name $DOMAIN \
  --subject-alternative-names "www.$DOMAIN" \
  --validation-method DNS \
  --region us-east-1 \
  --query CertificateArn --output text)
echo $CERT_ARN
```

Prove you own the domain by publishing the records ACM asks for.

**You asked for two names, so ACM wants two records** — one for the apex and one
for `www`. Publishing only the first is the commonest way to get a certificate
that sits on "pending" forever, so build the change batch from *all* of them:

```bash
aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1 \
  --query "Certificate.DomainValidationOptions[].ResourceRecord" \
  --output json > validation.json

jq '{Changes: [.[] | {
      Action: "UPSERT",
      ResourceRecordSet: {
        Name: .Name, Type: .Type, TTL: 300,
        ResourceRecords: [{ Value: .Value }]
      }
    }] | unique_by(.ResourceRecordSet.Name)}' validation.json > change-batch.json

aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID --change-batch file://change-batch.json
```

`unique_by` matters: when the names overlap ACM sometimes asks for the same
record twice, and Route 53 rejects a batch containing duplicates.

Now wait:

```bash
aws acm wait certificate-validated --certificate-arn $CERT_ARN --region us-east-1
aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1 \
  --query 'Certificate.Status' --output text
```

That's [layer 4 waiting on layer 2](04-three-layers.md#layer-4--the-certificate),
made visible. Usually 2–5 minutes. **Always check the status afterwards** — the
waiter gives up after a fixed number of attempts and, depending on your CLI
version, may not fail loudly when it does.

> **If you registered the domain minutes ago, expect this to time out the first
> time, and don't go hunting for a mistake.** A brand-new registration isn't
> *delegated* straight away: the `.com` registry has to publish your nameservers
> before anyone — including ACM — can look anything up in your zone. Until then
> your validation records are correct and invisible.
>
> Check with `dig NS $DOMAIN +short`. Empty means not delegated yet; wait and
> re-run the waiter. It's typically 10–60 minutes after registration completes.
> This is a layer 1 problem wearing a layer 4 costume, and it catches everyone
> who buys a domain and builds immediately.

If the domain *is* delegated and validation still hangs past 15 minutes, the
record really is wrong — check it resolves:

```bash
dig +short _something.$DOMAIN CNAME
```

### 4.3 CloudFront, with a private bucket

First an **Origin Access Control** — the thing that lets CloudFront read a
bucket that's closed to everyone else:

```bash
export OAC_ID=$(aws cloudfront create-origin-access-control \
  --origin-access-control-config \
  "Name=$BUCKET-oac,Description=OAC for $BUCKET,SigningProtocol=sigv4,SigningBehavior=always,OriginAccessControlOriginType=s3" \
  --query 'OriginAccessControl.Id' --output text)
echo $OAC_ID
```

Then the distribution:

```bash
cat > cf-config.json <<EOF
{
  "CallerReference": "$BUCKET-$(date +%s)",
  "Comment": "$DOMAIN",
  "Enabled": true,
  "DefaultRootObject": "index.html",
  "Aliases": { "Quantity": 2, "Items": ["${DOMAIN}", "www.${DOMAIN}"] },
  "Origins": {
    "Quantity": 1,
    "Items": [{
      "Id": "s3-origin",
      "DomainName": "${BUCKET}.s3.${REGION}.amazonaws.com",
      "OriginAccessControlId": "${OAC_ID}",
      "S3OriginConfig": { "OriginAccessIdentity": "" }
    }]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "s3-origin",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2, "Items": ["GET","HEAD"],
      "CachedMethods": { "Quantity": 2, "Items": ["GET","HEAD"] }
    },
    "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6",
    "Compress": true
  },
  "ViewerCertificate": {
    "ACMCertificateArn": "${CERT_ARN}",
    "SSLSupportMethod": "sni-only",
    "MinimumProtocolVersion": "TLSv1.2_2021"
  }
}
EOF

aws cloudfront create-distribution --distribution-config file://cf-config.json > cf-out.json

export DIST_ID=$(jq -r '.Distribution.Id' cf-out.json)
export DIST_DOMAIN=$(jq -r '.Distribution.DomainName' cf-out.json)
export DIST_ARN=$(jq -r '.Distribution.ARN' cf-out.json)
echo "$DIST_ID -> $DIST_DOMAIN"
```

`658327ea-…` is the AWS-managed **CachingOptimized** policy — a fixed ID,
identical in every account.

Now let CloudFront — and only this distribution — read the bucket:

```bash
cat > bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "AllowCloudFrontServicePrincipal",
    "Effect": "Allow",
    "Principal": { "Service": "cloudfront.amazonaws.com" },
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${BUCKET}/*",
    "Condition": { "StringEquals": { "AWS:SourceArn": "${DIST_ARN}" } }
  }]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKET --policy file://bucket-policy.json
```

That `Condition` is what keeps the bucket private: it grants access to the
CloudFront *service*, but only when the request comes from **your** distribution.

Wait for it to roll out — 5–15 minutes:

```bash
aws cloudfront wait distribution-deployed --id $DIST_ID
```

> **Got more than one page?** `DefaultRootObject` above only applies to `/`.
> It does **not** make `/guide/` serve `/guide/index.html` — an S3 origin behind
> an Origin Access Control does no directory-index lookup of its own, so every
> folder-style URL returns **403**, which reads like a permissions problem and
> isn't one. (This site hit exactly that.)
>
> Fix it with a CloudFront Function, which runs on every request for a fraction
> of a penny per million:
>
> ```javascript
> function handler(event) {
>   var request = event.request;
>   var uri = request.uri;
>   if (uri.endsWith('/')) {
>     request.uri = uri + 'index.html';
>   } else if (!uri.includes('.')) {
>     request.uri = uri + '/index.html';
>   }
>   return request;
> }
> ```
>
> ```bash
> aws cloudfront create-function --name dir-index \
>   --function-config '{"Comment":"Resolve directory URLs","Runtime":"cloudfront-js-2.0"}' \
>   --function-code fileb://dirindex.js
> aws cloudfront publish-function --name dir-index --if-match <ETag-from-above>
> ```
>
> Then attach it to your distribution's default behaviour as a
> **viewer-request** function — easiest in the console under **Behaviors** →
> **Edit** → **Function associations**. Skip this entirely if your site is a
> single `index.html`.

> **Building a single-page app** (React Router, Vue Router)? Deep links will 404,
> because there's no `about.html` in the bucket. Fix: CloudFront → your
> distribution → **Error pages** → create two custom responses, `403` and `404`,
> both returning `/index.html` with HTTP **200**. Then the router handles the
> path client-side.

### 4.4 Point the domain at it

```bash
for NAME in "$DOMAIN" "www.$DOMAIN"; do
cat > dns-$NAME.json <<EOF
{
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "${NAME}",
      "Type": "A",
      "AliasTarget": {
        "HostedZoneId": "Z2FDTNDATAQYW2",
        "DNSName": "${DIST_DOMAIN}",
        "EvaluateTargetHealth": false
      }
    }
  }]
}
EOF
aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID --change-batch file://dns-$NAME.json
done
```

`Z2FDTNDATAQYW2` is not a typo and not specific to you — it's a fixed constant
meaning "CloudFront" to Route 53. Every CloudFront alias record on earth uses it.

An **alias record** is a Route 53 speciality: behaves like a CNAME, works at the
apex — [the problem from layer 2](04-three-layers.md#the-apex-problem--the-one-gotcha-worth-knowing-in-advance),
solved.

```bash
dig +short $DOMAIN
curl -sI https://$DOMAIN | head -1
```

`HTTP/2 200` and you're live. **Skip to Part 6** unless you need a backend.

---

## Part 5 — Adding a backend (Shape 2)

A **Lambda** runs your code per request, then stops. You pay per request, and a
million a month are free.

### 5.1 The function

`index.mjs`:

```javascript
export const handler = async (event) => {
  const body = event.body ? JSON.parse(event.body) : {};

  return {
    statusCode: 200,
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ ok: true, youSent: body }),
  };
};
```

`.mjs` tells Node it's an ES module, so `export` works without a `package.json`.

### 5.2 A role for it

Every Lambda runs *as* an IAM role — even a hello-world, because it needs
permission to write its own logs.

```bash
cat > trust-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "lambda.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
EOF

aws iam create-role --role-name api-lambda-role \
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy --role-name api-lambda-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# IAM is eventually consistent across services: a role that exists here may not
# be visible to Lambda for a few seconds. Without this pause, the next command
# fails with "The role defined for the function cannot be assumed by Lambda",
# which blames the role when the real problem is timing.
sleep 10
```

### 5.3 Deploy it and give it a URL

`zip` is preinstalled on macOS; on Ubuntu/WSL it's `sudo apt install zip`.

```bash
zip function.zip index.mjs

aws lambda create-function \
  --function-name api \
  --runtime nodejs24.x \
  --role arn:aws:iam::${ACCOUNT_ID}:role/api-lambda-role \
  --handler index.handler \
  --zip-file fileb://function.zip

aws lambda create-function-url-config --function-name api --auth-type NONE
aws lambda add-permission --function-name api \
  --statement-id FunctionURLAllowPublicAccess \
  --action lambda:InvokeFunctionUrl --principal "*" \
  --function-url-auth-type NONE

export FN_URL=$(aws lambda get-function-url-config \
  --function-name api --query FunctionUrl --output text)
curl -X POST $FN_URL -d '{"hello":"world"}'
```

**Both** permission commands are needed — creating the URL alone gets you a 403.

> **Runtimes go stale.** `nodejs24.x` is current. If the CLI rejects it, your AWS
> CLI is out of date (`brew upgrade awscli`) — or use `nodejs22.x`, identical for
> this. Check the [supported runtimes
> list](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) before
> debugging anything else.

Update it later with:

```bash
zip function.zip index.mjs
aws lambda update-function-code --function-name api --zip-file fileb://function.zip
```

### 5.4 Secrets for the function

Environment variables, set on the function, never in the code:

```bash
aws lambda update-function-configuration --function-name api \
  --environment "Variables={ANTHROPIC_API_KEY=sk-ant-...}"
```

Read it in the handler as `process.env.ANTHROPIC_API_KEY`.

> For anything you'd mind leaking, graduate to **AWS Secrets Manager** (~$0.40
> per secret per month) — Lambda env vars are visible to anyone with console
> read access to the function. For a personal project's own key, env vars are a
> reasonable place to start.

### 5.5 Putting it on `/api/*` of your domain

Add a second origin and cache behaviour to the distribution you already have, so
`yourthing.com/api/…` hits the Lambda and everything else hits S3. It's fiddly
in raw CLI and much easier in the console — CloudFront → your distribution →
**Origins** → add the Lambda URL's hostname; then **Behaviors** → add
`/api/*` → that origin → cache policy **CachingDisabled**
(`4135ea2d-6df8-44a3-9df3-4b5a84be39ad`) → allow all HTTP methods.

Or hand it over:

> Add my Lambda function URL as a second origin on CloudFront distribution
> $DIST_ID, with a cache behaviour routing `/api/*` to it, caching disabled, all
> HTTP methods allowed. Show me the config before you apply it.

---

## Part 6 — Deploys without storing a key

Right now deploying means running `aws s3 sync` by hand. Better: push to GitHub,
GitHub deploys.

The naive version puts an AWS access key in GitHub secrets. Don't. **OIDC** lets
GitHub prove each workflow run's identity to AWS directly, and AWS hands back
credentials that expire in minutes. **No AWS key exists in GitHub at all.**

### 6.1 Trust GitHub as an identity provider

Once per AWS account:

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com
```

`EntityAlreadyExists` means it's already there — fine, carry on.

### 6.2 A role only your repo can assume

```bash
export GH_REPO="yourname/your-repo"      # <-- change this

cat > gh-trust.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
      },
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:${GH_REPO}:*"
      }
    }
  }]
}
EOF

aws iam create-role --role-name github-deploy \
  --assume-role-policy-document file://gh-trust.json
```

That `sub` condition is the security boundary: **only workflows in that one
repository** can assume this role. Get it wrong and any repo on GitHub can.

> ### If this fails with "Not authorized", read this before changing anything
>
> Some accounts — increasingly, all of them — issue **ID-qualified subjects**,
> where GitHub appends the numeric owner and repo IDs to the claim:
>
> ```text
> what most guides tell you to expect
>   repo:you/your-repo:ref:refs/heads/main
>
> what you may actually get
>   repo:you@8456990/your-repo@1329892525:ref:refs/heads/main
> ```
>
> The pattern above then matches nothing, and the only error you get is
> `Not authorized to perform sts:AssumeRoleWithWebIdentity` — which names no
> cause and sends people off rewriting a trust policy that was nearly right.
>
> **Don't guess. Print the claim.** Add this workflow, run it once, and read
> the real `sub`:
>
> ```yaml
> name: OIDC debug
> on: workflow_dispatch
> permissions: { id-token: write, contents: read }
> jobs:
>   claims:
>     runs-on: ubuntu-latest
>     steps:
>       - run: |
>           TOKEN=$(curl -sS -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
>             "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=sts.amazonaws.com" | jq -r '.value')
>           P=$(echo "$TOKEN" | cut -d. -f2)
>           P="${P}$(printf '=%.0s' $(seq 1 $(( (4 - ${#P} % 4) % 4 ))))"
>           echo "$P" | tr '_-' '/+' | base64 -d | jq '{sub, aud, repository}'
> ```
>
> The `sub`, `aud` and `repository` claims are not secrets — but never print the
> whole token, which is a credential. Delete the workflow once you have the answer.
>
> Then put the exact subject you saw into the trust policy, keeping `:*` on the
> end so any branch or tag in that repo still matches:
>
> ```text
> "token.actions.githubusercontent.com:sub": "repo:you@8456990/your-repo@1329892525:*"
> ```
>
> Pinning the IDs is *better* than the name-based form, not a workaround: numeric
> IDs never change, so the trust survives a rename and can't be inherited by
> someone who later registers a username you gave up.
>
> Resist the temptation to "fix" it with `repo:you*/your-repo*:*`. That wildcard
> also matches `you-evil/your-repo-evil`, and hands your AWS role to a stranger.

Scope its permissions to your one bucket and your one distribution:

```bash
cat > gh-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject","s3:DeleteObject","s3:ListBucket","s3:GetObject"],
      "Resource": ["arn:aws:s3:::${BUCKET}","arn:aws:s3:::${BUCKET}/*"]
    },
    {
      "Effect": "Allow",
      "Action": ["cloudfront:CreateInvalidation"],
      "Resource": "${DIST_ARN}"
    }
  ]
}
EOF

aws iam put-role-policy --role-name github-deploy \
  --policy-name deploy --policy-document file://gh-policy.json
```

That list is the entire blast radius if this role were ever misused: overwrite
one bucket, invalidate one distribution. Nothing else.

### 6.3 The workflow

`.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  id-token: write      # required for OIDC — without it, auth fails
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Delete these two steps if your site needs no build
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci && npm run build

      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/github-deploy
          aws-region: ${{ vars.AWS_REGION }}

      - run: |
          aws s3 sync dist/ s3://${{ vars.S3_BUCKET }}/ --delete \
            --exclude ".*" --exclude ".*/*"

      - run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ vars.CLOUDFRONT_DIST_ID }} \
            --paths "/*"
```

Change `dist/` to whatever folder holds your built files.

**If you have no build step, don't put `.` here.** In a GitHub Action, `.` is
the checked-out repository root, so you would publish `.git/` and
`.github/workflows/` to your live site — and `--delete` would then make that the
permanent contents of the bucket. Move your HTML into a `site/` folder and sync
that instead. (This repository does exactly that, for exactly this reason.)

Set the values, from your project folder:

```bash
gh secret set AWS_ACCOUNT_ID   --body "$ACCOUNT_ID"
gh variable set AWS_REGION     --body "$REGION"
gh variable set S3_BUCKET      --body "$BUCKET"
gh variable set CLOUDFRONT_DIST_ID --body "$DIST_ID"
```

The account ID goes in a **secret** — it isn't a credential, but it's
reconnaissance you needn't hand out. Bucket name and distribution ID are
**variables**: both are effectively public anyway.

```bash
git add .github && git commit -m "Deploy on push" && git push
gh run watch
```

From now on, `git push` is the deploy.

---

## Part 7 — What it costs

| Thing | Cost |
|---|---|
| Domain | ~$12–16/yr |
| **Route 53 hosted zone** | **$0.50/month** — the only charge that accrues with zero traffic |
| S3 storage | Fractions of a penny at this size |
| CloudFront | Generous free tier; a personal site won't touch it |
| Lambda | 1M free requests/month |
| ACM certificate | Free, always, with CloudFront |

Roughly **£15–20/year all in**, nearly all of it the domain.
[Current pricing](https://aws.amazon.com/pricing/) — check rather than trusting
this table.

**A second site on the same domain costs nothing extra.** A second *domain*
means a second hosted zone, so another $6/yr.

---

## Part 8 — Worth doing next

**Lock the Lambda's back door.** Your `.on.aws` URL still works directly,
bypassing CloudFront and any protection you put there. Switch it to IAM auth and
let only your distribution through:

```bash
aws lambda update-function-url-config --function-name api --auth-type AWS_IAM
aws lambda remove-permission --function-name api \
  --statement-id FunctionURLAllowPublicAccess
aws lambda add-permission --function-name api \
  --statement-id AllowCloudFront \
  --action lambda:InvokeFunctionUrl \
  --principal cloudfront.amazonaws.com \
  --source-arn arn:aws:cloudfront::${ACCOUNT_ID}:distribution/${DIST_ID} \
  --function-url-auth-type AWS_IAM

# Both actions are required. With only InvokeFunctionUrl, CloudFront's signed
# request is accepted at the URL and then refused at the function, and /api/*
# returns 403 with nothing in the logs to explain it.
aws lambda add-permission --function-name api \
  --statement-id AllowCloudFrontInvoke \
  --action lambda:InvokeFunction \
  --principal cloudfront.amazonaws.com \
  --source-arn arn:aws:cloudfront::${ACCOUNT_ID}:distribution/${DIST_ID}
```

Then attach an Origin Access Control of type *Lambda* to that origin (console:
CloudFront → Origin access → Create control setting). One catch: with OAC,
`POST`/`PUT` requests must carry an `x-amz-content-sha256` header containing the
SHA-256 of the body — irrelevant for a GET-only site, and it will bite the moment
you add a form.

**Other next steps:** `aws logs tail /aws/lambda/api --follow` for logs; repeat
Parts 4–5 on a subdomain for a second app (~10 minutes once the zone exists);
and when you've done this twice by hand, look at AWS SAM or CDK — doing it
manually first means you'll understand what the tools generate instead of
cargo-culting a template.

---

## Part 9 — Turning it off

If you abandon the project, **the hosted zone keeps charging $0.50/month**,
which is small enough to go unnoticed for years.

**First, get your variables back** — this section always runs in a new terminal
weeks later, so start with `source ~/.config/myproject/env` (see 2.5) or re-set
`DOMAIN`, `BUCKET`, `DIST_ID` and `ZONE_ID` by hand.

```bash
# 1. Disable CloudFront. It cannot be deleted while enabled, and the ETag
#    changes with every modification, so re-read it each time.
aws cloudfront get-distribution-config --id $DIST_ID > dist.json
ETAG=$(jq -r '.ETag' dist.json)
jq '.DistributionConfig | .Enabled = false' dist.json > dist-off.json
aws cloudfront update-distribution --id $DIST_ID \
  --distribution-config file://dist-off.json --if-match "$ETAG"

# 2. Wait for the disable to roll out (~15 minutes), then delete with a FRESH ETag
aws cloudfront wait distribution-deployed --id $DIST_ID
ETAG=$(aws cloudfront get-distribution-config --id $DIST_ID --query ETag --output text)
aws cloudfront delete-distribution --id $DIST_ID --if-match "$ETAG"

# 3. Bucket and Lambda
aws s3 rm "s3://$BUCKET" --recursive && aws s3api delete-bucket --bucket "$BUCKET"
aws lambda delete-function --function-name api 2>/dev/null || true

# 4. IAM
aws iam delete-role-policy --role-name github-deploy --policy-name deploy 2>/dev/null || true
aws iam delete-role --role-name github-deploy 2>/dev/null || true

# 5. Empty the hosted zone BEFORE deleting it. delete-hosted-zone fails with
#    HostedZoneNotEmpty while your A records and the ACM validation CNAME are
#    still there — and people read that error as "done" and keep paying.
aws route53 list-resource-record-sets --hosted-zone-id $ZONE_ID \
  --query "ResourceRecordSets[?Type!='NS' && Type!='SOA']" > records.json
jq '{Changes: [.[] | {Action: "DELETE", ResourceRecordSet: .}]}' records.json > delete-records.json
[ "$(jq '.Changes | length' delete-records.json)" -gt 0 ] && \
  aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID \
    --change-batch file://delete-records.json

aws route53 delete-hosted-zone --id $ZONE_ID
```

**Then check the charge has actually stopped:**

```bash
aws route53 list-hosted-zones --query "HostedZones[?Name=='${DOMAIN}.']"
```

Empty output means the $0.50/month is gone. Anything else means it isn't.

The domain registration is separate and runs to its yearly expiry — turn off
auto-renew in the Route 53 console if you don't want it.

---

## Things that will bite you

| Symptom | Cause |
|---|---|
| CloudFront won't accept the certificate | Cert isn't in `us-east-1`. Recreate it there |
| `InvalidLocationConstraint` creating a bucket | You're in `us-east-1` — drop the `--create-bucket-configuration` flag |
| `AccessDenied` from CloudFront | Bucket policy missing, or its `AWS:SourceArn` doesn't match the distribution |
| ACM stuck "Pending validation" | Validation CNAME wrong or missing — check with `dig` |
| 403 from the Lambda URL | `add-permission` skipped after creating the URL |
| Deep links 404 on an SPA | Add the 403/404 → `/index.html` custom error responses |
| Code changes don't appear | CloudFront cache. Invalidate, then hard-reload the browser |
| `Not authorized to perform sts:AssumeRoleWithWebIdentity` | The trust policy `sub` doesn't match. Very often GitHub sends an **ID-qualified** subject (`repo:you@123/repo@456:…`) — print the real claim, see Part 6.2 |
| `Credentials could not be loaded` in Actions | Workflow is missing `permissions: id-token: write` |
| Workflow green, site unchanged | The invalidation step didn't run, or synced the wrong folder |
| Deploy wiped the site | `aws s3 sync --delete` ran from the wrong directory |
| `InvalidClientTokenId` | Access key wrong or deleted. Rerun `aws configure` |
| Domain suspended after two weeks | ICANN verification email never clicked |
| `.dev` site shows `ERR_SSL_PROTOCOL_ERROR` | CloudFront not deployed yet, or the alias record is missing. `.dev` has no plain-HTTP fallback |

---

## Working with Claude Code on this track

- **Give it the goal, not the commands.** "Create the CloudFront distribution
  from Part 4.3 and wire the bucket policy" beats pasting commands one at a time.
- **Ask it to explain before running.** "What does this trust policy actually
  do?" is a fair question with a real answer.
- **Never paste your secret key into the chat.** Claude uses the CLI, which reads
  `~/.aws/credentials` itself.
- **Paste whole errors, not summaries.** These failures look like permissions
  problems when they're usually configuration ones.
- **Ask what it costs** before creating anything you didn't plan for. AWS has
  around 200 services and most of them are not free.

---

**Next:** [Share it →](30-share-it.md)
