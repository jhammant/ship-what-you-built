# Ship What You Built

You built something with an AI coding agent. It works. You're proud of it.

It runs on your laptop, at an address like `http://localhost:3000`, and that is
where it has been sitting for three weeks — because the gap between *"it works"*
and *"other people can use it"* turns out to be full of words nobody explained:
nameservers, DNS records, certificates, CI, OIDC, buckets.

This repository closes that gap. At the end you will have:

- a **real domain** you own, e.g. `yourthing.com`
- your project **live on it**, over HTTPS
- the code **on GitHub**, public, with a licence and a README
- **automatic deploys** — you change a file, push, and the live site updates
- a total bill of roughly **£10–20 a year**, almost all of it the domain

It comes in two halves. A **guide** you read (or hand to Claude Code and let it
drive), and a **skill** that turns the fiddly parts into one-liners you don't
have to memorise.

**[Read it on the web →](https://shipwhatyoubuilt.com/guide/)** · **[Start here →](guide/02-start-here.md)** · **[See what people have shipped →](SHOWCASE.md)**

---

## Who this is for

- You've built something and can't get it online.
- You've never made a GitHub repository, or you made one once and it scared you.
- You've heard AWS can produce a five-figure bill and would like to not do that.
- You don't want to learn DevOps. You want your thing to have a URL.

You do **not** need to be a developer. You need a laptop, a card for the domain,
and about an hour.

## The two tracks

There is no single right answer, so the guide gives you two complete ones. Pick
at the top and follow it end to end — you never have to mix them.

|  | **Track A — Cloudflare** | **Track B — AWS** |
|---|---|---|
| Best when | This is your first deploy | You already use AWS, or need it for work |
| Time | ~20 min static, ~45 min with a backend | ~90 min |
| Standing cost | Domain only | Domain + ~$0.50/month for the DNS zone |
| Bill-shock risk | Low — free tiers stop rather than bill | Real — needs a budget alarm before you start |
| Teaches you | The modern default | The stack most companies actually run |

Both tracks reach the same place: a domain, HTTPS, and pushes that deploy
themselves. **[The chooser walks you through it →](guide/02-start-here.md)**

## The guide

| Page | What it covers |
|---|---|
| [00 — Get an AI coding agent](guide/00-install-claude-code.md) | Install Claude Code (or Codex), and do one small thing with it |
| [01 — Find an idea](guide/01-find-an-idea.md) | What to actually build, and how to cut it down to finishable |
| [02 — Start here](guide/02-start-here.md) | What did you build, and which track fits it |
| [03 — Your machine](guide/03-your-machine.md) | Terminal and tools, with a proper Windows/WSL walkthrough |
| [04 — The accounts you need](guide/04-accounts.md) | GitHub, Cloudflare, AWS, Anthropic — and what each costs |
| [05 — Keys and access](guide/05-keys-and-access.md) | API keys, and how to give Claude access without pasting secrets |
| [06 — The four layers](guide/06-four-layers.md) | Registrar vs DNS vs hosting vs certificate — the model that makes everything obvious |
| [07 — Get it on GitHub](guide/07-github.md) | Your code in a repo, safely, without leaking a key |
| [08 — Let Claude drive](guide/08-let-claude-drive.md) | **The recommended path** — accounts, authorise the tools, hand over |
| [10 — Track A: Cloudflare](guide/10-cloudflare.md) | Domain, Pages, Workers, custom domain, auto-deploy |
| [20 — Track B: AWS](guide/20-aws.md) | Account safety, S3, CloudFront, Route 53, Lambda, OIDC deploys |
| [30 — Share it](guide/30-share-it.md) | Link previews, a README worth reading, and the showcase |
| [40 — Make a launch video](guide/40-launch-video.md) | Remotion, rendered from code, regenerable |
| [90 — When it breaks](guide/90-troubleshooting.md) | Symptom → cause, for both tracks |
| [99 — Glossary](guide/99-glossary.md) | Every term the guide uses, explained |

Every page is written to be read **by you or by Claude Code**. Drop into the
folder where your project lives, open Claude Code, and say:

> Read `guide/02-start-here.md` and walk me through it.

It will run the commands, explain what it's doing, and stop when it needs a
decision from you.

## The skill

The skill teaches Claude Code how your deploy works, so that after setup you can
stop thinking about any of this:

> Deploy it
>
> What's live right now?
>
> It's still showing the old version
>
> Put it on a subdomain

Install it:

```bash
git clone https://github.com/jhammant/ship-what-you-built.git
mkdir -p ~/.claude/skills
cp -r ship-what-you-built/skill ~/.claude/skills/first-site
```

Then, in the folder where your project lives, just talk to Claude Code. The
skill has two modes: **setup** the first time (repo, domain, deploys) and
**deploy** every time after. It works out which one you need.

Underneath are six small scripts you can also run directly. Each takes `--help`,
is safe to run twice, and the ones that change things take `--dry-run`:

| Script | What it does |
|---|---|
| `detect.sh` | Works out what you built, its build command and output folder |
| `preflight.sh` | Scans for credentials and mistakes **before** the repo goes public |
| `opensource.sh` | git repo, `.gitignore`, licence, GitHub — stopping before the first commit |
| `deploy.sh` | Build, upload, clear the CDN cache, confirm it's live |
| `status.sh` | Walks all four layers and tells you which one is broken |
| `og-image.sh` | Makes the 1200×630 image that shared links show |

Full details: [`skill/SKILL.md`](skill/SKILL.md).

## Show us what you shipped

This is the part that matters. When your thing is live, **add it to
[SHOWCASE.md](SHOWCASE.md)** — one line, your URL, what it does.

It takes two minutes, it's done entirely in the GitHub web interface, and it
means the first open-source contribution you ever make is to a project about
making your first open-source contribution. [How to do it →](CONTRIBUTING.md)

## A note on prices

Every figure in this guide is a **shape, not a quote**. Cloud pricing and free
tiers change, and a guide that hardcodes numbers is a guide that lies to you
eighteen months from now. Each track links to the live pricing page — check it,
and if you find something out of date, [open an issue](../../issues).

## Licence

[MIT](LICENSE). Use it, fork it, teach from it, translate it. If you run a
workshop from this, I'd love to hear about it.
