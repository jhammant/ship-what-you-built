# Paying for traffic

**This page gets you a Google Ads campaign driving search traffic to your
project, with conversion tracking so you know whether it's working — about
thirty minutes to set up, and a few pounds a day to run.**

[Getting it found](50-getting-found.md) covered the free ways — search
optimisation and sharing. This is the paid alternative: you give Google money,
and people searching for the problem your project solves see your link at the
top. It is faster than SEO and more predictable than posting, and it is also
the easiest way to spend money on something that doesn't work.

---

## When this makes sense, and when it doesn't

Paid traffic is worth trying when:

- Your project solves a problem people actually search for
- You have a clear thing you want them to do when they arrive (sign up, try
  it, subscribe)
- You can afford a few pounds a day to test, and you're comfortable stopping
  if it doesn't work

It is **not** worth trying when:

- Nobody searches for the problem (most developer tools, niche utilities)
- Your project has no call to action — if the whole thing is on the landing
  page, there's nothing to convert and nothing to measure
- You haven't tried the free routes first — if organic search and sharing
  haven't been set up, do [that](50-getting-found.md) first, because paid
  traffic to a page with no `<title>` and no preview image is paying to look
  unfinished

> **The real lesson from small-scale ads** is not the traffic they bring. It's
> what you learn from the search terms report — the actual phrases people type
> before clicking. Those phrases are free keyword research, and they often
> suggest content you should write or features you should build, which pays
> off long after you stop the campaign.

---

## The setup

### 1. Create an account

[ads.google.com](https://ads.google.com). You'll need a Google account and a
payment method. Google periodically offers credit for new accounts — check
for one before you start, because they're time-limited and easy to miss.

### 2. Install the tracking tag

Your Ads account has a **Conversion ID** — it looks like `AW-XXXXXXXXX`. Add
this to the `<head>` of your project page:

```html
<script async src="https://www.googletagmanager.com/gtag/js?id=AW-XXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'AW-XXXXXXXXX');
</script>
```

This is the same tag manager snippet used by Google Analytics. If you want
both — and you should — you can add a second `config` line rather than a
second script:

```html
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');   // Google Analytics
  gtag('config', 'AW-XXXXXXXXX');   // Google Ads
</script>
```

One script load, two services. The `G-` ID is your GA4 property; the `AW-`
ID is your Ads account.

### 3. Set up conversion tracking

A **conversion** is the thing you want visitors to do — click "Subscribe",
start a trial, download something. Without tracking it, you're measuring
clicks to your site, which tells you nothing about whether those clicks
mattered.

In Google Ads: **Goals** → **Conversions** → **New conversion action** →
**Website** → **Manual setup**. Give it a name, a value (even a notional
one — £1 is fine for a signup), and you'll get a conversion label.

Fire it from your page when the action happens:

```javascript
document.getElementById("subscribe-btn").addEventListener("click", function () {
  gtag("event", "conversion", {
    send_to: "AW-XXXXXXXXX/AbCdEfGhIjKlMn",
    value: 1.0,
    currency: "GBP",
  });
});
```

The `send_to` value combines your Conversion ID and the label Google gave you.

### 4. Create a Search campaign

For a personal project, **Search** is almost always the right campaign type.
It shows your link when someone searches for something relevant. Display
(banner ads on other sites) and Performance Max (Google decides everything)
are for later, if ever.

**New campaign** → **Leads** or **Website traffic** → **Search**.

**Budget:** start at £2–3 a day. That's enough to learn whether people click,
and cheap enough that a week of nothing useful costs less than lunch. You can
always raise it later; you can't un-spend a bad week at £20/day.

**Keywords:** the phrases you want to trigger your ad. Think about what
someone would type if they had the problem your project solves, not what
you'd call your project:

| Project | Good keywords | Bad keywords |
|---|---|---|
| A bin-day reminder | `bin collection day`, `when is my bin day` | `BinMinder`, `bin app` |
| A meal planner | `weekly meal plan`, `grocery list from recipes` | `meal planner app`, `food tech` |
| A tide app | `tide times near me`, `is it safe to swim` | `tide clock`, `coastal app` |

**The left column is the problem. The right column is the solution.** People
search for problems. Only search for your project name once they already know
about it, which is not what ads are for.

> **Match types matter.** A keyword in `[square brackets]` is exact match — only
> that phrase. In `"quotes"` is phrase match — that phrase within a longer
> query. Bare words are broad match — Google decides, liberally. Start with
> phrase match and move to exact match for the ones that convert, or broad
> match if you want Google to find new phrases (with a close eye on the
> search terms report).

### 5. Write the ad

Google gives you headlines (30 characters each) and descriptions (90
characters each). It mixes and matches them, so each one has to work on its
own:

- **Headline 1:** the benefit, not the name. "Check Your Bin Day Free" not
  "BinMinder"
- **Headline 2:** what makes it different. "Postcode lookup, 30 seconds"
- **Headline 3:** the name, if there's room. "BinMinder.co.uk"
- **Description 1:** one sentence about what it does
- **Description 2:** the call to action. "Try it free — no signup needed"

Write for someone who has the problem, not someone who knows your project
exists.

---

## Google Analytics — measuring what happens next

The Ads tag tells you who clicked. **Google Analytics (GA4)** tells you what
they did after they arrived — which pages they visited, how long they stayed,
whether they came back.

If you added the combined snippet above, you already have it. Go to
[analytics.google.com](https://analytics.google.com), create a property, and
use the `G-` measurement ID in your tag.

The three reports worth checking weekly:

1. **Acquisition → Traffic acquisition** — where people come from (organic,
   paid, direct, social). This is where you see whether the money is bringing
   a different kind of visitor.
2. **Engagement → Pages and screens** — which pages people actually look at.
3. **Acquisition → Search Console** — link your Search Console account and
   you see which organic queries bring people, alongside the paid ones. The
   overlap (or lack of it) tells you whether you're paying for traffic you'd
   get free.

> **A word about GA4's learning curve.** It is not intuitive. The interface
> assumes you're running a business with funnels and segments, and it buries
> simple questions behind several clicks. But the data it collects with the
> default setup — no custom events, no configuration — is already useful.
> Don't let the complexity stop you adding the tag; ignore the dashboards you
> don't understand and check the three reports above.

---

## What it costs, honestly

| Daily budget | Monthly cost | What you learn |
|---|---|---|
| £2 | ~£60 | Whether anyone clicks. Whether the keywords are right |
| £5 | ~£150 | Enough data to see conversion rates. Whether the page works |
| £10+ | ~£300+ | Scaling something you've already proved works |

**Start at £2 and stay there until you've seen a conversion.** If nobody
converts after two weeks at £2/day, the answer is not to spend more — it's
to change the page, the keywords, or the conclusion that paid traffic suits
this project.

Google will suggest you spend more. The dashboard will say your campaigns are
"limited by budget" almost immediately. Ignore it until you have evidence
that spending more produces proportionally more of the outcome you want.

> **The search terms report** (Campaigns → Keywords → Search terms) is the
> most valuable screen in the entire product. It shows the *actual phrases*
> people typed before clicking your ad, which are often nothing like the
> keywords you set. Review it weekly, add good ones as keywords, and add
> irrelevant ones as **negative keywords** so you stop paying for them.

---

## What goes wrong

| Symptom | What's happening |
|---|---|
| Lots of clicks, no conversions | The landing page doesn't match the search intent, or the conversion tracking isn't firing — check the browser console |
| "Ad not showing" | Budget too low, or bid below the floor for competitive keywords. Check the keyword status column |
| Spending the budget on irrelevant searches | Broad match is too broad. Switch to phrase or exact match, and add negative keywords |
| Conversion tracking shows zero | The gtag snippet isn't on the page, or the event isn't firing. Test: click the button, then check Google Ads → Tools → Tag Assistant |
| Google suggests "Smart" campaigns | Decline. Smart campaigns remove most of the controls and optimise for clicks, not conversions. Manual Search campaigns give you the data you need |

---

## When to stop

Paid traffic is a test, not a commitment. Stop when:

- **It's working and organic is catching up.** The search terms report gave
  you keywords to optimise for; organic traffic is growing; the ad is now
  paying for traffic you'd get free. That's the good outcome.
- **It's not converting after two weeks.** Either the keywords are wrong, the
  page is wrong, or the problem isn't one people search for. All three are
  useful to know.
- **The cost per conversion is higher than the value.** If each signup costs
  £5 in ads and the project is free, that's £5 of learning. If the project
  earns nothing and the learning is over, stop.

Stopping a campaign is free, instant, and reversible. Don't let it run on
autopilot because pausing feels like giving up.

---

**Next:** [Making money from it →](60-money.md)
