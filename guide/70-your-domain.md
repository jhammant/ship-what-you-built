# Getting more from one domain

**This page gets you two things: every future project hosted on the domain you
already own, and email at your own address. About forty minutes, and it will
save you most of your hosting bill.**

The single most expensive habit in this whole guide is buying a domain per
idea. This is the alternative.

---

## Why one domain, not ten

Look again at what a real bill is actually made of — the same account from
[Making money from it](60-money.md#the-other-side-what-it-actually-costs-to-run):

| | Per year |
|---|---|
| Ten projects, each on its own domain | ~£120 in domains, plus ~£60 in DNS zones |
| Ten projects, all on subdomains of one domain | **~£12 in domain, plus ~£6 in one zone** |

**A subdomain costs nothing.** Not a registration fee, not a hosted zone, not a
certificate. `tide.yourthing.com` is a record inside a zone you already pay for.
You can have as many as you like.

That is the whole argument, and it's worth internalising before your second
idea rather than after your tenth. Owning twenty domains is a decision people
make one £12 purchase at a time.

> **Where a separate domain genuinely earns its place:** something with its own
> brand that you'd introduce to a stranger by name, something you might sell
> one day, or something whose audience would find `project.yourname.com`
> confusing. A side project you're showing three friends is not that.

---

## What a subdomain actually is

Nothing special. `yourthing.com` is a zone — a set of DNS records — and
`tide.yourthing.com` is a record inside it, exactly like `www` is.
See [the four layers](06-four-layers.md#layer-2--dns) if that sentence
didn't land.

Which means:

- **No registrar involved.** You're not buying anything; you're adding a row.
- **No new hosted zone.** It lives in the one you have.
- **It can point anywhere.** `blog.yourthing.com` on Cloudflare and
  `api.yourthing.com` on AWS is a perfectly normal arrangement.

A naming convention that ages well:

```text
yourthing.com            you, or your main thing
www.yourthing.com        redirects to the apex
tide.yourthing.com       one project
recipes.yourthing.com    another
api.yourthing.com        something machine-facing
staging.yourthing.com    a version you're not ready to show
```

---

## The trick that makes it painless: one wildcard certificate

Without this you request a new certificate every time you add a project, and
validate it, and wait. Instead, request **one** certificate covering everything:

```text
*.yourthing.com      covers tide., recipes., api., anything
yourthing.com        the apex — see the warning below
```

Validate it once, and every future subdomain is already covered.

> **Two things about wildcards that catch people out.**
>
> `*.yourthing.com` covers **exactly one level**. It matches
> `tide.yourthing.com` but *not* `beta.tide.yourthing.com`. If you want
> nesting, you need `*.tide.yourthing.com` as well.
>
> And it does **not** cover the apex. `*.yourthing.com` does not match
> `yourthing.com`. Always request both names on the same certificate, which is
> why the block above has two lines.

### Track B — requesting it

```bash
export CERT_ARN=$(aws acm request-certificate \
  --domain-name "$DOMAIN" \
  --subject-alternative-names "*.$DOMAIN" \
  --validation-method DNS \
  --region us-east-1 \
  --query CertificateArn --output text)
```

Then publish the validation records exactly as in
[Track B, Part 4.2](20-aws.md#42-the-certificate--us-east-1-always) — and note
that ACM often needs only *one* record for an apex-plus-wildcard pair, because
both validate against the same name. Publishing all the records it lists,
deduplicated, handles either case.

### Track A — you don't have to think about it

Cloudflare issues and renews certificates for the domain and its subdomains as
part of having the zone there. Add the custom domain to your Pages project and
it's covered.

---

## Adding a project on a subdomain

### Track A (Cloudflare)

1. Deploy the project as its own Pages project.
2. Pages project → **Custom domains** → **Set up a custom domain** →
   `tide.yourthing.com`.
3. Done. The DNS record is created for you and the certificate is already
   handled.

That really is the whole procedure, and it's the strongest argument for Track A
if you expect to host several things.

### Track B (AWS)

Each project gets its own bucket and its own distribution, sharing the one
certificate and the one hosted zone:

```bash
export SUB=tide
export BUCKET=$(printf '%s' "$SUB.$DOMAIN" | tr '.' '-')   # tide-yourthing-com

aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

Then create a distribution exactly as in
[Part 4.3](20-aws.md#43-cloudfront-with-a-private-bucket), changing two things:
`Aliases` becomes `["tide.yourthing.com"]`, and `ACMCertificateArn` is the
wildcard certificate you already have. Finally, the alias record:

```bash
aws route53 change-resource-record-sets --hosted-zone-id "$ZONE_ID" --change-batch "{
  \"Changes\": [{
    \"Action\": \"UPSERT\",
    \"ResourceRecordSet\": {
      \"Name\": \"$SUB.$DOMAIN\",
      \"Type\": \"A\",
      \"AliasTarget\": {
        \"HostedZoneId\": \"Z2FDTNDATAQYW2\",
        \"DNSName\": \"$DIST_DOMAIN\",
        \"EvaluateTargetHealth\": false
      }
    }
  }]
}"
```

**The cost of that second project: nothing.** Same zone, same certificate, and
S3 plus CloudFront at this scale is fractions of a penny.

> **One thing worth knowing before you go all-in.** Browsers treat subdomains
> of the same domain as related for some purposes — a cookie set with
> `domain=.yourthing.com` is readable by every subdomain. For separate hobby
> projects this doesn't matter. If one of them handles logins or anything
> sensitive, keep its cookies scoped to its own hostname (which is the default
> — just don't widen it), or give that one its own domain.

If a project outgrows the arrangement, moving it to its own domain later is
straightforward: buy the domain, point it at the same distribution, and leave a
redirect behind.

---

## Email at your own domain

`hello@yourthing.com` rather than a Gmail address. Worth doing sooner than you'd
think: AdSense, Stripe, Apple's developer programme and most partners take a
custom domain more seriously, and several will ask for one.

**Hosting your website and receiving email are unrelated.** Your site is layer
3; email is a different set of DNS records in layer 2, pointing at a different
company entirely. You can host on AWS and take email through Apple without the
two knowing about each other.

### Option 0 — just forward it (free, five minutes)

If you only want to *receive*, and you're happy replying from your existing
address, forwarding is enough and costs nothing. Cloudflare Email Routing does
this: `hello@yourthing.com` lands in your normal inbox. It adds the MX records
for you.

Start here unless you specifically need to *send* as `you@yourthing.com`. Most
people asking for custom email actually want this.

### Option 1 — iCloud+ (good if you're already paying for it)

If you already have an iCloud+ subscription — which most people with an iPhone
and more than 5GB of photos do — a custom email domain is included at no extra
cost. You use Apple Mail as normal and messages arrive at your own domain, and
it can be shared with Family members.

There are limits on how many domains and how many addresses each, so check
[Apple's current documentation](https://support.apple.com/en-gb/102540) rather
than trusting a number here. Set-up is a wizard in iCloud settings that tells
you exactly which DNS records to add.

**Best when:** you're in the Apple ecosystem already and want one personal
address that just works.

### Option 2 — Zoho Mail (best free tier for a real mailbox)

Zoho's free plan gives you a genuine mailbox rather than forwarding: **up to 5
users, 5GB each, on one domain**, at no cost.

The catch, and it's a real one: **the free tier has no IMAP, POP or Exchange
ActiveSync**. You use Zoho's webmail or its own mobile app — you cannot add the
account to Apple Mail, Outlook or Thunderbird unless you upgrade to a paid tier
(Mail Lite, a pound or two per user per month). Check the
[current plans](https://www.zoho.com/mail/zohomail-pricing.html) before
committing, since these change.

**Best when:** you want several real addresses on your own domain for free and
don't mind using their webmail.

### The records you'll be adding

Whichever you choose, the provider gives you a list like this. It's worth
knowing what each one does rather than pasting blindly:

| Record | What it does |
|---|---|
| **MX** | Where mail for this domain should be delivered. The essential one |
| **TXT** (SPF) | Lists who is allowed to send mail as you. Stops others forging your address |
| **TXT** (DKIM) | A signature proving a message really came from you and wasn't altered |
| **TXT** (DMARC) | Tells receivers what to do when SPF or DKIM fails |
| **TXT** (verification) | A one-off string proving to the provider that you own the domain |

Add all of them, not just MX. SPF and DKIM are what stop your mail landing in
spam, and DMARC is increasingly expected by the large providers.

### The mistake that silently breaks email

> **Moving your DNS without bringing the MX records is the classic disaster.**
> If you switch nameservers — say from your registrar to Cloudflare, as in
> [Track A step 2b](10-cloudflare.md#2b-you-already-own-a-domain-elsewhere) —
> the new provider imports what it can find, and anything it misses simply
> stops existing. Mail to your domain then bounces, and **nobody tells you**;
> you just quietly stop receiving email.
>
> Before changing nameservers, write down what you have:
>
> ```bash
> dig MX yourthing.com +short
> dig TXT yourthing.com +short
> dig TXT _dmarc.yourthing.com +short
> ```
>
> Then check the same commands return the same answers afterwards.

### Check it actually works

Send yourself a message, then send one *from* the address to a Gmail account
and check it doesn't land in spam. [mail-tester.com](https://www.mail-tester.com)
will score a message and tell you which of SPF, DKIM or DMARC is missing, which
is faster than guessing.

---

**Next:** [When it breaks →](90-troubleshooting.md)
