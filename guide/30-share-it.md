# Share it

Your thing is live. This is the part most people skip, and it's the part that
decides whether anyone ever sees it.

Three jobs, about twenty minutes total.

---

## 1. Make the link look like something when it's shared

Paste your URL into LinkedIn, Slack or WhatsApp right now. If you get a bare
blue link with no picture, nobody is clicking it.

The fix is four lines in your `<head>`. These are **Open Graph tags** — a small
convention every social platform reads to build the preview card:

```html
<head>
  <meta charset="utf-8">
  <title>Tide Clock</title>
  <meta name="description" content="Today's tide times for your nearest beach, and when it's safe to swim.">

  <!-- What the preview card shows -->
  <meta property="og:title"       content="Tide Clock">
  <meta property="og:description" content="Today's tide times for your nearest beach, and when it's safe to swim.">
  <meta property="og:image"       content="https://yourthing.com/preview.png">
  <meta property="og:url"         content="https://yourthing.com">
  <meta property="og:type"        content="website">

  <!-- Twitter/X uses its own names, and falls back to og: for the rest -->
  <meta name="twitter:card" content="summary_large_image">
</head>
```

**The rules that actually matter:**

- **`og:image` must be an absolute URL.** `https://yourthing.com/preview.png`,
  not `/preview.png`. This is the number one reason previews come out blank —
  the scraper isn't on your site, so a relative path means nothing to it.
- **Make it 1200×630 pixels.** That's the ratio every platform crops to. Wrong
  ratio, and your title gets sliced in half.
- **Under 5 MB**, and a normal format — PNG or JPG. Not WebP, not SVG; support
  is patchy and the failure is silent.
- **It must be publicly reachable.** No login, no `robots.txt` block. Test it by
  opening the image URL in a private browsing window.
- **`og:description` is the sales pitch,** not a keyword list. One sentence
  saying what it does and who it's for.

### Make the image

**If you installed the skill, one command does it:**

```bash
~/.claude/skills/first-site/scripts/og-image.sh \
  --title "Tide Clock" \
  --subtitle "Today's tide times for your nearest beach" \
  --domain tide-clock.example.com
```

That renders a card with headless Chrome, writes `preview.png` at exactly
1200×630, and prints the `<meta>` tag to paste. Add `--light` for a light card,
`--accent "#C0392B"` to match your own colours.

Otherwise: screenshot your own site, crop to 1200×630, save it as `preview.png`
next to your `index.html`, deploy. Or:

> Generate a 1200×630 Open Graph preview image for this project as a
> self-contained HTML file, screenshot it at exactly that size, and save it as
> `preview.png`. Use the colours and fonts already in my site so it looks like
> it belongs.

### Then check it before you post

Every platform caches the preview **the first time it sees your URL**. Post a
broken one and it can stay broken for days. So validate first:

| Platform | Validator |
|---|---|
| LinkedIn | [linkedin.com/post-inspector](https://www.linkedin.com/post-inspector/) |
| Facebook | [developers.facebook.com/tools/debug](https://developers.facebook.com/tools/debug/) |
| X | Post the link in a draft and look |
| Anything | `curl -s https://yourthing.com \| grep 'og:'` |

LinkedIn's Post Inspector has a **re-scrape** button that clears its cache. If
you've already posted a broken preview, that's the fix.

---

## 2. Write a README worth reading

Your repository's README is the front door. People decide in about four seconds.

The order below is deliberate — it front-loads the two things that decide
whether someone keeps reading:

```markdown
# Project Name

One sentence. What it is, who it's for. No preamble.

**[Try it →](https://yourthing.com)**

![Screenshot](preview.png)

## What it does

Two or three bullets. Concrete, not aspirational.

## Run it locally

The exact commands, copy-pasteable, that work on a clean machine.

## How it's built

A short paragraph. What it's made of and why — this is the bit other
builders read, and it's what makes them star it.

## Licence

MIT.
```

**The screenshot is not optional.** A README with an image gets meaningfully
more engagement than one without, because most people decide from the picture.
Reuse the `preview.png` you just made.

**Add topics** — Settings → the gear next to *About* → Topics. This is most of
how anyone discovers a repo on GitHub. Pick five or six that genuinely describe
it: the language (`python`), the kind of thing it is (`cli`, `dashboard`,
`static-site`), and where it runs (`cloudflare-pages`, `aws-lambda`).

Or hand the whole job over:

> Write a README for this project following the structure in
> https://github.com/jhammant/ship-what-you-built/blob/main/guide/30-share-it.md. Read the actual code first — I want it accurate about
> what this does, not generic. Include real local-setup commands and check they
> work.

---

## 3. Add yourself to the showcase

This is the bit I'd most like you to do. **[SHOWCASE.md](../SHOWCASE.md)** is a
list of things people built and got online using this guide, and yours belongs
on it.

It takes two minutes and needs **no terminal at all** — it's entirely in the
GitHub website:

1. Open **[SHOWCASE.md](../SHOWCASE.md)** in this repository.
2. Click the **pencil icon** (top right of the file).
3. GitHub says *"You need to fork this repository to propose changes"* — click
   **Fork this repository**. That makes your own copy; you're not editing mine.
4. Add one row to the bottom of the table:

   ```markdown
   | [Tide Clock](https://tide-clock.example.com) | Today's tide times for your nearest beach | Track A | [repo](https://github.com/you/tide-clock) |
   ```

5. Click **Commit changes…**, write a short message, choose **Create a new
   branch and start a pull request**.
6. Click **Propose changes**, then **Create pull request**.

Done. You've made a pull request. If that's your first one, then the first
open-source contribution you ever made was to a project about making your first
open-source contribution, which is a pleasing shape.

I merge these quickly. If something's wrong I'll say so in the PR rather than
just closing it.

> **Prefer the terminal?**
> ```bash
> gh repo fork jhammant/ship-what-you-built --clone
> cd ship-what-you-built
> # edit SHOWCASE.md
> git checkout -b add-my-project
> git commit -am "Add Tide Clock to showcase"
> gh pr create --fill
> ```

---

## 4. Post it

You built a thing, and it works, and it's on the internet at an address you own.
That's genuinely worth saying out loud.

What works, briefly:

- **Lead with the thing, not the process.** "I built a tide clock for my
  kitchen wall" beats "I've been learning about CloudFront."
- **Put the link in the post, not the first comment.** The preview card you just
  set up is the whole point.
- **Say what surprised you.** The bit you got stuck on is the most useful and
  most relatable part, and it's what other people reply to.
- **Show the screenshot.** Every time.
- **Say it's open source and link the repo.** People do click through, and it's
  how the stars happen.

If it helps, tag the guide or link it — I'd like to see what people build, and
it's how anyone else finds their way here.

---

**Something broken?** [When it breaks →](90-troubleshooting.md)
