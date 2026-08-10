# The accounts you need

**You'll end with:** every account your track needs, each one set up so it can't
be taken away from you and can't quietly bill you.

**Time:** ~40 minutes, most of it waiting for verification emails and typing
codes off your phone.
**Cost:** nothing on this page. You don't spend anything until you buy a domain.

You don't need all of these. Which ones depend on your track, which you chose
in [Start here](00-start-here.md). The table tells you; the sections tell you how.
Any word below that you don't recognise is in
[the glossary](99-glossary.md).

---

## The whole list, at a glance

| Account | What it's for | Needed for | Card to sign up? | Cost at personal scale |
|---|---|---|---|---|
| **GitHub** | Stores your code in a *repository* — one project's files plus their whole history; both tracks deploy *from* it | Everyone, both tracks | No | Free for public and private repositories |
| **Cloudflare** | Buys your domain, runs its **DNS** — the lookup that turns `yourthing.com` into the address of the machine serving it — and hosts your site | Track A | No — only when you buy a domain | Free plan, plus the domain at cost |
| **AWS** | The same three jobs, on AWS | Track B | **Yes** | Sign-up credit first, then a small monthly amount, plus the domain |
| **Anthropic** | **API** access — an API is how one program asks another program to do something, so this is what lets your *deployed app* send requests to Claude | Only if your app calls Claude | Yes, to add credit | Prepaid credit, drawn down per request |

**Do them in this order:** password manager → GitHub → your track's account
(Cloudflare or AWS) → Anthropic if you need it. GitHub first because both tracks
need it and it's the one with no financial risk, so it's a gentle place to learn
what "verify your email, turn on 2FA" feels like.

> **Which email address?** Use one you will still control in five years. Not a
> work address — you lose it when you leave, and with it your domain, your
> hosting and your repo. Not an address on a domain you're about to buy, either:
> if the domain lapses you lose the email that would let you renew it. A personal
> Gmail/Fastmail/iCloud address is the right answer here.

---

## First: a password manager

A password manager is an app that generates and stores a different random
password for every site, so you only remember one. If you already use one, skip
this section.

The reason it belongs on this page rather than in a lecture about hygiene: the
four accounts below can, between them, take your domain, delete your code and
spend your money. They are exactly the accounts where reusing `Summer2024!`
matters, because password reuse means one leaked site hands an attacker all four.

Any of these is fine. Pick in under five minutes:

| Option | Where it lives | Notes |
|---|---|---|
| **1Password**, **Bitwarden** | Their servers, synced to your devices | Bitwarden has a free tier that covers this comfortably |
| **iCloud Keychain** (Apple) / **Google Password Manager** | Built into your OS or browser | Free, already on your machine, fine for this |
| A notebook in a drawer | Your drawer | Genuinely fine, as long as you actually write in it |

The one rule: the **recovery codes** you're about to generate for GitHub and
Cloudflare must go somewhere that is *not* your phone, because the failure you're
protecting against is losing your phone. A password manager entry synced to your
laptop, or a printout, both work. Both is better.

---

## GitHub — everyone needs this

GitHub hosts your code. A **repository** — "repo" — is one project's files plus
the record of every change ever made to them. You **commit** (save a labelled
snapshot of your changes) and then **push** (send those commits up to GitHub).
Both tracks watch your repository and rebuild your site whenever something is
pushed to it, so nothing else on this list works without it.
[Get it on GitHub](05-github.md) does the actual doing; this page only gets you
the account.

### 1. Sign up

Go to [github.com/signup](https://github.com/signup). It asks for an email, a
password and a username.

**Take a moment on the username.** It's not cosmetic. It becomes part of the
address of everything you ever put on GitHub:

```text
https://github.com/YOUR-USERNAME/your-project
https://YOUR-USERNAME.github.io/your-project
```

You can rename yourself later, but the clean-up is worse than it sounds. GitHub
does redirect links to your *repositories* to the new name. It does **not**
redirect your profile page — `github.com/old-name` starts returning "404 not
found" straight away — and the same goes for any gists (single-file snippets)
you'd shared. Worse, those repository redirects stop working the moment somebody
else claims your old username and creates a repository with the same name, which
they are free to do from the day you release it. Your GitHub Pages address is
built from your username too, so that moves with it. Which is to say: pick
something you'd be comfortable putting on a CV, lowercase, hyphens rather than
underscores if you need a separator, no birth year.

> **What going wrong looks like:** *"Username is not available."* Someone has it.
> GitHub has been around since 2008 and the short names went early. Add a word
> rather than a number — `jane-builds` reads better than `jane1987` and doesn't
> tell strangers your age.

### 2. Verify your email

GitHub sends a code to the address you gave. Type it in.

> **What going wrong looks like:** you can log in, but creating a repository or
> pushing code fails and a yellow banner says *"Please verify your email
> address."* Check spam, then use **Settings → Emails → Resend verification
> email**. An unverified account is a half-account.

### 3. Turn on two-factor authentication

**2FA (two-factor authentication)** means logging in needs two things: your
password, and a six-digit code that changes every thirty seconds. Knowing the
password is no longer enough, so a leaked or guessed password on its own can't
get anyone in.

GitHub will make you do this sooner or later anyway. It **requires 2FA** from
accounts that have done anything the wider ecosystem leans on — published a
package or an app, created a release, own an organisation, or contributed to a
repository a lot of other software depends on. If you land in one of those
groups, GitHub emails you, gives you 45 days to enrol plus a short grace period,
and then stops you using github.com until you do. Ninety seconds now beats
finding out mid-deploy.

Go to **Settings → Password and authentication → Two-factor authentication** and
choose the **authenticator app** option, not SMS. An authenticator app is a small
app that generates those six-digit codes offline — 1Password and Bitwarden both
do it, as do Google Authenticator, Authy and your iPhone's built-in Passwords
app. SMS is weaker: phone numbers can be stolen by someone talking your mobile
provider into moving your number to their SIM.

GitHub shows a QR code. Scan it with the app, type the six digits it shows back,
and you're enrolled.

### 4. Save the recovery codes — properly

Immediately after enrolling, GitHub shows you about sixteen **recovery codes**:
one-time strings that get you in when you don't have your phone. It will offer to
download them as a text file. Do that, and *also* paste them into your password
manager.

This is the sentence to take seriously: **if you lose your phone and you don't
have your recovery codes, you have lost the account.** GitHub's account recovery
for a 2FA lockout is deliberately hard, because an easy recovery route is just a
second, weaker front door. There is a good chance you will not get back in.

| Where to keep them | Verdict |
|---|---|
| Password manager entry | Yes |
| Printed and in a drawer | Yes |
| A note on the same phone that has the authenticator | No — that's one thing, not two |
| Screenshot in your camera roll | No — it syncs to everything and lives forever |
| Email to yourself | Only if that email account itself has 2FA on |

### 5. Personal account or organisation?

GitHub offers two kinds of account and the sign-up flow may nudge you at the
second one.

| | **Personal account** | **Organisation** |
|---|---|---|
| Owned by | You | A group; you're an owner of it |
| Repos live at | `github.com/you/project` | `github.com/org-name/project` |
| Members | Just you | Several people with roles and permissions |
| Extra setup | None | Billing, membership, permission policies |

**You want a personal account.** An organisation is for when several people need
different levels of access to the same code — it's a permissions system, and
right now you have nobody to permit. You can create an organisation later and
*move* a repository into it in a few clicks, with GitHub redirecting the old
address. Nothing is lost by starting personal.

---

## Cloudflare — Track A

Cloudflare is where [Track A](10-cloudflare.md) buys your domain, runs your DNS
and hosts your site. One account covers all three layers, which is most of why
Track A is shorter.

### Signing up

Go to [dash.cloudflare.com/sign-up](https://dash.cloudflare.com/sign-up). Email
and password, then verify the email. **No card is asked for, and none is needed**
until the moment you buy a domain.

The **dashboard** is the web page you land on after logging in — Cloudflare's
control panel, where your domains, DNS records and sites are listed and edited.
"Console" and "dashboard" mean the same kind of thing across these providers;
Cloudflare says dashboard, AWS says console.

Right now the dashboard will be empty and will invite you to "Add a site". Don't.
Track A tells you when, and adding a site before you own the domain just creates
a half-configured **zone** — Cloudflare's word for one domain and all the
settings attached to it — that you'll have to delete again.

### The free plan is a product, not a trial

This trips people up, because most free things online are a countdown. Cloudflare's
free plan has no end date, no card on file and no "your trial expires in 14 days"
email coming. It is how the overwhelming majority of Cloudflare's users use
Cloudflare, and it includes DNS, the HTTPS certificate that puts the padlock in
the browser's address bar, and **Cloudflare Pages** — their hosting for sites
built straight out of a repository.

The limits are on *scale* — how many requests, how many builds, how big — not on
time. At personal-project traffic you will not approach them, and if you somehow
do, Cloudflare's usual behaviour is to stop serving rather than to bill you. That
is precisely the bill-shock trade in [the chooser](00-start-here.md): Track A
fails by stopping, Track B fails by charging.

Check the current limits rather than trusting this paragraph:
[cloudflare.com/plans](https://www.cloudflare.com/plans/).

### Turn on 2FA before you buy anything

Click your profile icon, top right → **My Profile** → the **Authentication**
tab → **Two-Factor Authentication**. Same as GitHub: use an authenticator app,
and save the codes it gives you — Cloudflare calls them **backup codes** rather
than recovery codes — somewhere that isn't your phone.

Do it *now*, before there's a domain in the account. Once you've bought a domain,
this account controls a thing you own — someone with access to it can move your
domain elsewhere or repoint your site. While you're here, make sure the
verification email actually got clicked: Cloudflare requires a verified account
email address before it will let you register or transfer a domain, and finding
that out mid-purchase is annoying.

> **What going wrong looks like:** you enrol, and the first code is rejected as
> invalid. Nine times in ten the clock on your phone has drifted. Turn on
> automatic time-setting in your phone's date-and-time settings and try again —
> these codes are derived from the current time, so a phone that's forty seconds
> out generates the wrong number.

---

## AWS — Track B, and the one with teeth

[Track B](20-aws.md) runs on AWS. It's the stack a very large share of the
industry uses, and it's worth learning. It is also the only account on this page
that can produce a bill large enough to matter, so this section is longer and
front-loads the protections.

None of what follows is meant to frighten you off AWS. It's meant to get three
specific things switched on in the first twenty minutes, after which the account
is about as dangerous as any other.

### Signing up

Go to [portal.aws.amazon.com/billing/signup](https://portal.aws.amazon.com/billing/signup).
You'll need:

- An email address, which becomes the **root user** identity (see below).
- An account name — a label for your own reference. "Jane's projects" is fine.
- **A payment card.** Not optional, and it's asked for even if you go on to pick
  the plan that can't bill you — AWS uses it to verify you're a real person. AWS
  places a small temporary authorisation charge on it, typically around a pound
  or a dollar, which is reversed. Debit cards usually work; prepaid cards usually
  don't.
- **A phone number for verification.** AWS calls or texts you a code. You type it
  in, or key it into the phone keypad when the automated call asks.
- A support plan. Choose **Basic**, the free one. The paid ones are for companies
  with an outage budget.
- **A plan: free or paid.** New accounts choose. The **free plan** hands you
  sign-up credit to spend and *cannot bill you* — but it expires six months after
  you open the account, or when the credit runs out, and then the account closes
  unless you upgrade. The **paid plan** is ordinary pay-as-you-go, with your
  credit spent first. Start on free;
  [the free tier section below](#the-aws-free-tier-honestly) explains what
  happens next, and why a site you intend to keep online ends up on paid.

> **What going wrong looks like, and it's common:**
>
> | Symptom | Cause | What to do |
> |---|---|---|
> | Card rejected at sign-up | Prepaid/virtual card, or your bank blocked an unfamiliar foreign authorisation | Use a normal debit or credit card; approve the charge in your banking app if it prompts |
> | Phone verification loops or never arrives | Internet phone numbers — Google Voice, Skype and the like — are frequently rejected | Use a real mobile number; try the automated-call option instead of SMS |
> | You sign in and everything says *"Your account is being activated"* | Normal — AWS verifies new accounts | Usually minutes, occasionally a few hours. Wait. If it's still saying it the next day, contact AWS support, which is free for account issues |

### The root account, plainly

The email address you signed up with is the **root user**. It is the master key
to the account. It is not "the admin user" or "the first user" — it sits outside
the normal permission system entirely, and:

- It can do **anything**, and no permission setting can restrict it.
- It can **close the account**.
- It can **spend without limit**. Once the account is on the paid plan there is
  no built-in cap, no prepaid balance and no "you have used your allowance" wall.
  AWS bills you afterwards for whatever got used.

That last point is the one that produces the horror stories. So there are three
things to do in order, before you build anything, and this is genuinely the order
they should happen in.

### 1. Turn on MFA for root — immediately

**MFA (multi-factor authentication)** is AWS's name for the same thing GitHub
calls 2FA: password plus a rotating six-digit code.

Sign in as root → click your account name (top right) → **Security credentials**
→ **Multi-factor authentication (MFA)** → **Assign MFA device** → **Authenticator
app**. Scan the QR code, enter two consecutive codes, done. Save the recovery
path: for AWS that means keeping access to the sign-up email and phone number,
because that's how root recovery works.

Do this first because everything else you're about to set up is worthless if
someone can log in as root and switch it off.

### 2. Set a budget alarm — before you build anything

A **budget alarm** emails you when your spend crosses a line you set. It doesn't
stop the spending; it tells you. That warning is the difference between noticing
on day one and noticing on the statement.

In the AWS console, go to **Billing and Cost Management → Budgets → Create
budget**. Two settings matter:

- **Zero-spend budget** — AWS offers this as a template. It emails you the moment
  your bill exceeds essentially nothing. On an account that's meant to be running
  a personal site for pennies, that's the alarm you want.
- **A ceiling you'd actually notice** — a second budget at a number that would
  annoy you. Pick something real: if £20 in a month would make you sit up, set
  £20.

Then go to **Billing and Cost Management → Billing preferences → Alert
preferences → Edit** and tick both **Receive AWS Free Tier alerts** and
**Receive CloudWatch billing alerts**. Check the email address on it is one you
read.

> An alarm you never see is not an alarm. Send it to your everyday inbox, not to
> an address you only check when something has already gone wrong.

On a brand-new free-plan account this can feel premature — you can't be billed
yet. Do it anyway. The day you upgrade to the paid plan is the day it starts
mattering, and that is not a day you'll remember to come back here. (AWS has also
been handing out sign-up credit for completing a few starter activities, one of
which is creating a budget. Worth checking whether that still applies when you
sign up.)

Track B repeats this with exact clicks at the point you'd do it. It's here as
well because it belongs to *account setup*, not to deploying, and because doing
it later means doing it after the risk started.

### 3. Never create an access key for the root user

An **access key** is a pair of strings — an ID beginning `AKIA…` and a secret —
that lets a program act as you, without a password and without MFA. It's what
your laptop — and the automation that publishes your site — use to talk to AWS.

A root access key is a permanent, unrestricted, unrevocable-in-practice master
credential in a text file. AWS's own console will warn you if you try to make
one. Don't. If you already have one from an earlier experiment, go to **Security
credentials** and delete it now.

### What an IAM user is, and why you make one

**IAM (Identity and Access Management)** is AWS's permission system. An **IAM
user** is an identity inside your account that you create, and that you can give
exactly the permissions it needs — and no more.

You make one because of what happens when something goes wrong:

| | Leaked root key | Leaked IAM key with limited permissions |
|---|---|---|
| What the attacker can do | Everything, in every AWS region — AWS runs data centres all over the world and one key works in all of them — forever | Only what you granted |
| How you stop it | Effectively: close the account | Delete the key. Thirty seconds |
| Blast radius | The whole account and the card behind it | The one service you scoped it to |

So: root logs in once, creates an IAM user, and then you use the IAM user for
day-to-day work. Root gets used for a handful of things only it can do — closing
the account, changing the payment method — and otherwise stays logged out.

[Track B](20-aws.md) walks through creating this and sets it up so that your
deploys don't use a long-lived key at all, using a mechanism where GitHub proves
its identity to AWS per run. Here you only need the concept.

> AWS also offers **IAM Identity Center** as its current recommendation for human
> sign-in. It's better and it's more setup. If Track B or your workplace points
> you at it, follow them; the reasoning on this page is unchanged.

### The honest risk, stated once

A leaked AWS key is not a theoretical problem with a slow fuse. Public GitHub
commits are scraped continuously by automated systems, and a key pushed to a
public repository is typically found and used **within minutes**. The standard
use is spinning up large numbers of expensive machines — the sort rented by the
hour for graphics and AI work — in every region, to mine cryptocurrency. The
resulting bills routinely reach **five figures** before anyone notices, because
nothing in AWS stops them.

AWS often waives these bills for genuine first-time accidents, and there's a
support process for it. Often is not always, and the days spent arguing are
their own punishment.

One softener, and only one: while your account is still on the **free plan** the
damage is capped, because that plan can't bill you at all. The moment you upgrade
to the paid plan — which anything you intend to leave running eventually does —
the cap is gone and the paragraph above applies in full.

This is exactly why this guide puts MFA and the budget alarm before the first
line of infrastructure, and why [Get it on GitHub](05-github.md) makes you scan
for credentials before anything goes public. Both of those are cheap. The
alternative is not.

If it happens anyway: [the troubleshooting page](90-troubleshooting.md) has the
order of operations, and the short version is *delete the key first, ask
questions second*.

### The AWS free tier, honestly

AWS advertises a free tier. It is real, and it was rebuilt in July 2025 — so most
of the advice you'll find online, and quite possibly what a colleague remembers,
describes a version that no longer applies to a new account. What a new account
gets now:

| Kind | What it means | Watch out for |
|---|---|---|
| **The free plan** | Credit granted at sign-up, plus some more for completing starter activities. On this plan AWS does not bill you at all | It ends six months after you open the account, or when the credit runs out, whichever comes first — and then the account *closes* unless you upgrade to the paid plan. AWS gives you a window, currently about 90 days, to reopen it by upgrading |
| **The paid plan** | Ordinary pay-as-you-go. Credit is spent first, then your card | No cap, no wall, no confirmation dialog. This is the plan anything you intend to keep online ends up on |
| **Always free** | Thirty-odd services with a permanent monthly free allowance, on either plan | The allowance is per month, and only for the exact configuration named |
| **Short-term trials** | One-off trials on particular services | Expire on their own schedule |

The thing to diarise: if your site is live on a free-plan account when that
window shuts, the account closing takes the site with it. If the project is meant
to outlive the free plan, upgrade *before* the deadline rather than after — with
the budget alarm from step 2 already in place, so the first paid month can't
surprise you.

If your account was created before 15 July 2025 you're on the older scheme
instead — 12 months of free usage on some services from the day you signed up,
plus always-free and trials. Month 13 arrives silently there; nothing warns you
on the day it ends.

And the part that matters most, on either scheme:

**Once you're on the paid plan, nothing stops charges.** Cross the line — by a
lot or by a little, by accident or on purpose — and AWS bills you for the excess
without asking. Not every service has a free allowance at all: the DNS **hosted
zone** in Track B (AWS's per-domain DNS setting, billed monthly) is a small charge
from day one.

So the alarm is the real protection, not the free tier. The free tier decides
what you pay; the alarm decides how fast you find out.

AWS has restructured this before and will again, so don't take numbers or
timescales from any guide, including this one. The live page:
[aws.amazon.com/free](https://aws.amazon.com/free/).

---

## Anthropic — only if your app calls Claude

Skip this section unless your deployed project itself sends requests to Claude —
a "generate with AI" button, a chat feature, a page that summarises whatever a
visitor pastes into it. **Using Claude Code to build the project doesn't count**;
that's you, on your machine.

### The distinction people get wrong

These are two separate products, with separate billing, and one does not include
the other:

| | **Claude.ai subscription** (Free / Pro / Max) | **API credit** |
|---|---|---|
| What it is | A monthly subscription for a person | Pay-as-you-go for a program |
| What it buys | The chat app at claude.ai, and Claude Code | Requests from your code to the API |
| How it's charged | Flat monthly fee | Per request, by amount of text in and out |
| Where you manage it | claude.ai | The developer console at [platform.claude.com](https://platform.claude.com) (the old `console.anthropic.com` address redirects there) |
| Does your deployed app use it? | **No** | **Yes** |

Your Pro subscription does not give your website any API access. Not a little,
not a reduced rate — they're separate accounts on separate balances. This catches
people constantly, and it catches them at the worst moment: after deploying,
when the live site is the thing that's broken.

> **What going wrong looks like:** your site loads fine, but the AI feature fails
> and the response from Anthropic says something close to *"Your credit balance
> is too low to access the Anthropic API."* That's not a bug in your code. That's
> an empty API balance. Add credit in the console and it starts working.

### What to do

1. Sign up at [platform.claude.com](https://platform.claude.com). Verify the
   email. If you signed up with an email and password rather than a Google
   account, turn on 2FA while you're in there.
2. Under **Settings → Billing**, add a payment method and **buy a small amount of
   credit to start**. Credit is prepaid — you top up a balance and requests draw
   it down — which is a much friendlier failure mode than AWS's: when it runs out,
   the API simply stops answering rather than billing you onwards. Two things to
   know: credits expire a year after you buy them, and purchases are
   non-refundable, so buy small.
3. Leave **auto-reload** off to begin with, and set a **spend limit**: in the
   Console that lives under **Settings → Workspaces → your workspace → Limits**,
   where you can also **Add notification** to get an email when spend crosses a
   number you pick. Same reasoning as the AWS alarm — the realistic risk here is
   a loop in your own code, not an attacker.
4. Don't create the API key yet. Keys and where they're allowed to live are
   [the next page](03-keys-and-access.md), and creating one before you know where
   it's going is how it ends up pasted into a file that gets committed.

Current API pricing, which is per-model and changes:
[claude.com/pricing](https://claude.com/pricing).

> Building on OpenAI, Google or another provider instead? The shape is identical:
> a console account, a prepaid or metered balance separate from any consumer
> subscription, a spend limit, and a key you handle carefully. Everything on
> [03](03-keys-and-access.md) applies unchanged.

---

## Which do I actually need?

Keyed to the shapes in [Start here](00-start-here.md).

**Shape 1 — a static site** (HTML/CSS/JS, or a framework that builds to a folder)

- GitHub — yes
- Cloudflare (Track A) *or* AWS (Track B) — one of them, not both
- Anthropic — no

**Shape 2 — a site with a bit of backend** — backend meaning code that runs on a
server somewhere rather than in the visitor's browser (a form that saves, an API
call you're hiding, a login)

- GitHub — yes
- Cloudflare *or* AWS — one of them
- Anthropic — only if the backend bit calls Claude
- Plus, possibly, an account for whatever else the backend talks to: a database
  service like Supabase or Neon, a payments provider like Stripe. Those aren't
  covered here, but the pattern on [03](03-keys-and-access.md) applies to all of
  them

**Shape 3 — something that has to keep running** (a Flask/FastAPI app, a bot, a
scheduled job)

- GitHub — yes
- Cloudflare *or* AWS — yes, for the domain and DNS, even though the hosting
  lives elsewhere
- Plus an account with whichever host you picked from
  [the honest note](00-start-here.md#the-honest-note-about-shape-3) — Fly.io,
  Railway, Render, Hugging Face. They all follow the pattern above: verify email,
  turn on 2FA, set a spend limit if they offer one

Nobody needs both Cloudflare and AWS. If you later want to move, you move — that's
the point of [the three layers](04-three-layers.md), and it doesn't require
starting again.

---

## What each of these costs

Shapes, not quotes. Every figure below moves, which is why each row links to the
page that's actually current.

| Account | Shape of the cost at personal-project scale | Live pricing |
|---|---|---|
| **GitHub** | Free. Unlimited public *and* private repositories; **GitHub Actions** — their automation runner, which is the thing that rebuilds your site when you push — free on public repositories and a monthly allowance on private ones; automatic scanning for leaked keys on public repositories. Paid plans buy team features you don't need yet | [github.com/pricing](https://github.com/pricing) |
| **Cloudflare** | Free plan covers DNS, HTTPS and Pages hosting indefinitely. You pay only for the domain, and as a **registrar** — the company you actually buy the name from, [layer 1](04-three-layers.md#layer-1--the-registrar) — Cloudflare sells at wholesale cost with no markup and no first-year-discount trap | [Plans](https://www.cloudflare.com/plans/) · [Registrar](https://www.cloudflare.com/products/registrar/) |
| **AWS** | A small fixed monthly charge for the DNS hosted zone, plus usage-based storage and traffic charges that round to pennies at low traffic. Call it "less than a coffee a month" — but it is not zero, and it is not capped | [Route 53](https://aws.amazon.com/route53/pricing/) · [S3](https://aws.amazon.com/s3/pricing/) · [CloudFront](https://aws.amazon.com/cloudfront/pricing/) · [Free tier](https://aws.amazon.com/free/) |
| **The domain itself** | The one unavoidable cost, billed yearly. `.com` is stable and boring, which is a feature. Beware **TLDs** — top-level domains, the `.com`/`.io`/`.dev` ending — that are cheap for year one and several times that on renewal. Always check the *renewal* price | Your track's registrar page |
| **Anthropic API** | Per request, by volume of text in and out. A personal site with a handful of users a day is small change; a bug that retries in a loop is not, which is what the spend limit is for | [claude.com/pricing](https://claude.com/pricing) |

The realistic all-in total for a personal project on either track is *the domain,
plus a rounding error* — which is the number in [the README](../README.md). The
difference between the tracks isn't the amount. It's that Track A's free tier
stops when you exceed it, while Track B — once its free plan is behind you —
bills you.

---

## Before you move on

A quick check. You should now have:

- [ ] A password manager, or a deliberate decision about where passwords live
- [ ] GitHub: signed up, email verified, 2FA on, recovery codes saved somewhere
      that is not your phone
- [ ] Track A only — Cloudflare: signed up, email verified, 2FA on
- [ ] Track B only — AWS: signed up, activated, **MFA on root**, **a budget alarm
      that emails an address you read**, no root access key, and you know which
      plan you're on and when the free one runs out
- [ ] Anthropic, if your app calls Claude: signed up, small credit balance, spend
      limit set

If the AWS row has an unticked box, tick it before you go further. Everything
after this page assumes those two protections exist.

---

**Next:** [Keys and access →](03-keys-and-access.md)
