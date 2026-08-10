# Get it on GitHub

Both tracks deploy **from a GitHub repository**. That's the modern shape: your
repo is the source of truth, and pushing to it is what makes the live site
change. So this comes first.

It's also where you find out whether you're about to publish an API key in front
of the entire internet, which is a much better thing to discover now than in an
hour.

> **Fast lane:** already have this project in a repo with a `.gitignore` you
> trust? Jump to [What counts as a secret](#3-what-counts-as-a-secret) — read that
> section, run the scan, then go to your track.

---

## 1. Install the two tools

```bash
# macOS
brew install git gh

# Windows
winget install Git.Git GitHub.cli

# Debian/Ubuntu
sudo apt install git && \
  (type -p curl >/dev/null || sudo apt install curl) && \
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null && \
  sudo apt update && sudo apt install gh
```

`git` tracks your changes. `gh` is GitHub's command-line tool — it saves you a
lot of clicking, and it handles login properly so you never deal with personal
access tokens.

```bash
gh auth login
```

Choose **GitHub.com** → **HTTPS** → **Login with a web browser**. It prints a
code, opens your browser, you paste the code. Done — you're authenticated for
both `git` and `gh` from now on.

---

## 2. Write `.gitignore` BEFORE your first commit

This is the single most important instruction on this page, and the ordering is
not negotiable.

Git remembers everything. If you commit a file containing a password and delete
it in the next commit, **the password is still in the repository forever** — in
the history, fetchable by anyone, indexed by bots. Deleting it later does not
help. Not committing it in the first place is the only clean answer.

Create a file called `.gitignore` in your project folder:

```gitignore
# Secrets — never commit these
.env
.env.*
!.env.example
*.pem
*.key
credentials.json
secrets.*

# Dependencies — huge, and rebuildable from a lockfile
node_modules/
venv/
.venv/
__pycache__/

# Build output — regenerated on every deploy
dist/
build/
.next/
.cache/

# Local noise
.DS_Store
Thumbs.db
*.log
.vscode/
.idea/

# Local databases
*.sqlite
*.sqlite3
*.db
```

Trim it to what applies. Leaving extra lines in costs nothing.

> **If you've already committed** and you're not sure what went in, don't panic
> and don't push yet. Skip to
> [If you've already leaked something](#6-if-youve-already-leaked-something).

### Where secrets go instead

Not in the code. Ever. The pattern is:

1. Real values live in `.env` — which `.gitignore` excludes.
2. A file called `.env.example` **is** committed, listing the *names* with fake
   values, so anyone cloning your repo knows what to fill in:

   ```bash
   OPENAI_API_KEY=sk-replace-me
   DATABASE_URL=postgres://user:pass@localhost:5432/dev
   ```

3. In production, the real values are set in your host's dashboard as
   environment variables. Both tracks cover exactly where.

---

## 3. What counts as a secret

People either publish keys by accident or get so nervous they never publish
anything. Here's the actual line:

| Thing | Safe to publish? | Why |
|---|---|---|
| Your source code | **Yes** | That's the point |
| Your domain name | **Yes** | It's in public DNS already |
| An S3 bucket name | **Yes** | Usually visible in URLs anyway |
| A CloudFront distribution ID | **Yes** | Useless without credentials |
| A **publishable**/anon key (Stripe `pk_`, Supabase anon) | **Yes** | Designed to sit in browser code — but *only* if your access rules are set up |
| Your AWS **account ID** | Prefer not | Not a credential, but it's reconnaissance. Put it in a GitHub secret |
| An AWS access key (`AKIA…`) | **NEVER** | Full control of your account |
| A Stripe secret key (`sk_`) | **NEVER** | Full control of your money |
| A `.env` file | **NEVER** | That's what it's for |
| A private key / `.pem` | **NEVER** | The name is a hint |

**The Supabase row deserves a flag.** The anon key is genuinely designed to be
public — but it is only safe if Row Level Security is switched on and your
policies are right. Publishing an anon key against a table with RLS disabled
hands the world your database. If you built with Supabase and don't know the
answer, check before you go public:

> Check every table in my Supabase project for whether RLS is enabled and what
> the policies actually allow. Assume the anon key is public knowledge. Tell me
> what an anonymous user could read or write.

### Scan before you publish

Run these in your project folder. They take seconds.

```bash
# Anything that looks like a key, in your tracked files
git grep -nE '(sk-[A-Za-z0-9]{16,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----)'

# Is anything ignore-worthy accidentally tracked?
git ls-files | grep -Ei '(^|/)\.env|\.pem$|\.key$|credentials'

# What is git actually about to include?
git status --short
```

No output from the first two is what you want. And ask Claude Code, which is
better at this than a regex:

> Review everything staged for commit and flag anything that looks like a
> credential, a personal detail, or something I'd regret publishing. Be
> paranoid — this repo is about to be public and permanent.

---

## 4. One thing to decide before you go public

A public repo is permanent and searchable. The code is fine — that's why you're
here. It's the *incidental* content that people regret:

- **Real names**, especially children's, in file names, app titles or seed data
- **Home addresses** or postcodes in test fixtures
- **Photos** of family in an `assets/` folder
- **Personal email addresses** in commit history (`git config user.email`)
- **Internal URLs** or client names from work

None of these are security problems. They're permanence problems: renaming
*before* the first commit costs nothing, and renaming *after* means rewriting
history and force-pushing.

So take one minute now and look. If something gives you pause, change it now.
If you'd rather keep your email out of commits, GitHub gives you a no-reply
address:

```bash
# Settings → Emails → "Keep my email addresses private" gives you this
git config --global user.email "12345678+yourname@users.noreply.github.com"
```

None of this is a reason not to publish. It's a two-minute check that means you
never have to unpublish.

---

## 5. Make the repository

```bash
cd /path/to/your-project

git init
git add .
git status          # <- look at this list. Actually look at it.
git commit -m "Initial commit"
```

Then create it on GitHub and push, in one command:

```bash
gh repo create your-project-name --public --source=. --remote=origin --push
```

- `--public` — swap for `--private` if you want to think about it. You can flip
  it later in Settings; going private→public is easy, public→private doesn't
  un-publish what people already cloned.
- `--source=.` — use this folder.
- `--push` — push straight away.

### Turn on the safety nets

Free on public repos, and worth thirty seconds:

```bash
gh repo edit --enable-secret-scanning --enable-secret-scanning-push-protection
```

**Push protection** is the good one: it blocks a `git push` that contains
something matching a known key format, *before* it reaches GitHub. It has saved
an enormous number of people from a very bad afternoon.

### Add a licence

Without one, "public" legally means "you may look at it and nothing else" — no
one can use, fork or build on your work. If you want people to actually use it,
say so:

```bash
gh repo edit --add-topic open-source
curl -sL https://raw.githubusercontent.com/licenses/license-templates/master/templates/mit.txt \
  -o LICENSE
```

Then edit the year and your name in `LICENSE`. **MIT** is the standard "do what
you like, don't sue me" choice and is what most personal projects use. If you'd
rather anyone who modifies your code has to share their changes, use **GPL-3.0**
instead. If you genuinely don't care, **Unlicense**. Any of the three is a
better answer than none.

---

## 6. If you've already leaked something

It happens. The order matters enormously:

1. **Rotate the key first.** Go to the provider — AWS, OpenAI, Stripe, whoever —
   delete the exposed key and issue a new one. Do this *before* anything else.
   Public commits are scraped by bots within *seconds*, and an exposed AWS key
   gets used for crypto mining measured in minutes. Once the key is dead, the
   leak is a tidiness problem instead of an emergency.

2. **Then clean the history**, if you want to. Tools:
   [`git-filter-repo`](https://github.com/newren/git-filter-repo) or
   [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/). Both rewrite
   history, which means a force-push and a broken clone for anyone who already
   has one. On a repo nobody has forked, that's painless.

3. **If it was never pushed**, you got away with it — clean the history locally
   and rotate anyway, because "I'm fairly sure it never left my laptop" is not a
   security posture.

**Never** just delete the file and commit. The old commit is still there and
still fetchable.

---

## 7. Let Claude do it

All of the above, as one instruction — in the folder where your project lives:

> Read https://github.com/jhammant/ship-what-you-built/blob/main/guide/02-github.md. Set this project up as a public GitHub repository
> following it exactly: write an appropriate `.gitignore` first, scan for
> secrets and personal details before anything is staged, show me `git status`
> and stop for my approval before the first commit, then create the repo with
> secret scanning and push protection on and add an MIT licence.

The stop-before-the-first-commit part is deliberate. It's the one step in this
whole guide where a mistake is permanent, so it's worth your own eyes.

---

**Next:** pick your track —
[Track A: Cloudflare →](10-cloudflare.md) · [Track B: AWS →](20-aws.md)
