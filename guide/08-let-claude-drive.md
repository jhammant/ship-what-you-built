# Let Claude drive

**This is the recommended path.** You create the accounts, you authorise the
tools on your own machine, and then you hand the work to Claude Code and answer
its questions.

**Time:** about 30 minutes, most of it waiting for DNS.
**What you type:** roughly six commands and a paragraph of English.

The rest of this guide — [the three layers](06-four-layers.md),
[Track A](10-cloudflare.md), [Track B](20-aws.md) — explains what is actually
happening underneath. You do not have to read it first. Come back to it when
something breaks, or when you want to understand what you just did, which is
worth doing at some point but not tonight.

---

## Why this order

The reason this works is that **the credentials never travel through the
conversation.** You log in once with each tool. The tool stores the credential
on your machine, in the place it is designed for. Claude Code then runs those
tools as you, and reads what they print.

```text
  You  ──login──>  the CLI tool  ──stores──>  a file on your machine
                        ▲
                        │ runs it as you
                   Claude Code
```

So the honest version of "give Claude the keys" is: **you never paste a key.**
You authorise the tools, and Claude uses the tools.

> **If anything ever asks you to paste a secret into the chat, stop.** Something
> is set up wrong. There is no step in this guide where that is the right
> answer. See [Keys, and giving Claude access](05-keys-and-access.md).

---

## Step 1 — Create the accounts

Do this in a browser. It is the one part that genuinely cannot be automated,
because it involves your email, your card and your consent.

Follow **[The accounts you need](04-accounts.md)** and come back. In short:

| Account | Who needs it | Card required? |
|---|---|---|
| **GitHub** | everyone | no |
| **Cloudflare** | Track A | only to buy a domain |
| **AWS** | Track B | yes, at signup |
| **Anthropic** | only if your project calls Claude | yes, for API credit |

**Do the safety steps while you are there** — two-factor on GitHub, and on AWS
the root MFA and the budget alarm. Those pages explain why in detail; the short
version is that they are the difference between a mistake costing nothing and a
mistake costing four figures.

---

## Step 2 — Authorise the tools on your machine

Each of these opens a browser, you approve, and it writes a credential locally.
You are not typing any secrets — you are clicking "allow".

```bash
# GitHub — opens a browser, you paste a one-time code it shows you
gh auth login
```

Choose **GitHub.com** → **HTTPS** → **Login with a web browser**.

Then, for your track:

```bash
# Track A — Cloudflare. Opens a browser, you click Allow.
npx --yes wrangler@latest login
```

```bash
# Track B — AWS. This one asks for an access key you created in the console.
aws configure
```

`aws configure` is the exception: AWS has no browser login for the CLI by
default, so you paste the access key **into the terminal prompt**, not into the
chat. It writes `~/.aws/credentials`, which is exactly where it belongs.
[04-accounts.md](04-accounts.md) walks through creating that key as a limited
IAM user rather than using your root account.

### Prove it worked

Run these. Each should print something about *you*:

```bash
gh auth status                   # your GitHub username
aws sts get-caller-identity      # your AWS account id and user (Track B)
npx wrangler whoami              # your Cloudflare email (Track A)
```

If one of them errors, fix that before continuing — Claude cannot work around a
credential that isn't there, and the errors it hits later will be confusing
rather than obvious.

---

## Step 3 — Hand it over

Open a terminal **in the folder where your project lives** and start Claude
Code:

```bash
cd /path/to/your-project
claude
```

Then paste this, changing only the two obvious things:

> I've built something in this folder and I want it online at a domain I own.
>
> Read https://shipwhatyoubuilt.com/guide/00-start-here.html and follow it.
>
> - I want to use **Track B (AWS)** — I've done `aws configure` already.
> - The domain I want is **yourthing.com** (I have not bought it yet).
>
> Work out what shape my project is first and tell me, before doing anything
> else. Stop and ask me before anything that spends money, and before the first
> commit. Explain what each step is doing as you go — I want to understand it,
> not just have it done.

Swap **Track B (AWS)** for **Track A (Cloudflare)** if that is what you set up,
and put your real domain in.

That is the whole handover.

### If you installed the skill

Even easier — the [skill](https://github.com/jhammant/ship-what-you-built/tree/main/skill)
teaches Claude Code this workflow permanently, so you can just say:

> Put this online at yourthing.com using AWS.

and later, forever after:

> Deploy it
>
> What's live right now?
>
> It's still showing the old version

---

## What Claude will do, and where it stops

Worth skimming, so nothing is a surprise:

1. **Work out what you built** — static files, something with a backend, or
   something that needs to keep running. If it's the third, it will tell you
   plainly that neither track's free tier fits, rather than letting you find
   out in an hour.
2. **Check for secrets** before anything becomes public — API keys, `.env`
   files, and personal details you might not want permanently searchable.
3. **Stop, and show you what is about to be committed.** A first commit is
   permanent, so this one is yours to approve.
4. **Create the GitHub repository**, with secret scanning on.
5. **Buy the domain** — after asking you, because it is the one step that
   spends money and is not refundable.
6. **Wire up hosting, HTTPS and DNS**, then wait for them, which is most of the
   elapsed time.
7. **Set up deploys on push**, so changing a file and pushing updates the live
   site.
8. **Check it is actually live** and tell you the URL.

**The three places it should stop and ask you:** spending money, the first
commit, and making the repository public. If it doesn't stop at those, say so —
that's the guide being wrong, and worth
[an issue](https://github.com/jhammant/ship-what-you-built/issues).

---

## How to be a good driver

You are not just watching. The things that make this go well:

- **Answer in plain English.** "No, use my existing domain" is a perfectly good
  instruction. You don't need to know the command.
- **Ask what a step does** before approving it, whenever you're unsure. "What
  does this trust policy actually allow?" gets a real answer, and asking is how
  you end up understanding your own infrastructure.
- **Paste whole errors, never summaries.** These failures routinely *look* like
  permission problems and *are* configuration problems, and the difference is
  always in the part people trim off.
- **Say when something looks wrong.** "That's not the domain I asked for" early
  is worth an hour later.
- **Don't approve anything that spends money you weren't expecting.** AWS has
  around 200 services and most of them are not free.

---

## When it goes wrong

It will, somewhere — usually DNS, usually just slow rather than broken.

Ask for the diagnosis before the fix:

> This is failing. Here's the complete error:
>
> ```text
> <paste everything>
> ```
>
> Before changing anything, tell me which of the four layers you think this is
> and why.

That one habit stops the shotgun approach where six settings change at once and
you end up with a working site and no idea which change mattered — which is
barely better than a broken one.

[When it breaks](90-troubleshooting.md) has the symptom-to-cause tables if you'd
rather look it up yourself.

---

## Doing it by hand instead

Nothing here is magic, and some people would rather type it themselves — it's a
genuinely good way to learn, and you end up able to debug it later.

- **[Track A — Cloudflare](10-cloudflare.md)** · ~20 minutes, fewest moving parts
- **[Track B — AWS](20-aws.md)** · ~90 minutes, the stack most companies run

Both contain every command, with an explanation of what each one does.

---

**Next:** [The three layers →](06-four-layers.md) — ten minutes that make
everything above make sense, whether or not you typed it yourself.
