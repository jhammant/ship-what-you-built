# Track A — Cloudflare

**You'll end with:** your project live on your own domain, over HTTPS, rebuilding
itself every time you push to GitHub.

**Time:** ~20 minutes for a static site, ~45 with a backend.
**Cost:** the domain. Everything else here is free at personal-project scale, and
Cloudflare's free tiers *stop serving* rather than silently billing you.

**Before you start:** [the three layers](01-three-layers.md) and
[your code on GitHub](02-github.md).

> **UI wording moves.** Cloudflare renames menu items a few times a year. If a
> label below doesn't match what you see, search the dashboard for the nearest
> word — the shape of the steps hasn't changed in years even when the names have.

---

## 1. Make an account

[dash.cloudflare.com/sign-up](https://dash.cloudflare.com/sign-up). Email and
password, no card required yet.

**Turn on two-factor now** (top-right menu → **My Profile** → **Authentication**).
This account will shortly control your domain's DNS, which means whoever holds
it can point your name anywhere they like. Two minutes, removes a whole category
of problem.

---

## 2. Get your domain into Cloudflare

Two routes depending on whether you already own one.

### 2a. Buying a new domain here

Dashboard → **Domain Registration** → **Register Domains**. Search, pick, pay.

Cloudflare sells at wholesale cost with no markup and — importantly — **no
renewal jump**. The price you pay in year one is the price in year five. Compare
that against the £1.50-now-£26-later offers elsewhere; over five years the
"cheap" one costs three times as much.

Two things to know:

- A domain bought at Cloudflare **must use Cloudflare's DNS**. That's fine for
  this guide, and you can still host anywhere. It does mean you can't buy here
  and run DNS elsewhere.
- Cloudflare doesn't sell every extension. Notably no `.co.uk` at time of
  writing. If you want one it isn't offering, buy it at Namecheap or Gandi and
  use route 2b.

Registration is instant, and the domain appears in your dashboard already set up.
**Skip to step 3.**

### 2b. You already own a domain elsewhere

You're keeping the registrar and moving only DNS — [layer 2](01-three-layers.md#layer-2--dns).
Nothing is transferred, nothing costs money, and it takes about ten minutes.

1. Dashboard → **Add a domain** → type it → choose the **Free** plan.
2. Cloudflare scans your existing DNS and imports what it finds. **Check the
   imported list against your current provider before continuing** — this is the
   step where people accidentally drop their email. If you receive email at this
   domain, make sure the `MX` records and any `TXT` records starting `v=spf1`,
   plus any `_dmarc` or `_domainkey` records, all came across.
3. Cloudflare gives you two nameservers, like `zoe.ns.cloudflare.com`.
4. Go to your **current registrar**, find *Nameservers* (sometimes under DNS
   settings or "custom DNS"), replace what's there with Cloudflare's two.
5. Wait. Usually 10–60 minutes, occasionally a few hours. Cloudflare emails you.

Check progress yourself rather than refreshing the dashboard:

```bash
dig NS yourthing.com +short
```

When that prints the Cloudflare nameservers, layer 1 has caught up.

---

## 3. Deploy the site

Dashboard → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**.

Authorise GitHub (you can grant access to just this one repository), pick your
repo, and you land on build settings. This is the only screen that needs
thought:

| You built… | Framework preset | Build command | Output directory |
|---|---|---|---|
| Plain HTML/CSS/JS | **None** | *(leave empty)* | `/` |
| Vite / React / Vue / Svelte | the matching one | `npm run build` | `dist` |
| Astro | Astro | `npm run build` | `dist` |
| Next.js (static export) | Next.js (Static HTML Export) | `npm run build` | `out` |
| Eleventy / Hugo / Jekyll | the matching one | its build command | `_site` / `public` |

**Not sure what your output directory is?** Run `npm run build` locally and look
at which folder appears. That's the answer. Or ask:

> Look at my build config and tell me exactly what to put in Cloudflare Pages
> for build command and output directory.

Click **Save and Deploy**. Roughly a minute later you have a live URL like
`your-project.pages.dev`. **Open it.** If it works, layers 3 and 4 are done — the
certificate was issued automatically and you didn't have to think about it.

If the build fails, the log tells you why and it's nearly always one of:
the wrong output directory, a dependency that was in `.gitignore` and shouldn't
have been, or a Node version mismatch (set `NODE_VERSION` in the environment
variables to match your local `node -v`).

> **"The docs keep telling me to use Workers instead of Pages."** Cloudflare is
> gradually merging the two, and Workers now serves static assets too. Pages
> still works, is still supported, and is markedly simpler for a first deploy —
> use it. Nothing here becomes wasted effort if you move later.

---

## 4. Put it on your domain

Pages project → **Custom domains** → **Set up a custom domain** → type
`yourthing.com`.

Because the domain is already in this Cloudflare account, that's the whole job.
Cloudflare creates the DNS record itself, handles [the apex CNAME
problem](01-three-layers.md#the-apex-problem--the-one-gotcha-worth-knowing-in-advance)
with CNAME flattening, and issues the certificate. Two to five minutes.

**Add `www.yourthing.com` as well.** People type it. Cloudflare will redirect
one to the other, and you avoid the classic "works with www, not without."

Verify from outside your own machine's cache:

```bash
dig @1.1.1.1 yourthing.com +short
curl -sI https://yourthing.com | head -n 1
```

You want `HTTP/2 200`.

---

## 5. Only if you have a backend (Shape 2)

Skip this if your project is static files. You're finished — go to
[Share it](30-share-it.md).

### The idea

You add a `functions/` folder to your repo. Cloudflare turns each file in it
into an API endpoint, using the path. No config, no separate deploy.

```text
functions/api/hello.js   ->   https://yourthing.com/api/hello
functions/api/save.js    ->   https://yourthing.com/api/save
```

The function runs when someone hits that URL, then stops. You are billed for
requests, not for time waiting — which is why this is free at your scale.

### A real one

`functions/api/ask.js` — a backend that calls Claude, keeping your API key out
of the browser:

```javascript
export async function onRequestPost(context) {
  const { question } = await context.request.json();

  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "anthropic-version": "2023-06-01",
      // Set in the dashboard, NOT in this file
      "x-api-key": context.env.ANTHROPIC_API_KEY,
    },
    body: JSON.stringify({
      model: "claude-sonnet-5",
      max_tokens: 1024,
      messages: [{ role: "user", content: question }],
    }),
  });

  if (!res.ok) {
    return new Response(JSON.stringify({ error: "upstream failed" }), {
      status: 502,
      headers: { "content-type": "application/json" },
    });
  }

  const data = await res.json();
  return new Response(JSON.stringify({ answer: data.content[0].text }), {
    headers: { "content-type": "application/json" },
  });
}
```

Called from your page:

```javascript
const res = await fetch("/api/ask", {
  method: "POST",
  headers: { "content-type": "application/json" },
  body: JSON.stringify({ question: "Why is the sky blue?" }),
});
const { answer } = await res.json();
```

`onRequestPost` handles POST. `onRequestGet` handles GET. `onRequest` handles
everything.

### Your API key

Pages project → **Settings** → **Environment variables** → **Production** → add
`ANTHROPIC_API_KEY`, and click the **Encrypt** button. Encrypted values can
never be read back out of the dashboard — you can replace one, but not view it.
That's the behaviour you want.

Add it to **Preview** too if you want pull-request builds to work.

Redeploy after adding variables. Existing deployments don't pick them up.

> **The reason for all of this**, if it isn't obvious: anything in your
> browser-side JavaScript is readable by anyone who presses F12. A key in
> front-end code is a public key. The function exists so the key stays on
> Cloudflare's side of the fence.

### If you need to store data

| You need | Use | Free tier |
|---|---|---|
| Key-value (settings, sessions, counters) | **Workers KV** | Generous |
| A real SQL database | **D1** (SQLite) | Generous |
| File/image uploads | **R2** (S3-compatible, no egress fees) | 10 GB |
| Auth, Postgres, realtime | **Supabase** — not Cloudflare, but it pairs well | Generous |

Add these under **Settings** → **Functions** → **Bindings**, which makes them
appear on `context.env` alongside your variables. Each has its own short setup;
follow [Cloudflare's docs](https://developers.cloudflare.com/) for the one you
pick, and ask Claude to wire it in — it's mechanical.

---

## 6. From now on

```bash
git add .
git commit -m "Make the button blue"
git push
```

That's the deploy. Cloudflare sees the push, builds, and swaps the live version
when it succeeds. Watch it in the Pages dashboard, or:

```bash
gh browse   # opens the repo; Actions tab if you added checks
```

Every pull request gets its own **preview URL** automatically, so you can look
at a change before merging it. This is a genuinely nice thing to have for free.

**Rolling back:** Pages project → **Deployments** → find the last good one →
**Rollback**. Instant, and it doesn't touch your git history.

---

## 7. What it costs

| Thing | Cost |
|---|---|
| Domain | ~$10–12/yr, at cost, no renewal jump |
| DNS | Free, unlimited queries |
| Pages hosting & bandwidth | Free, unlimited |
| Builds | Free up to a monthly cap you won't reach |
| Functions (Workers) | Free up to a daily request cap you won't reach |
| Certificate | Free, auto-renewed |

**Realistically: the domain, and nothing else.** [Current
pricing](https://www.cloudflare.com/plans/) — check it rather than trusting this
table, which will age.

The one thing to know: the free tier's failure mode is a **429 / "over limit"**
response, not a bill. If your project unexpectedly goes viral, it goes down
rather than charging you. For a personal project that's the right trade.

---

## 8. Things that will bite you

| Symptom | What's actually happening |
|---|---|
| Build succeeds, site is blank | Wrong output directory. Check what `npm run build` produces |
| Build fails on a dependency | `node_modules` was committed, or `package-lock.json` wasn't. Commit the lockfile, ignore the folder |
| Build fails, works locally | Node version. Set `NODE_VERSION` in environment variables to your `node -v` |
| Custom domain stuck "pending" | Domain isn't in this Cloudflare account, or nameservers haven't switched. `dig NS yourthing.com` |
| Function returns 500 | Missing environment variable, usually. Check the real-time logs under **Functions** |
| `/api/…` returns your HTML | The `functions/` folder must be at the **repo root**, not inside `src/` |
| Env var change had no effect | Variables apply at build time — redeploy |
| Works with `www`, not without | Add both as custom domains |
| Old version still showing | Your browser. Hard-reload (Cmd/Ctrl+Shift+R) before suspecting Cloudflare |
| Email stopped after moving DNS | The `MX` records didn't import. Copy them from your old provider — see step 2b |

---

**Next:** [Share it →](30-share-it.md)

*Curious what the other track looks like? [Track B: AWS](20-aws.md). You don't
need it, but the comparison is instructive — the same four layers, more visible.*
