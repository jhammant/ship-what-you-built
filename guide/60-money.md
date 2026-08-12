# Making money from it

**This page gets you a realistic picture of what a small site earns, and the
order to try things in — about fifteen minutes to read.** It is deliberately
unglamorous, because the gap between what people expect from ads and what ads
actually pay is where most of the disappointment lives.

Everything here comes from running [BinMinder](https://binminder.co.uk) — a UK
bin-collection reminder service — through ad networks, affiliate links and a
subscription flow, and getting several of them wrong first.

---

## The number nobody tells you

Display advertising pays per thousand page views. The industry measure is
**RPM** — revenue per mille, i.e. per 1,000 views.

For a small English-language site with no particular commercial intent, a
realistic RPM is somewhere around **£1–5**. So:

| Page views / month | Roughly what ads pay |
|---|---|
| 1,000 | a pound or two |
| 10,000 | £10–50 |
| 100,000 | £100–500 |
| 1,000,000 | £1,000–5,000 |

Read that table before you spend an evening integrating anything. **At the
scale a new personal project operates at, ads pay for a coffee, not a
domain.** That is not a reason never to do it — but it should change what you
expect, and it should stop you degrading a nice site for £3 a month.

> Those are shapes, not quotes. RPM swings enormously by topic (finance and
> insurance pay many times what a hobby site does), by country (US and UK
> traffic pays far more than most), and by season (December is the peak;
> January falls off a cliff).

---

## The other side: what it actually costs to run

Before working out what a project earns, it helps to know what it costs. Here
is a real AWS bill — one personal account, several dozen small sites, four
consecutive months:

| Month | Total | Domains | DNS (Route 53) | **Actual hosting** |
|---|---|---|---|---|
| May | $56.73 | $34.00 | $13.07 | **$0.18** |
| June | $18.13 | $0 | $13.05 | **$0.18** |
| July | $170.14 | $127.00 | $13.85 | **$0.30** |
| August | $161.12 | $120.00 | $13.81 | **$0.09** |

Look at the last column. **Serving the actual websites — S3 storage and
CloudFront delivery for dozens of live sites — costs between nine and thirty
cents a month.** Not per site. In total.

Every meaningful pound in that bill is one of two things:

- **Domains.** The spikes are months where domains were bought or renewed.
  This is the real cost of a project, and it is a *decision*, not a running
  cost — nobody accidentally spends $127 on hosting, but it's very easy to
  accidentally own twenty domains.
- **DNS zones.** That steady ~$13.80 every month is Route 53 charging per
  hosted zone: $0.50 each for the first 25, then $0.10 for each one after. Zone
  charges accrue whether or not a single person visits, and whether or not
  anything is still deployed there.

**The two conclusions worth carrying:**

1. **Hosting is not your cost. Ownership is.** Deploying another static site to
   a bucket you already have is genuinely free. Buying another domain is £10–16
   a year forever, plus $6 a year for the zone.
2. **Abandoned projects keep charging.** That flat $13 line is mostly zones for
   things nobody visits. When you retire a project, delete the hosted zone and
   turn off auto-renew — [Track B, Part 9](20-aws.md#part-9--turning-it-off)
   walks through it, and it is the single most-skipped section of this guide.

> Track A shifts this further: Cloudflare charges nothing for DNS at all, so
> the equivalent bill would be domains only. If you own a lot of names, that
> difference is most of your bill.

---

## The four ways, in the order worth trying them

1. **Affiliate links** — highest earnings per visitor at small scale, and no
   approval gate for most programmes.
2. **A subscription** — the only one that scales with value rather than
   traffic, but it needs something people would genuinely miss.
3. **Display ads** — easiest to add, pays least, costs you the most in speed
   and goodwill.
4. **Selling to a business** — one council or one company paying properly
   beats ten thousand visitors. Slowest, and it isn't passive.

Most people do these in exactly the opposite order. Ads are the most obvious
thing and the least rewarding thing.

---

## Display ads, and how it actually goes

### Getting in is the first hurdle, and going live is the second

Ad networks are not all the same, and the good ones have **traffic minimums**:

| Network | Rough entry bar | What it is |
|---|---|---|
| **Google AdSense** | none | The default. Takes new sites with no traffic |
| Ezoic | low | Ad-management layer, will take small sites |
| Newor Media | moderate | Managed network, sells your inventory through Google Ad Manager |
| Mediavine | high (tens of thousands of sessions) | Premium, much better RPM |
| Raptive | very high | Premium, top-tier RPM |

**BinMinder went through this with Newor Media, and the failure mode was more
interesting than a flat "no".** The application was accepted at the Google Ad
Manager level — the account was approved, the paperwork was done. But the site
itself sat at **"Pending", with zero active ad units, "Inactive"**, and never
started serving. Approved and live are two different states, and the dashboard
is the only place that tells you which one you're in.

So the lesson isn't "you'll get rejected". It's:

- **Getting accepted is not the same as getting paid.** Check for *active
  units* and *impressions*, not an approval email.
- **Zero impressions and a low RPM are different problems.** Zero means the
  integration isn't live. Low means it is live and your traffic isn't worth
  much yet. Diagnose which before changing anything.

The fallback was **AdSense**, which accepts sites with essentially no traffic.
That is its whole role in this ecosystem: it is where you start, and it pays
correspondingly less than the networks you cannot get into yet.

> **AdSense has its own gate, and it isn't traffic — it's "low value
> content".** It wants to see a site with a real reason to exist before it
> approves you: roughly a handful of substantial pages, not a shell. If you're
> rejected on those grounds, adding *more* pages is the wrong fix — see
> [the near-duplicate trap](50-getting-found.md#the-trap-that-ai-makes-very-easy),
> which is the specific way this bites projects built with an agent.

**The practical sequence:** start on AdSense, grow traffic, and reapply to a
premium network when you genuinely clear its bar. Moving up is where the real
increase comes from — the difference between AdSense and a premium network on
the same traffic can be several times over.

### `ads.txt`, and keeping it honest

`ads.txt` is a plain text file at the root of your site — `yourthing.com/ads.txt`
— listing who is allowed to sell advertising on your behalf. It exists to stop
fraudsters claiming they can sell your inventory. Buyers check it; if you are
not listed correctly, some demand quietly disappears.

**If you are on AdSense alone, the entire file is one line:**

```text
google.com, pub-0000000000000000, DIRECT, f08c47fec0942fa0
```

Replace the `pub-` number with your own publisher ID from your AdSense account.
`f08c47fec0942fa0` is Google's certification ID and is the same for everyone.

> **The trap, learned the hard way.** When you apply to a managed network they
> give you a large `ads.txt` — often a thousand lines — authorising every
> partner they resell through, plus a `managerdomain=` line naming them as your
> BinMinder ran for months on a 1,123-line `ads.txt` that named a network it
> had never gone live with — the file outlived the relationship by a long way,
> because nothing breaks when it's wrong and so nothing reminds you.
>
> It isn't harmful, exactly — `ads.txt` authorises sellers rather than
> summoning them, so a thousand lines for a network you don't use simply
> describes relationships that don't exist. But it's untrue, it declares
> someone else as your authorised manager, and it makes the one line that
> *does* matter hard to find. **When you leave a network, put your `ads.txt`
> back to the one line that's true.**

> **And when Google says your `ads.txt` is missing, check before you fix it.**
> AdSense will report the file as missing or unreachable when it is being
> served perfectly well — the status reflects the last time Google *crawled*
> it, not the current state, and that crawl can be days stale. Verify what the
> world actually sees first:
>
> ```bash
> curl -sS -o /dev/null -w '%{http_code}\n' https://yourthing.com/ads.txt
> curl -sS -A "Mozilla/5.0 (compatible; Googlebot/2.1)" https://yourthing.com/ads.txt | head -3
> ```
>
> A `200` to Googlebot means the file is fine and the warning is lag. Rewriting
> a correct file because a dashboard is behind is a good way to break a working
> setup.

### You need a consent banner, and AdSense will insist

If you have visitors in the UK or EU, personalised advertising requires
consent, and Google requires you to use a **certified Consent Management
Platform**. This isn't optional politeness — AdSense will stop serving
personalised ads to European traffic without one, which is most of your
revenue if you're a UK site.

Free options exist that meet the requirement, including Google's own. Set it up
at the same time as the ads, not afterwards, because retrofitting consent to a
site that has been running without it is more annoying than doing it once.

### What ads actually cost you

Worth pricing honestly against the pound or two:

- **Speed.** Ad scripts are heavy and third-party. A fast page becomes a slow
  one, which affects both how it feels and how it ranks.
- **Layout shift.** Ads that load late shove your content down the page.
  Reserve the space with fixed-height containers or you will make the site
  visibly worse.
- **Trust.** On a small utility that people use *quickly* — check a date, get an
  answer — ads make it feel less like a helpful thing and more like a funnel.
- **Your own use of it.** Never click your own ads. It is the fastest way to
  get an AdSense account permanently banned, and appeals rarely succeed.

---

## Affiliate links, which work better than you'd think

BinMinder's main revenue idea was not ads on the page. It was a link in the
**reminder message itself**:

```text
Tomorrow: RECYCLING bin. Treat yourself after! https://yourthing.link/x7k2m
```

That short URL redirects through an affiliate programme — takeaway delivery, in
this case — and pays a commission on anything that follows.

**Why this shape works when banner ads don't:**

- It reaches people who are not looking at your website. A reminder service's
  users mostly never visit the site after signing up, so page views — and
  therefore ad revenue — are structurally tiny. The message is the product.
- It arrives at a moment with context. "Bin night, and it's Thursday" is a
  better moment to mention dinner than a banner is at any moment.
- Commissions per action are pounds, where an ad impression is a fraction of a
  penny.

**What to know before you try it:**

- **Approval takes days, not minutes.** Most programmes review applications
  manually, and several want to see a working site first. Apply early.
- **Use your own short links**, one per message, so you can actually measure
  which placements work. If you can't attribute a click you can't improve
  anything.
- **Disclose it.** UK advertising rules require it to be obvious when a link is
  commercial, and it costs you almost nothing to be straight about it.
- **Relevance beats payout rate.** A 3% commission on something your users
  actually want beats 10% on something irrelevant.

---

## Subscriptions, and the mistake worth learning from mine

The honest one. BinMinder has a complete Stripe integration: a payment module,
a trial-aware signup flow, subscription state in the database. All written, all
committed, all deployed.

**And live revenue from it was zero, for months.**

Not because of a bug. The Stripe API keys were never set as environment
variables in production, so the config check that enables payments evaluated
false, and the entire flow stayed switched off. The code was live. The feature
was not.

**Three things that generalises to:**

1. **Shipping the code is not turning the feature on.** Anything gated behind
   an environment variable is off until that variable exists *in production*.
   It works on your laptop because your laptop has a `.env`.
2. **Check the outcome, not the deploy.** A green deploy told him nothing. The
   question is "has anyone actually been charged?", and nobody had.
3. **Measure from your own database.** When the payment provider isn't wired
   up, anything reading from Stripe reports zero — and zero looks identical to
   "no sales" when it actually means "not switched on". BinMinder's daily
   revenue digest reads subscription state from Postgres for exactly this
   reason: your database knows what you promised people, whoever is taking the
   money.

If you add a paid tier, do this on day one:

```bash
# Prove the switch is actually on in production, not just in your code
curl -s https://yourthing.com/api/health | grep -i stripe
```

Better still, make your health endpoint say plainly whether payments are
enabled. A feature that can be silently off should tell you it's on.

---

## What actually works at this scale

Ranked by what returns most per hour spent, for a project with a few thousand
visitors a month:

1. **Do nothing yet.** Get people using it first. Monetising a thing nobody
   uses is optimising a zero.
2. **One relevant affiliate link,** placed where someone is already about to
   act. Minutes of work, no approval gate on most programmes, pounds per
   conversion rather than fractions of pennies.
3. **Ask.** A "buy me a coffee" style link earns more than ads do at small
   scale, more often than people expect, and costs your visitors nothing.
4. **A paid tier, if there is something people would genuinely miss.** Ten
   people paying £2 beats 20,000 page views. And it tells you something ads
   never will — that what you made is worth money to someone.
5. **Ads, last.** Add them when traffic is large enough that the RPM table
   above shows a real number, and reapply to a better network the moment you
   clear its bar.

---

## Before you monetise anything

- [ ] Does it have users who would notice if it disappeared? If not, stop here.
- [ ] Is the thing still fast and pleasant with the money bit added?
- [ ] If it's ads: is your `ads.txt` true, and is a consent banner live?
- [ ] If it's affiliate: is the commercial relationship disclosed?
- [ ] If it's a subscription: has a real payment gone through in production,
      by you, with a real card?
- [ ] Can you tell tomorrow whether it earned anything, without logging into
      four dashboards?

That last one matters more than it sounds. If checking revenue is a chore, you
will stop checking, and a switched-off payment flow can sit there for months.

---

**Next:** [Getting more from one domain →](70-your-domain.md)
