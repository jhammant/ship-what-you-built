# The three layers

Ten minutes here saves you an afternoon later. Almost every "I'm stuck" moment
in hosting comes from not knowing which of these three things is broken.

---

## What actually happens when someone visits your site

Someone types `yourthing.com` into a browser. Four separate systems, owned by
up to four different companies, have to cooperate:

```text
  1. "Who is allowed to answer for yourthing.com?"
     ──> REGISTRAR    (you bought the name here; you told it which
                       nameservers are in charge)
                             │
                             ▼
  2. "Where is yourthing.com?"
     ──> DNS          (the nameservers answer with an address)
                             │
                             ▼
  3. "Give me the page."
     ──> HOSTING      (a server sends back your HTML)
                             │
                             ▼
  4. "Prove you're really yourthing.com."
     ──> CERTIFICATE  (proves it, so the browser shows a padlock
                       instead of a red warning)
```

**These are four separate purchases from four possible vendors.** You can buy
the name at AWS, run DNS at Cloudflare, host on GitHub, and get the certificate
free from Let's Encrypt. Nothing forces them to match.

That single fact is worth more than any command in this guide, because it means
**no choice you make today is a trap**. Don't like your host? Change layer 3,
keep the domain. Registrar being annoying? Move layer 1, nothing goes down.

---

## Layer 1 — The registrar

**What it is:** the company you buy the domain name from. Namecheap, Cloudflare,
AWS Route 53 Domains, GoDaddy, Gandi.

**What you're actually buying:** not the name — a *lease* on it, usually a year
at a time, and the right to say who answers DNS questions about it. That's it.
That second part is the important one.

**What it costs:** the registrar's price plus a fixed ICANN fee. There's no
technical difference between registrars. There are two commercial ones:

- **The renewal trap.** `.online` at £1.50 for year one, then £26 every year
  after. Always look up the *renewal* price. Some TLDs renew at 15× year one.
- **The markup.** Some registrars sell at cost, some add 30%.

`.com` is boringly flat — roughly $11/year forever, everywhere. That's part of
why it's still the default.

**How to switch registrar:** transfer the domain (needs an auth code from the
old one, takes ~5 days). Your site stays up the entire time, because the
nameservers don't change. Layer 1 is the least sticky thing you own.

---

## Layer 2 — DNS

This is the layer people find confusing, so it gets the most space.

DNS is a global phone book. Your bit of it is called a **zone** — the set of
records that answer questions about `yourthing.com`.

### Nameservers: who holds the phone book

At the registrar, your domain has **nameservers** set against it — usually two
to four addresses like `ns1.example.com`. They mean: *these machines are the
authority on this domain, ask them.*

Change the nameservers and you've moved your entire DNS to a new provider. This
is the one setting at the registrar that really matters, and it's the reason
"where I bought the domain" and "who runs my DNS" are different questions.

### Records: what's in the phone book

Inside the zone, you add records. In practice you need four kinds:

| Record | Answers | Example value |
|---|---|---|
| **A** | "What IPv4 address?" | `104.21.5.12` |
| **AAAA** | "What IPv6 address?" | `2606:4700::6815:50c` |
| **CNAME** | "What *other name* should I look up instead?" | `yourthing.pages.dev` |
| **TXT** | "Here's some text" — used to prove you own the domain | `google-site-verification=…` |

A **CNAME** is an alias, and it's what modern hosts want you to use. You point
`www.yourthing.com` at `yourthing.pages.dev`, and now if Cloudflare changes
their IP addresses tomorrow, your site doesn't notice. This is why hosts hand
you a hostname rather than an IP.

### The apex problem — the one gotcha worth knowing in advance

You cannot put a CNAME on the **apex** (also called the root, or the naked
domain): `yourthing.com` with no `www.`. The DNS specification forbids it, and
this trips up nearly everyone.

Providers solve it with a non-standard record type that looks like a CNAME but
resolves to an A record behind the scenes:

- Cloudflare calls it **CNAME flattening** (it just works, you add a CNAME and
  Cloudflare handles it)
- Route 53 calls it an **ALIAS** record
- Others call it `ANAME` or `ALIAS`

**Both tracks in this guide handle this for you.** You're being told now so that
when you read "you can't CNAME the apex" on Stack Overflow at 11pm, you already
know what it means and that it's solved.

### "DNS propagation" — mostly a myth

You'll be told changes take 24–48 hours. They almost never do.

Every DNS record has a **TTL** (time-to-live) in seconds — a note saying "you
may cache this answer for this long." Set a record with a 300-second TTL and the
world sees your change within five minutes.

The 48-hour folklore comes from two real things:

1. **Nameserver changes** (layer 1) genuinely are slow — the `.com` registry
   publishes those on its own schedule, typically a few hours.
2. **Your own computer and router cache aggressively**, so *you* are often the
   last person on earth still seeing the old value. This produces the classic
   "it works for everyone but me."

**Lower the TTL to 300 *before* you make a change you know is coming.** Then the
change itself is nearly instant.

### See it for yourself

You don't have to take any of this on faith. In a terminal:

> `dig` is the standard tool for asking DNS a question directly. macOS has it
> already. On Ubuntu or WSL: `sudo apt install bind9-dnsutils`. On Windows
> without WSL there's no `dig` — use `nslookup -type=NS yourthing.com`, or
> [dnschecker.org](https://dnschecker.org) in a browser, which also shows you
> what the rest of the world sees rather than just your own machine.

```bash
# Which nameservers are in charge? (layer 1 answering)
dig NS shipwhatyoubuilt.com +short

# What address does the site resolve to, and what's the TTL?
dig A shipwhatyoubuilt.com

# Ask a specific public resolver, bypassing your own cache
dig @1.1.1.1 A shipwhatyoubuilt.com +short

# Follow the whole chain from the root servers down — genuinely worth
# running once just to watch it happen
dig +trace shipwhatyoubuilt.com
```

`dig +trace` is the one to run when something is inexplicably wrong. It shows
you exactly which layer stops cooperating.

---

## Layer 3 — Hosting

Where your actual files or code live, and what sends them to the browser.

Three broad shapes, matching the three in [the chooser](00-start-here.md):

| Shape | What "hosting" means | Track A | Track B |
|---|---|---|---|
| Static files | A CDN serving files from storage | Cloudflare Pages | S3 + CloudFront |
| Plus a backend | A function that runs per request, then stops | Cloudflare Workers | Lambda |
| Always running | A machine that stays on | (see [the honest note](00-start-here.md#the-honest-note-about-shape-3)) | |

The first two only cost money when someone visits, and at personal-project
traffic that rounds to zero. The third costs money whether or not anyone visits,
which is the whole reason the chooser separates them.

---

## Layer 4 — The certificate

HTTPS needs a certificate proving you control the domain. Browsers now shame
sites that lack one, so this isn't optional.

**It's free and, in both tracks, automatic.** Let's Encrypt made certificates
free in 2015 and everyone followed. Cloudflare and AWS both issue and renew
yours without you doing anything.

The one thing worth knowing: the certificate authority has to **verify you
control the domain** before issuing, and it does that by asking you to prove it
via DNS (add a TXT record) or HTTP (serve a specific file). That's why
certificate setup sometimes says *"pending validation"* and waits on a DNS
record. It's layer 4 waiting for layer 2. Both tracks add that record for you.

AWS has one extra rule that catches everybody: **a certificate used by
CloudFront must be issued in the `us-east-1` region**, no matter where you or
your users are. Track B says this again at the point it matters.

---

## The mix-and-match table

Any row of layer 1 works with any row of layer 2, and so on. Some common
combinations:

| Registrar | DNS | Hosting | Verdict |
|---|---|---|---|
| Cloudflare | Cloudflare | Cloudflare Pages | Fewest moving parts. **Track A.** |
| Route 53 | Route 53 | S3 + CloudFront | All in one bill. **Track B.** |
| Namecheap | Cloudflare | Cloudflare Pages | Fine. Point Namecheap's nameservers at Cloudflare, done. |
| Route 53 | Cloudflare | Anything | Fine, and saves the hosted-zone fee. Keep the name at AWS, move the nameservers. |
| Cloudflare | Cloudflare | AWS Lambda | Fine. Cloudflare DNS in front of AWS compute is a common production setup. |

**There is no wrong row.** There are only rows with more or fewer accounts to
log into.

---

## When it breaks, which layer is it?

| What you see | Layer | First thing to check |
|---|---|---|
| "Server not found" / `NXDOMAIN` | 2 (or 1) | `dig NS yourthing.com` — are the nameservers what you expect? |
| Resolves, but connection refused/times out | 3 | The host isn't serving. Is the deploy actually finished? |
| Red padlock warning | 4 | Certificate missing, expired, or issued for the wrong name |
| Works with `www.`, not without (or vice versa) | 2 | You created a record for one hostname and not the other |
| Everyone sees it but you | 2 | Your own cache. `dig @1.1.1.1` to bypass it |
| Old version still showing | 3 | CDN cache — needs a purge/invalidation, plus a browser hard-reload |

Getting into the habit of asking *"which layer?"* before you start changing
things is the single biggest time-saver in this entire guide.

---

**Next:** [Get it on GitHub →](05-github.md)
