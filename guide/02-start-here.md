# Start here

Two questions, then you're on a track and you can stop making decisions.

---

## First, how much of this do you want to do yourself?

There are three honest answers, and none of them is the wrong one. Pick by how
much you want to understand versus how quickly you want a URL.

| | What you actually do | Time | Pick this if |
|---|---|---|---|
| **Full auto** | Install the skill, paste one paragraph, approve the domain purchase | ~30 min, mostly waiting | You want it live tonight and you'll read the code later |
| **Step by step, with the skill** | Same skill, but it stops at each stage and explains before doing it | ~45 min | You want it live *and* to know what happened |
| **By hand** | Follow the track pages and type every command yourself | 20–90 min | You learn by doing, or you'd rather no agent touched your cloud account |

**All three end in the same place**: your domain, HTTPS, a public repo, and
deploys that happen when you push.

### Full auto

Install the skill, then let it run without stopping to ask about every step:

```bash
git clone https://github.com/jhammant/ship-what-you-built.git
mkdir -p ~/.claude/skills
cp -r ship-what-you-built/skill ~/.claude/skills/first-site
```

Then, in your project folder:

```bash
claude --dangerously-skip-permissions
```

> **Read [what that flag means](00-install-claude-code.md#stop-it-asking-you-about-everything)
> before you use it.** In short: it stops asking about anything at all, so only
> use it in a project folder under `~/dev` that is already a git repository —
> that commit is your undo button. It is still worth watching what scrolls past.

Then say what you want, and answer when it asks:

> Put this online at yourthing.com using AWS. Buy the domain, set up the repo
> and automatic deploys. Ask me before spending money.

### Step by step, with the skill

Same skill, without the flag:

```bash
claude
```

> Read the guide at shipwhatyoubuilt.com and walk me through getting this
> online, one stage at a time. Explain each step before you do it, and stop for
> my approval between stages.

This is the one most people should take. The skill still does the fiddly
mechanics — cache invalidation, certificate validation, the OIDC trust policy —
but you see and approve each stage, so you finish knowing what you own.

### By hand

Skip the skill entirely. [Track A](10-cloudflare.md) and [Track B](20-aws.md)
list every command with an explanation of what it does and what going wrong
looks like. Nothing in this guide requires an agent.

**[The skill lives here](https://github.com/jhammant/ship-what-you-built/tree/main/skill)**
if you want to read it before installing it — it's a markdown file and six
short shell scripts, and reading it first is a reasonable instinct.

---

## Question 1 — What did you build?

Look at the folder your project lives in and find the row that matches. If two
seem to fit, pick the lower one.

### Shape 1 — A static site

**You have:** `.html`, `.css`, `.js` files. Maybe images. You can double-click
the HTML file and it opens in your browser and works.

**Also this shape:** anything with a *build step* that produces a folder of
files — React, Vue, Svelte, Vite, Astro, Eleventy, plain Tailwind. You run
`npm run build`, you get a `dist/` or `build/` folder, and that folder is the
whole site.

**Tell-tale:** nothing on your machine has to stay running for the site to work.

> **Time:** ~20 minutes on Track A, ~90 on Track B
> **Cost:** the domain on Track A; the domain plus ~$0.50/month on Track B

### Shape 2 — A site with a bit of backend

**You have:** a form that saves something, a page that calls an API key you
don't want in the browser, a "generate with AI" button, a login, a small
database.

**Tell-tale:** parts of it work if you open the files directly, but the
interesting bits need a server to answer.

> **Time:** ~45 minutes on Track A, ~90 on Track B
> **Cost:** the domain on Track A; the domain plus ~$0.50/month on Track B

### Shape 3 — Something that has to keep running

**You have:** a Python Flask/FastAPI/Streamlit app, a Discord bot, a job that
runs on a schedule, a websocket server, a game server, something holding a model
in memory, or a database you administer yourself.

**Tell-tale:** you start it with a command, and you have to *leave that command
running* or it stops working.

> **Read [the honest note](#the-honest-note-about-shape-3) below before you pick a track.**

---

## Question 2 — Which track?

Both tracks get you to the same finish line. Pick on temperament, not
technology.

### Take Track A (Cloudflare) if…

- This is your first time deploying anything.
- You want the shortest path from here to a working URL.
- You'd rather a free tier **stopped working** than quietly billed you.
- You don't already have a cloud account you're attached to.

**[→ Track A: Cloudflare](10-cloudflare.md)**

### Take Track B (AWS) if…

- You already have an AWS account, or your company uses AWS and you want the
  practice.
- You want to learn the stack that a very large share of the industry runs on.
- You're comfortable setting up a budget alarm and turning on MFA before you
  start, because the failure mode here is financial and it is real.

**[→ Track B: AWS](20-aws.md)**

### Genuinely can't decide?

Take Track A. You can move to AWS later without buying a new domain or changing
a line of code — that's the whole point of
[the three layers](06-four-layers.md), and it's the next page.

---

## What you need on your machine

Install these once, now, rather than discovering each one missing halfway through
a step. Both tracks use all of them.

```bash
# macOS — installs Homebrew first if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git gh jq awscli

# Debian / Ubuntu
sudo apt update && sudo apt install -y git jq curl zip dnsutils
# gh and awscli have their own installers — see guide/07-github.md
```

| Tool | What it's for | Used in |
|---|---|---|
| `git` | tracks your changes | everywhere |
| `gh` | GitHub from the command line | [02](07-github.md) |
| `curl` | fetching a URL to check it works | everywhere |
| `dig` | asking DNS questions directly | [01](06-four-layers.md), troubleshooting |
| `jq` | reading JSON that AWS commands return | Track B |
| `zip` | packaging a Lambda | Track B, backend only |
| `aws` | the AWS command line | Track B |

`dig` is already on macOS. On Ubuntu it's in `dnsutils`. On Windows, see below.

> ### If you're on Windows, read this first
>
> This guide is written in **bash**, and Track B in particular uses heredocs
> (`cat > file <<EOF`) and single-quoting that **do not work in PowerShell or
> `cmd`**. You have two good options:
>
> 1. **WSL (recommended)** — open PowerShell as administrator and run
>    `wsl --install`. Reboot. You now have a real Ubuntu terminal, and every
>    command in this guide works exactly as written. This is worth twenty minutes.
> 2. **Git Bash** — comes with [Git for Windows](https://gitforwindows.org/).
>    Fine for Track A and for [02](07-github.md). Track B's heredocs mostly work,
>    but path handling occasionally bites.
>
> **Track A works fine either way** and needs far less terminal — most of it is
> a web dashboard. If you're on Windows and want the path of least resistance,
> take Track A.

---

## Before either track: two shared steps

Do these first regardless of track. They're short.

1. **[Understand the three layers](06-four-layers.md)** — ten minutes of
   reading that makes every subsequent step obvious instead of magic. Skip it
   and you will be copying commands you don't understand, which is exactly how
   people end up stuck.

2. **[Get your code on GitHub](07-github.md)** — both tracks deploy *from* a
   GitHub repository. This is also where you find out whether you're about to
   publish an API key, so it comes before anything is public.

> **Already have your project on GitHub with a `.gitignore` you trust?** Skip
> straight to your track. Come back to [02](07-github.md) at the "what counts as
> a secret" section before you make the repo public.

---

## The honest note about Shape 3

If your project has to keep running, **neither track's free tier is designed for
it**, and a guide that pretended otherwise would waste your afternoon.

Here's the real picture:

| What you built | What actually fits |
|---|---|
| Python API (Flask, FastAPI) | A container host — Fly.io, Railway, Render. Or AWS App Runner / Lambda with an adapter. |
| Streamlit / Gradio app | Streamlit Community Cloud or Hugging Face Spaces — both free, both built for exactly this |
| Discord/Telegram bot | A small always-on VM, or Fly.io. It has no web address, so it needs no domain |
| Scheduled job | GitHub Actions on a `schedule:` trigger. Free, and you already have the repo |
| Websockets / game server | Cloudflare Durable Objects (Track A, advanced) or a VM |
| Postgres you manage | Don't. Use Supabase or Neon — the free tiers are generous and backups are somebody else's problem |

**You can still use this guide.** Do [01](06-four-layers.md) and
[02](07-github.md), buy your domain via whichever track you prefer, and then use
that track's *DNS* section to point the domain at whatever host from the table
above you chose. The domain and DNS parts transfer completely. Only the hosting
chapter changes.

And a genuinely useful question to ask first: **does it have to keep running, or
did it just end up that way?** A surprising number of Flask apps are one form
and one API call, and become Shape 2 — deployable on a free tier forever — with
about twenty minutes of help from Claude. It's worth asking:

> This is a Flask app. Look at what it actually does — could it be a static page
> plus one serverless function instead? Show me what would have to change, and be
> honest if the answer is no.

---

**Next:** [Your machine →](03-your-machine.md)
