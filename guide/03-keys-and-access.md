# Keys, and giving Claude access

**You'll end with:** a working API key stored somewhere it can't leak, a spend
cap so it can't bankrupt you, and a clear rule about what Claude Code needs from
you. **Time:** ~20 minutes, most of it in the Claude Console.

This page covers the two things people mean when they say "keys": the credentials
your *app* uses to call a paid service, and the credentials *Claude Code* uses to
touch your cloud accounts. They're related, and they're both easy to get wrong
exactly once.

Every term is explained where it first appears; if you land mid-page and hit an
unfamiliar one, the [glossary](99-glossary.md) has it.

If your project is a plain static site that calls nothing, you can skim parts 1
to 4 and read [part 5](#5-giving-claude-code-access-to-your-accounts), which
applies to everyone.

---

## 1. What an API key actually is

An **API key** is a password for a program rather than a person. When your code
calls someone else's service — Anthropic, OpenAI, Stripe, a weather API — that
service needs to know whose account to charge and whose data to return. There's
no login box in the middle of a program, so instead the request carries a long
random string that says "it's me".

They look like this:

```text
sk-ant-api03-XbK9....................................................
AKIAIOSFODNN7EXAMPLE
ghp_16C7e42F292c6912E7710c838347Ae178B4a
```

Three things worth knowing about that shape:

- **The prefix is deliberate.** `sk-ant-` for an Anthropic secret key, `AKIA` for
  an AWS access key ID, `ghp_` for a GitHub personal access token, `sk_live_` for
  a live Stripe secret. Providers agreed to use recognisable prefixes so that
  *scanners* can spot a leaked key in public code. GitHub's secret scanning, and
  the bots crawling GitHub for other reasons, both work by pattern-matching those
  prefixes. The prefix exists to save you.
- **The rest is random on purpose.** Nobody guesses a key. Keys leak; they are
  not cracked.
- **Anyone holding it is you.** A key carries no notion of *who* is using it.
  Someone who copies your Anthropic key can spend your credit; someone who copies
  your AWS key can create servers you pay for. This is not theoretical — it's the
  single most common way a hobby project turns into a bill.

> A key is not the same as a *username and password*. You can't put two-factor
> authentication in front of a key, because there's no human there to be
> prompted. That's exactly why the rest of this page exists.

---

## 2. The one rule, and where keys go instead

**Keys never go in your code, never in a repository, and never pasted into a
chat window.** That's the whole rule. Everything below is just the mechanics of
following it.

(A **repository**, or "repo", is the folder of your project as Git tracks it —
including every past version. That "every past version" part matters later, in
[part 6](#6-when-a-key-leaks). If none of that is familiar yet,
[05 — GitHub](05-github.md) covers it properly.)

The alternative is always the same idea: the key lives *outside* the code, and
the code asks for it by name at the moment it runs.

### What an environment variable actually is

This guide uses the term constantly, so here it is properly.

An **environment variable** is a named value that the operating system hands to a
program at the moment that program starts. Think of it as a small label pinned to
the program: `ANTHROPIC_API_KEY=sk-ant-…`. The program asks the operating system
"what's the value of `ANTHROPIC_API_KEY`?" and gets the string back. The value is
never written down inside the program itself.

That's the entire trick, and it's why the whole industry does it this way: the
*same* code runs on your laptop and on the server, and each place supplies its
own value. Nothing secret ever ends up in a file that gets copied around.

You already have dozens of them. Try this:

```bash
echo $HOME
echo $PATH
```

`$HOME` and `$PATH` are environment variables your shell was handed when it
started. Setting one of your own, for the current terminal window only:

```bash
export ANTHROPIC_API_KEY="sk-ant-api03-your-real-key"
echo $ANTHROPIC_API_KEY
```

```powershell
# PowerShell, on Windows
$env:ANTHROPIC_API_KEY = "sk-ant-api03-your-real-key"
```

Use the PowerShell version only if you're on Windows and *not* using WSL (Windows
Subsystem for Linux, which gives you a real Linux terminal inside Windows). If
you followed [01 — Your machine](01-your-machine.md), you're in WSL and the
`export` version above is the one you want.

> **The failure mode nobody warns you about:** environment variables are handed
> out *when a program starts*. If your app was already running when you typed
> `export`, it did not get the new value, and it will keep saying the key is
> missing until you stop it and start it again. Same for a second terminal
> window — it never saw the `export` at all. If a variable "isn't working", stop
> the program, check `echo $THE_NAME` in the *same* window, and start it again.

A second, quieter problem: typing `export MY_KEY=...` puts the key into your
shell history file (`~/.zsh_history` or `~/.bash_history`) in plain text. That's
not a disaster, but it's why the next option is usually better.

### The three legitimate homes for a key

| Where | Use it for | Watch out for |
|---|---|---|
| A `.env` file in the project, listed in `.gitignore` | Local development | It is a plain text file with no protection except never being committed |
| An environment variable set in your shell | One-off scripts, command-line tools | Vanishes when you close the terminal; lands in shell history |
| Your host's dashboard (Cloudflare, AWS, GitHub Actions secrets) | Anything deployed | Changing it usually needs a redeploy before the app sees it |

A `.env` file is nothing magical. It's a plain text file, one `NAME=value` per
line, no spaces around the `=`:

```text
ANTHROPIC_API_KEY=sk-ant-api03-your-real-key
DATABASE_URL=postgres://user:pass@localhost:5432/dev
```

Something has to read it — the `dotenv` package in Node, `python-dotenv` in
Python, or a framework like Next.js or Vite that loads it automatically. It is
**not encrypted**. The only thing protecting it is that `.gitignore` keeps it out
of your repository, which is why
[05 — GitHub](05-github.md) makes you write `.gitignore` *before* your first
commit rather than after.

Commit a `.env.example` alongside it with the *names* and fake values, so anyone
cloning your repo knows what to fill in. That file is safe and useful.

For the full list of what is and isn't a secret — publishable keys, bucket names,
account IDs, the awkward Supabase case — see
[what counts as a secret](05-github.md#3-what-counts-as-a-secret) on the GitHub
page. It isn't repeated here.

---

## 3. Getting an Anthropic API key

If your project calls Claude, this is where the key comes from. If it calls
OpenAI or something else, the shape of the process is near enough identical —
only the URLs change.

### Billing is separate from your Claude.ai subscription

This catches almost everyone. A Claude Pro or Max subscription pays for the
**chat app** at claude.ai. The **API** — what your deployed code calls — is a
different product with its own balance, billed by usage. Having Pro gives your
app nothing. You can sign into both with the same email, and they're still
separate wallets.

(Claude Code itself is the odd one out: it can run on either your subscription or
an API key. That's a separate question from the key your *app* needs, and it's
covered in [part 5](#5-giving-claude-code-access-to-your-accounts).)

### Step by step

1. Go to **[platform.claude.com](https://platform.claude.com)** and sign in. This
   is the Claude Console — the developer site, not the chat app. (The old address
   `console.anthropic.com` still works; it redirects here.) If you created the
   account in [02 — Accounts](02-accounts.md), use that login.
2. **Settings → API keys → Create Key.**
3. **Name it after the project** — `shipwhatyoubuilt-prod`, not `key1`. In six
   months you will have several, and the only way to know which one you can
   safely delete is the name. This is the reason to bother.
4. **Choose an expiry.** You'll be offered presets (a few hours, a day, 7 days,
   30 days), a custom length, or **Never**. For a project you're about to deploy
   and leave running, **Never** is the sane choice — an expired key means a site
   that dies silently in a month. For a key you're only using to try something
   out today, a short expiry is free insurance. You can't change this after the
   key is made.
5. **Copy it now.** The key is shown exactly once. Close that box without copying
   and there is no "show me again" — the value is genuinely not recoverable.
   Delete the key and create another; it costs nothing but a minute.
6. Paste it somewhere real immediately: your password manager, or straight into
   the `.env` file or host dashboard where it's going to live. Not a text file on
   your desktop called `key.txt`.
7. **Add credit.** Billing → add a payment method and buy credit. Until there's a
   balance, every call fails.

### Set a spend limit before you set anything else up

The Console has spend controls in the **Billing** area — a monthly spend cap, and
email alerts at thresholds you choose. (Anthropic reorganises these settings from
time to time, so if they're not exactly where this says, look around Billing and
Limits in Settings; the two controls themselves are what matter.) Set both now,
at a number that would annoy you rather than hurt you.

The reason is specific: your **backend** — the part of your app that runs on a
server rather than in the visitor's browser — is a public URL that spends your
money on behalf of whoever calls it. If someone finds it and hammers it, or if
your own code gets stuck in a retry loop, which is far more common, the cap is
what turns a horrible week into a mildly irritating morning.

Prices and free-credit offers change; check
**[claude.com/pricing](https://claude.com/pricing)** for what things actually
cost today rather than trusting a number written in a guide.

### One key per project

Create a separate key for each project, and a separate one for each environment
if you have a staging site — a private copy of the site you try changes on before
the real one. It costs nothing and buys you the ability to **delete
one key without breaking everything else you own**. A shared key means that the
day you have to rotate it, you have to redeploy every project at once, at speed,
under stress. That's how mistakes happen.

### When it doesn't work

| What you see | What it means | Fix |
|---|---|---|
| `401` / `authentication_error` / "invalid x-api-key" | The key is wrong, revoked, expired, or has a stray space or newline on the end | Re-copy it. Check for whitespace — a trailing newline from a copy-paste is the classic. Check the key's expiry in the Console; expired keys can't be reactivated, so make a new one |
| `400` "Your credit balance is too low" | The key is fine; the account has no money | Billing → add credit |
| `429` / `rate_limit_error` | Too many requests too fast, or you've hit an account tier limit | Slow down, add retries with a delay; check Limits in the Console |
| `undefined` where the key should be | The app never received the environment variable | It was set after the app started, set in a different terminal, or misspelt. Names are case-sensitive |
| Works locally, `500` when deployed | The variable exists on your laptop and not on the host | Set it in the host dashboard, then **redeploy** |

---

## 4. Using the key in a deployed app

### Why it cannot go in the browser

Anything that reaches the browser is readable by whoever is looking at it. Press
**F12** in any browser to open developer tools: the **Sources** tab lists every
JavaScript file the page loaded, in full, and the **Network** tab shows every
request including its headers. Finding `sk-ant-` in there takes about four
seconds.

So: **a key in front-end code is a public key.** ("Front-end" means the part of
your app that runs inside the visitor's browser — the opposite of the backend.)
Not "a bit risky" — public. It is being handed to every visitor along with the
page.

> **A build step does not hide it.** Bundlers like Vite, webpack and Next.js
> don't obscure values, they *inline* them into the output file. This is why Vite
> requires a `VITE_` prefix and Next.js a `NEXT_PUBLIC_` prefix before a variable
> is exposed to browser code — the prefix exists so that publishing a value is a
> deliberate thing you had to type. If a tutorial tells you to call your key
> `VITE_ANTHROPIC_API_KEY`, it is telling you to publish it.

The shape that works puts a small piece of *your* code in the middle:

```text
  Browser                 Your function                Anthropic
  (public)                (server-side, private)       (the API)

  fetch("/api/ask")  ──>  reads the key from     ──>   x-api-key: sk-ant-…
                          the environment
                          and calls the API
                     <──  returns just the       <──
                          answer
```

The browser never sees the key. It only ever talks to your own URL.

### Track A — Cloudflare Pages and Workers

In your Pages project: **Settings → Variables and Secrets → Add → Production**.
Add `ANTHROPIC_API_KEY`, paste the value, and tick **Encrypt**. Encrypted
variables can't be read back afterwards, even by you — only overwritten. That's
correct behaviour, not a bug.

Read it in a Pages Function or Worker — Cloudflare's names for a small piece of
your own code that runs on their servers instead of in the browser — from the
request context:

```javascript
export async function onRequestPost(context) {
  const key = context.env.ANTHROPIC_API_KEY;
  // ...
}
```

> **Two things bite people here.** First, Workers do not have Node's
> `process.env` unless you've turned on Node compatibility — `context.env` is the
> right thing to reach for, and `process.env.X is undefined` is the error you'll
> see if you forget. Second, **Production and Preview are separate lists**. Set
> the variable on Production only and every preview branch deploy returns a 500,
> which reads as "it broke for no reason" when in fact it never had the key.

Variables apply to *new* builds. After adding one, trigger a redeploy — the
deployment that's currently live was built without it.

Full walkthrough: [Track A: Cloudflare](10-cloudflare.md).

### Track B — AWS Lambda

A **Lambda function** is AWS's equivalent of a Worker: a lump of your code that
AWS runs on demand, with no server for you to manage. Each function carries its
own environment variables, set on the function itself:

```bash
aws lambda update-function-configuration \
  --function-name your-function \
  --environment "Variables={ANTHROPIC_API_KEY=sk-ant-api03-...}"
```

Read it in the handler the ordinary Node way:

```javascript
export const handler = async (event) => {
  const key = process.env.ANTHROPIC_API_KEY;
  // ...
};
```

> **That command replaces the entire variable set**, it doesn't add to it. If the
> function already had three variables and you run the above with one, the other
> two are gone and the function starts failing in a way that looks unrelated.
> Pass all of them every time, or set them in the AWS console where you can see
> the existing list.

Two honest caveats about Lambda environment variables:

- **They're visible to anyone with console read access to the function.** They're
  encrypted while stored, but anyone allowed to call
  `lambda:GetFunctionConfiguration` can read the value back in plain text. (Those
  permissions are handed out by **IAM**, Identity and Access Management — the AWS
  service that decides who is allowed to do what.) On a personal project where
  you're the only person with an account, that's fine. On anything shared, it
  isn't.
- **The upgrade is AWS Secrets Manager** — the secret lives in a separate service
  with its own access controls and audit trail, and the function fetches it at
  runtime. It charges a small amount per secret per month plus per call; see
  [AWS Secrets Manager pricing](https://aws.amazon.com/secrets-manager/pricing/)
  for the current figures. Worth it when other people have access to the account,
  or when the key controls money.

Full walkthrough: [Track B: AWS](20-aws.md).

### Your endpoint is now a public money-spender

Your function's URL is an **endpoint** — a single address that accepts requests.
Once it's live, anyone who finds it can call it, and each call costs you. Before
you share the link widely, it's worth adding one of:

- a **rate limit** (a cap on how many requests one visitor can make per minute);
- a [Cloudflare Turnstile](https://www.cloudflare.com/products/turnstile/) check
  on the form — Cloudflare's free "prove you're not a bot" widget, the
  less-annoying descendant of CAPTCHA;
- or simply a hard `max_tokens` value on every request. Tokens are the chunks of
  text Claude is billed by — roughly three-quarters of a word each — so capping
  them caps what any single call can cost.

And keep the Console spend limit from part 3 in place regardless — it's the
backstop that doesn't depend on you having thought of everything.

> Look at my backend function as if I'd just posted the URL publicly. What's the
> most expensive thing someone could make it do in an hour, and what's the
> smallest change that caps it?

---

## 5. Giving Claude Code access to your accounts

This is the other thing people mean by "giving Claude access", and it works
differently from what most people expect.

### Claude Code uses the credentials already on your machine

Claude Code runs on **your** computer, as **you**. When it runs `aws s3 ls`, that
command runs exactly as it would if you'd typed it — same user, same permissions,
same config files. So it doesn't need its own credentials for your cloud
accounts. It needs the command-line tools on your machine to be logged in, which
you do once, yourself:

| Service | Command | Where the credential ends up |
|---|---|---|
| AWS | `aws configure` | `~/.aws/credentials` |
| GitHub | `gh auth login` | Your OS keychain, or `~/.config/gh/` |
| Cloudflare | `wrangler login` | A token in `~/.config/.wrangler/` (browser-based; no key to copy) |

Each of those opens a browser or asks you for values *in the terminal*, not in
the chat. After that, Claude Code can use the tool and never has to know the
secret itself.

### Therefore: never paste a secret into the chat

Stated plainly, because it's the point of this section:

**If something asks you to paste a secret into the conversation, something is set
up wrong.** The right response is to stop and fix the setup, not to paste it.

The reasons are practical rather than dramatic. Your conversation is stored on
disk, it goes to the model, it might end up in a screenshot you send someone or a
transcript you share, and it is one careless `git add .` away from your
repository. None of that is necessary, because the command-line tool already
holds the credential and Claude reads it through the tool.

The same applies to the [Anthropic key from part 3](#3-getting-an-anthropic-api-key):
you put it in `.env` or the host dashboard yourself. Claude Code can *reference*
`ANTHROPIC_API_KEY` in code it writes without ever seeing the value.

> **If you've already pasted a key into a chat** — with Claude or anything else —
> don't spiral about it. Go to [part 6](#6-when-a-key-leaks) and rotate it. It
> takes two minutes and then it doesn't matter.

### What Claude Code can actually see

Worth knowing precisely, in both directions:

- **The files in the folder you opened it in**, and its subfolders. That includes
  your `.env`, if it's there. That's normal and often useful — but it's the
  reason to open Claude Code in your *project* folder and not in your home
  directory, where it can see everything you own.
- **The output of commands it runs.** If a command prints a secret, that secret
  is now in the conversation. This is why `cat .env` is a bad habit and
  `aws sts get-caller-identity` (which prints an account ID and no credentials)
  is a fine one.
- **Not** your browser, your email, or anything outside that folder, unless you
  connect a tool that provides it.

### Permissions: read before you approve

By default, Claude Code asks before it edits a file or runs a command. You can
approve one command, approve a kind of command for the rest of the session, or
switch to a mode that stops asking. Faster modes are legitimate — plenty of
people use them for a repetitive task in a repo they can throw away — but the
default exists for a reason on a project you care about.

The habit worth building is small: **read the command before you approve it.**
You do not need to understand every flag. You need to notice the shapes that are
hard to undo:

| Shape | Why to look twice |
|---|---|
| `rm -rf …` | Deletes without confirmation and without a bin to recover from |
| `git push --force` | Overwrites history on the remote, including other people's |
| `curl … \| bash` | Runs code from the internet unread. Sometimes normal, always worth a glance at the URL |
| `aws … delete-…` / `terraform destroy` | Removes real infrastructure |
| Anything writing to `~/.aws`, `~/.ssh`, `~/.gitconfig` | Touching credentials rather than your project |

"What does this command do, and what happens if it goes wrong?" is a fair
question with a real answer, and asking it costs you ten seconds.

---

## 6. When a key leaks

It happens to careful people. The order of operations matters more than anything
else on this page, so here it is first:

**Rotate first. Clean up git history second. Never the other way round.**

### 1. Rotate — right now, before you do anything else

Go to the provider and **delete the exposed key, then create a new one**:

- **Anthropic:** platform.claude.com → Settings → API keys → delete → Create Key
- **AWS:** IAM → Users → your user → Security credentials → deactivate, then
  delete the access key → create a new one → `aws configure` again
- **GitHub:** Settings → Developer settings → Personal access tokens → revoke
- **Stripe:** Developers → API keys → roll the secret key
- **Cloudflare:** My Profile → API Tokens → roll

Do this **on suspicion, not on proof**. Rotating a key you didn't need to rotate
costs you five minutes. Not rotating one you did costs you considerably more.

Why the order is non-negotiable: public commits are scraped by bots within
*seconds* of the push — there are people running scanners against GitHub's public
event firehose full time, and exposed AWS keys have been observed in use for
crypto mining within minutes. Nothing you do to your git history is fast enough
to beat that. But the moment the key is dead, the copy the bots have is worthless
and **the leak stops being an emergency and becomes a tidying job**.

Then check the damage: your Anthropic usage page, your AWS billing dashboard,
your Stripe logs. Usually nothing happened. Look anyway.

### 2. Then clean the history

Understand what you're up against: **deleting the file in a later commit does
nothing on its own.** Git keeps every version of everything. The old commit still
contains the key, it's still fetchable by anyone who clones the repo, and GitHub
will still serve it to anyone who knows that commit's ID — the long string of
letters and numbers Git gives every saved change. "I removed it in the next
commit" is the single most common mistaken belief about this.

Actually removing it means rewriting history, with one of:

- **[git-filter-repo](https://github.com/newren/git-filter-repo)** — the current
  recommended tool, and what Git's own documentation now points to.
- **[BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)** — older,
  simpler for the specific job of "remove this string everywhere". Needs Java.

Both rewrite every affected commit, which means a **force-push** — overwriting
GitHub's copy of your history with your rewritten one — and which means anyone
who already cloned your repo has a copy that no longer matches. On a personal
project nobody has forked, that's painless. On anything with collaborators, tell
them first.

> If the commit was **never pushed**, you got away with it. Clean it up locally
> and rotate the key anyway — "I'm fairly sure it never left my laptop" is not a
> security posture.

And turn on GitHub's push protection so the next one is caught before it leaves
your machine — one command, in
[05 — GitHub](05-github.md#turn-on-the-safety-nets).

---

## 7. Quick reference

| Key type | What it looks like | Where it belongs | If it leaks |
|---|---|---|---|
| Anthropic API key | `sk-ant-api03-…` | `.env` (gitignored) or host dashboard | Console → Settings → API keys → delete, create new, check Usage |
| OpenAI API key | `sk-proj-…` or `sk-…` | Same | platform.openai.com → API keys → revoke, create new |
| AWS access key | ID `AKIA…` (20 characters) plus a separate 40-character secret | `~/.aws/credentials` only, via `aws configure` | **Immediately:** IAM → deactivate → delete → new key. Then check Billing, and CloudTrail (the AWS log of every action taken on your account) |
| GitHub token | `ghp_…` or `github_pat_…` | Ideally nowhere — use `gh auth login` instead | Settings → Developer settings → revoke |
| Cloudflare API token | `cfut_…` on newly created tokens; older ones are 40 characters with no prefix | Ideally nowhere — use `wrangler login` | My Profile → API Tokens → roll |
| Stripe secret key | `sk_live_…` / `sk_test_…` | Server-side environment variable only | Dashboard → Developers → API keys → roll. Treat `sk_live_` as an emergency |
| Stripe publishable key | `pk_live_…` | Browser code — it's designed for that | Nothing. It is public by design |
| Supabase publishable key | `sb_publishable_…`; older projects have a long `eyJ…` "anon" key instead | Browser code — **only** with Row Level Security on | Nothing, *if* RLS is right. If it isn't, fix the policies; that's the actual leak |
| Database URL | `postgres://user:pass@host/db` | Environment variable | Change the database password, then update the variable |
| Private key file | `-----BEGIN … PRIVATE KEY-----`, `.pem`, `.key` | `~/.ssh/` or a secrets manager, mode `600` | Generate a new pair; remove the old public key from everywhere it was authorised |

**Row Level Security** (RLS) is a database setting that decides, row by row, who
is allowed to see what. It's what makes a Supabase key safe to publish: the key
itself grants nothing, and your rules do the deciding. With RLS off, that same
published key is a read-write handle on your whole database. This is the single
most common way a Supabase project leaks, and it isn't really a key problem at
all.

And one prompt worth running in your project folder before anything goes public:

> Go through this project as if it were about to be a public repository. Find
> anything that looks like a credential — in the code, in config files, in the
> git history, in commit messages. For each one tell me what it is, where it
> should live instead, and whether it's already been committed.

---

**Next:** [The three layers →](04-three-layers.md)
