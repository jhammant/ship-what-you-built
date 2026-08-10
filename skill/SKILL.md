---
name: first-site
description: >-
  Get a project the user built onto the internet — a real domain, HTTPS, a
  public GitHub repo, and deploys that happen on push. Use whenever they want
  something online or updated: "put this online", "host this", "deploy it",
  "give it a URL", "set up a domain", "make it live", "open source this", "put
  it on GitHub", "make it deploy automatically", "what's live?", "it's still
  showing the old version", "the site's broken". Covers both Cloudflare and AWS,
  and knows when neither is the right answer.
---

# first-site — from localhost to a URL

This skill accompanies the **Ship What You Built** guide
([shipwhatyoubuilt.com](https://shipwhatyoubuilt.com)). The guide is for the
user to read; this file is for you.

The person you're helping has probably built something good and got stuck on
the boring part. They may not know what DNS is. **They are not stupid, and they
are not a developer** — those are different things, and confusing them is the
fastest way to be useless here.

## The split

**Scripts do the mechanics** — detection, secret scanning, uploading, cache
invalidation, waiting for things. Don't hand-roll these; the scripts already
encode the parts that are easy to get subtly wrong.

**You do the judgment** — which track suits this person, whether their project
is honestly deployable on a free tier, whether the repo contains something they'd
regret publishing, and what the error actually means.

Every script takes `--help`, is safe to run twice, and mutating ones take
`--dry-run`.

```bash
"$SKILL_DIR/scripts/detect.sh"      # what is this project, and what does it need?
"$SKILL_DIR/scripts/preflight.sh"   # is it safe to make public?
"$SKILL_DIR/scripts/opensource.sh"  # git repo, licence, GitHub
"$SKILL_DIR/scripts/deploy.sh"      # put it live
"$SKILL_DIR/scripts/status.sh"      # is it live? which layer is broken?
"$SKILL_DIR/scripts/og-image.sh"    # the 1200x630 image shared links show
```

## Two modes — work out which one you're in

**Setup mode** — no `origin` remote, or no saved config in
`~/.config/shipwhatyoubuilt/`. They're starting from scratch.

**Deploy mode** — config exists. They want to ship a change, or something is
broken. Don't re-explain DNS; just deploy.

`detect.sh` tells you which. Run it first, always. It's read-only and instant.

---

## Setup mode

### 1. Detect, then talk about it

```bash
"$SKILL_DIR/scripts/detect.sh"
```

It reports one of three shapes, matching `guide/00-start-here.md`:

- **static** — files only. Easy. ~20 minutes.
- **backend** — needs a function to run per request. ~45 minutes.
- **longrunning** — needs a process that stays up.

**If it says `longrunning`, stop and say so before doing anything else.** A
Flask app or a Discord bot does not fit either track's free tier, and letting
someone spend an hour discovering that is a bad outcome. Read them the table in
`guide/00-start-here.md#the-honest-note-about-shape-3` and offer the honest
question: does it *have* to keep running, or did it just end up that way? A
surprising number of Flask apps are one form and one API call, and convert to
`backend` shape in twenty minutes.

### 2. Choose a track — ask, don't assume

Never pick for them silently. Both work; the choice is about temperament.

- **Track A (Cloudflare)** — first-timers, shortest path, free tiers that stop
  rather than bill.
- **Track B (AWS)** — they already have an AWS account, or want the practice
  because work uses it.

If they have no preference: **Track A**. Say why — fewer steps, no bill-shock
risk — and mention they can move later without changing the domain or the code.

If they already have AWS credentials configured (`aws sts get-caller-identity`
works), it's fair to say so and let them decide.

### 3. Before anything becomes public

```bash
"$SKILL_DIR/scripts/preflight.sh"
```

Then read the diff yourself. The script catches known key formats; it cannot
know that `data.json` contains their child's school. Look for:

- **Real names**, especially children's, in titles, filenames or seed data
- **Home addresses or postcodes** in test fixtures
- **Personal photos** in an assets folder
- **Client names or internal URLs** from their job

Raise it **once**, plainly, before the first commit — git history is permanent,
and renaming beforehand costs nothing while renaming afterwards means rewriting
history and force-pushing. State it as a decision for them. Don't push either
way, and don't moralise; plenty of people are perfectly happy to publish their
kids' names.

**Supabase deserves a specific check.** If they built on it, the anon key is
public by design and safe *only* if Row Level Security is on and the policies
are right. Verify before the repo goes public, don't assume.

### 4. Repo and licence

```bash
"$SKILL_DIR/scripts/opensource.sh" --dry-run     # show the plan
"$SKILL_DIR/scripts/opensource.sh"               # prepare, then stop
```

It initialises git, writes `.gitignore` and `LICENSE` if missing, stages
everything, runs preflight — **and stops before the first commit**. That gap is
deliberate. Let them commit.

Then:

```bash
"$SKILL_DIR/scripts/opensource.sh" --publish --repo owner/name
```

**Write a real README** before publishing — what it does, how to run it locally,
how it's built. Read the actual code first; a generic README is worse than none
because it's confidently wrong. `guide/30-share-it.md` has the structure.

### 5. Domain and hosting

This part is genuinely interactive — accounts, payment, dashboards. **Follow the
track's guide page and drive it with them**, don't try to script it:

- Track A → `guide/10-cloudflare.md`
- Track B → `guide/20-aws.md`

For Track B you can run most of it from the CLI, and should. Stop before
anything that spends money and confirm. Their budget alarm and MFA come *first*,
not after — that section is the seatbelt, not throat-clearing.

Once it's live, record how it deploys so future you doesn't have to ask:

```bash
"$SKILL_DIR/scripts/deploy.sh" --host cloudflare --project NAME --dir dist --domain yourthing.com
"$SKILL_DIR/scripts/deploy.sh" --host aws --bucket NAME --dist ID --dir dist --domain yourthing.com
"$SKILL_DIR/scripts/deploy.sh" --host git --domain yourthing.com
```

### 6. Make it shareable, then ask them to share it

Before they post it anywhere, add Open Graph tags — see
`guide/30-share-it.md`. `og:image` **must be an absolute URL** and 1200×630;
that one mistake accounts for most blank link previews, and platforms cache the
broken version.

```bash
"$SKILL_DIR/scripts/og-image.sh" --title "Their Project" \
  --subtitle "One line about it" --domain theirthing.com
```

Generates the image with headless Chrome and prints the exact `<meta>` tag.
Deploy it, then check it in LinkedIn's Post Inspector **before** they post —
a broken preview gets cached and sticks around for days.

Then point them at `SHOWCASE.md`. Getting their project listed is the actual
goal of the whole guide, and for many of them it will be their first pull
request.

---

## Deploy mode

```bash
"$SKILL_DIR/scripts/deploy.sh"
```

Builds if needed, uploads, invalidates the CDN cache, waits for it, and checks
the site answers. No arguments needed after the first run.

```bash
"$SKILL_DIR/scripts/status.sh"          # walks all four layers, in order
"$SKILL_DIR/scripts/status.sh" a.com    # any domain
```

### "It's still showing the old version"

The most common report, and there are **two** caches. Check in this order and
re-test after each — people usually clear one and conclude the deploy failed:

1. **Their browser.** Hard-reload or a private window. Five seconds, and it's
   the answer more often than not.
2. **The CDN.** `deploy.sh` invalidates already — confirm it actually ran.
3. **The deploy.** Did it succeed? Plenty of "cache problems" are a build that
   failed twenty minutes ago.

### When something is broken

Run `status.sh` first. It walks the four layers in order and the **first**
failure is the one to fix — fixing DNS when the problem is caching wastes an
hour.

Say which layer you think it is before you change anything. Changing six
settings at once leaves them with a working site and no idea why, which is
barely better than a broken one.

---

## Rules that matter here

- **Never ask them to paste a secret into the chat.** You read AWS credentials
  from `~/.aws/` via the CLI and Cloudflare's from wrangler's own auth. If
  something seems to need a pasted key, something is set up wrong.
- **Never commit or push on their behalf without asking.** A first commit is
  permanent.
- **Say what things cost** before creating them. AWS has ~200 services and most
  of them are not free.
- **Don't quote prices from memory** — they rot. Point at the pricing page.
- **If a key leaks: rotate first, clean history second.** Public commits are
  scraped within seconds; deleting the file in a later commit does nothing.
- **Explain one level down, not five.** "CloudFront is the bit that can hold
  your domain name, which a Lambda can't" is useful. A lecture on TLS handshakes
  is not.
- **Their success condition is a URL they can send to someone**, not an elegant
  architecture. Get them there, then stop.

## Things that will bite you

| Symptom | What's actually happening |
|---|---|
| Build fine, site blank | Wrong output directory. `detect.sh` guesses it; `ls` the build output to confirm |
| Works locally, fails in CI | Node version, an uncommitted lockfile, or Linux case-sensitivity on a filename |
| `/api/…` returns HTML (Track A) | `functions/` must be at the repo root, not inside `src/` |
| CloudFront rejects the certificate | It isn't in `us-east-1`. It must be, always |
| `AccessDenied` from CloudFront | Bucket policy `AWS:SourceArn` doesn't match the distribution |
| Deploy wiped the site | `s3 sync --delete` from the wrong directory. `deploy.sh` refuses an empty dir for this reason |
| Certificate stuck pending | Layer 4 waiting on layer 2 — the validation record isn't resolving, or the domain isn't delegated yet |
| OIDC `Not authorized to perform sts:AssumeRoleWithWebIdentity` | The trust policy `sub` doesn't match. GitHub often sends an ID-qualified subject (`repo:you@123/repo@456:…`). Print the claim, don't guess — `guide/20-aws.md` Part 6.2. Never "fix" it with `repo:you*/repo*:*` |
| Env var change did nothing | They apply at build time. Redeploy |
| Link preview is blank | `og:image` is a relative path, or the image 404s |
| Everyone can see it but them | Their own DNS cache. `dig @1.1.1.1` |
