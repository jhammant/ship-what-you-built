# Getting it found

**This page gets you the two ways people will actually arrive at your site —
search and sharing — and what measurably works at each. About twenty minutes,
plus an hour of setup you only do once.**

You already made the link look right in [Share it](30-share-it.md). This is the
longer game: being findable when nobody is looking for you by name.

---

## The two doors, and which to open first

| | Search | Sharing |
|---|---|---|
| Speed | Slow — weeks to months | Immediate |
| Effort | An hour, once, then patience | Every post |
| Traffic shape | Small, steady, compounding | A spike, then nothing |
| Who arrives | People with the problem | People who follow you |

**Do the search setup first even though the payoff is slower**, because it's an
hour that keeps paying, and because the same work — a real title, a real
description, a preview image — is what makes the sharing look good too. Then
share, because search takes weeks and you want someone using the thing this
week.

---

## Search: the hour that matters

Almost all of the value is in a handful of things, and skipping them is common
even on good projects. Here are four real sites — three of mine — checked the
day this was written:

| Site | Canonical | Structured data | Preview tags | Sitemap |
|---|---|---|---|---|
| iphoneopen.com | yes | yes | yes | yes |
| checkmybinday.co.uk | yes | yes | yes | yes |
| binminder.co.uk | yes | no | yes | **missing** |
| my11plustutor.co.uk | **no** | **no** | **no** | **no** |

That last row is the lesson. It is a free, open-source 11+ practice app with
17,000 questions in it — comfortably the most *useful* thing in that list — and
it has none of the scaffolding that would let anyone find it, and no preview
tags, so every link to it shares as a bare blue URL. **Being good is not a
distribution strategy.**

### The checklist

Work through this once. Claude can do nearly all of it in a single pass — the
prompt is at the end.

**1. A real `<title>` per page.** Not "Home". It is the single biggest on-page
factor and it is what people see in results. Put the useful words first:

```html
<title>Find My Bin Collection Day – Free UK Bin Day Checker</title>
```

**2. A meta description.** It doesn't affect ranking directly; it is the sales
pitch under the title and it changes whether anyone clicks.

```html
<meta name="description" content="Check your UK bin collection day free. Enter a postcode, get your next recycling, food and general waste dates.">
```

**3. One `<h1>` per page**, saying what the page is. Sub-headings as `<h2>`.
This sounds pedantic and is genuinely how machines read your structure.

**4. A canonical link**, so the same page reachable at several URLs (`www` and
non-`www`, with and without a trailing slash) counts as one page rather than
competing with itself:

```html
<link rel="canonical" href="https://yourthing.com/page">
```

**5. `robots.txt`** at your root, saying crawling is allowed and where the map
is:

```text
User-agent: *
Allow: /

Sitemap: https://yourthing.com/sitemap.xml
```

**6. `sitemap.xml`** listing your pages. For a handful of pages, write it by
hand:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://yourthing.com/</loc></url>
  <url><loc>https://yourthing.com/about</loc></url>
</urlset>
```

**7. Structured data**, if your thing is a recognised type — an app, a recipe,
a FAQ, an event. It's a small JSON block that can earn you a richer-looking
result:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebApplication",
  "name": "Tide Clock",
  "description": "Today's tide times for your nearest beach",
  "applicationCategory": "UtilitiesApplication",
  "offers": { "@type": "Offer", "price": "0", "priceCurrency": "GBP" }
}
</script>
```

**8. Tell Google it exists.** Sign in to
[Google Search Console](https://search.google.com/search-console), verify the
domain (a DNS TXT record — you know how to add those now), submit the sitemap.
Without this you are waiting to be discovered; with it you are asking.

Search Console is also the only honest source for what people actually searched
before landing on you. Check it in a month; the queries are frequently not the
ones you'd have guessed, and they tell you what to write next.

### The trap that AI makes very easy

This is the one that matters most for anything built with an agent, because an
agent makes it a single prompt.

You have a thing that works for one council, or one city, or one product. So
you generate a page for **all** of them — 657 pages, each with the right name
substituted in. It looks like a content strategy. Google calls it thin
content, and the result is that none of them rank.

Here are real measurements from doing exactly that:

| | Result |
|---|---|
| Mean overlap between generated council pages | **82%** |
| After adding a unique facts block to each | **78%** |
| Pages Google eventually indexed | roughly none — 657 ended up `noindex` |
| AdSense verdict | rejected as low-value content |

**The middle row is the important one.** The fix that felt right — write a
genuinely unique block of facts for each page — moved overlap from 82% to 78%.
Barely anything. The reason is arithmetic: the unique part was about **80
words against 2,000 words of shared template**. Ninety-six percent of every
page was still identical to every other page.

Compare that with pages on the same site that *did* work: 2,200–2,800 words
each, written to be substantial, and only **22% overlap**. Real content, not a
template with a variable in it.

**So the rule is not "write more pages". It is:**

- **Unique content has to dominate the page, not garnish it.** If your template
  is 2,000 words and your per-page facts are 80, you have one page repeated N
  times, whatever the URL says.
- **Ten real pages beat 700 generated ones.** They rank, they can be linked,
  and they don't get your ad account rejected.
- **If you can't say something substantially different about each one, don't
  make the page.** Serve those cases from a single page with a lookup instead —
  which is what most utilities should do anyway.
- **`noindex` is the honest repair** if you already made them. It tells Google
  not to consider pages you know are thin, which protects how it judges the
  rest of your site.

Measure your own, rather than guessing — if two pages share most of their
words, you'll see it immediately:

```bash
# crude but effective: how much of page B's wording already appears on page A?
for u in https://yourthing.com/a https://yourthing.com/b; do
  curl -sL "$u" | sed 's/<[^>]*>/ /g' | tr '[:upper:]' '[:lower:]' \
    | tr -cs '[:alnum:]' '\n' | sort -u > "/tmp/$(basename "$u").words"
done
comm -12 /tmp/a.words /tmp/b.words | wc -l   # shared
cat /tmp/b.words | wc -l                      # total on B
```

### Two things that quietly cost you

- **Third-party scripts on the critical path.** `cdn.tailwindcss.com` and
  similar CDN builds are convenient and slow — the Tailwind CDN in particular
  is documented as a development tool, not for production, because it compiles
  in the browser on every visit. Speed is a ranking factor and, more to the
  point, a leaving factor.
- **A JavaScript-only page.** If your content only exists after JavaScript
  runs, some crawlers and most link-preview scrapers see an empty page. Test
  what they see:

  ```bash
  curl -sL https://yourthing.com | sed 's/<[^>]*>//g' | tr -d '[:space:]' | wc -c
  ```

  A few hundred characters means your page is effectively empty to a machine.
  Tens of thousands means the content is really in the HTML.

---

## Sharing: what measurably works

Everything below is measured from about 600 posts on one UK tech account, so
treat it as a strong hint rather than a law — but the effects are large enough
to be worth copying.

### The levers, biggest first

| Lever | Measured effect |
|---|---|
| **Format** | Video ≈ **3.3×** a plain link post. Image ≈ 2.7×. Text ≈ 1.2× |
| **A hook in the first line** | ≈ **2.9×** |
| **Length 300–1,500 characters** | ≈ **2.3×** versus a one-liner |
| **Link in the post body** | ≈ **0.6×** — a 40% penalty |
| **Replying in the first hour** | roughly **doubles** reach |

Which gives five rules that cost nothing:

1. **Never post a bare link.** It is the weakest thing available. Post an image
   or a video and put the link in the first comment.
2. **Open with the problem, not the product.** "I built X" performs far worse
   than the situation the reader recognises. "It works, and it's been sitting
   on my laptop for three weeks" is a hook; "Introducing X" is not.
3. **Write 300–1,500 characters.** A real thought, not a slogan and not an
   essay.
4. **Reply to every comment in the first hour.** This is the biggest lever you
   personally control, and the one most people skip.
5. **Say what surprised you.** The bit you got stuck on is the most relatable
   and most repliable part. A launch post that admits a failure gets more
   genuine replies than one that claims a triumph.

> **Timing matters far less than people think** — on this account, the best
> slot beat the worst by under 2×, while format alone was 3.3×. Post at a
> reasonable hour and spend your effort on the video instead of the calendar.

### Where else to put it

- **Hacker News** (Show HN) — brutal, and the single best source of genuinely
  technical feedback. Submit your own work, title it plainly, be present in the
  comments.
- **Reddit** — find the subreddit for the *problem*, not for programming. A bin
  reminder belongs in a UK local subreddit, not r/webdev. Read the rules first;
  self-promotion bans are common and permanent.
- **Product Hunt** — a spike of the wrong sort of traffic for most small
  utilities, but real if your thing is a product rather than a tool.
- **The obvious one people forget:** tell the people it was built for. If you
  made it for a specific group, find where they already talk.

### The thing that outperforms all of it

Make something for a specific person or group with a real problem, and tell
them directly. Twenty people who needed it beats two thousand who scrolled past.

---

## Get Claude to do the setup

Most of the search checklist is mechanical:

> Go through this project for search and sharing readiness. For every page:
> check there is a unique descriptive `<title>`, a meta description, exactly one
> `<h1>`, a canonical link, and Open Graph tags with an absolute `og:image` URL.
> Add a `robots.txt` and a `sitemap.xml` covering every real page. Add
> schema.org structured data if there's a type that genuinely fits — don't
> invent one. Then tell me what you changed and what you deliberately left
> alone.

Then verify rather than trusting it:

```bash
curl -sL https://yourthing.com | grep -oE '<title>[^<]*|rel="canonical"|property="og:[a-z:]*"'
curl -sIL https://yourthing.com/sitemap.xml | head -1
curl -sIL https://yourthing.com/robots.txt | head -1
```

---

**Next:** [Making money from it →](60-money.md)
