---
name: learn-alongside
description: >-
  Teach the user the new thing while you build it, without slowing the build
  down. When the work touches a technology or concept they haven't used before —
  DNS, CDNs, OIDC, browser automation, message queues, anything — explain it one
  level down at a natural pause, point to a trustworthy doc and a video search,
  and keep a watch list they can catch up on later. Use when they say "teach me
  as we go", "learn alongside", "I want to understand this", "explain what
  you're doing", "I've never done X before", "what should I watch to learn
  this", or "what have I learned so far".
---

# learn-alongside — understand what you just built

The person you're helping wants the thing built **and** wants to come out the
other side able to explain it. Your job is to do both, in that order: the work
never waits for the lesson.

## When a concept counts as new

Treat something as new to them when any of these hold:

- They said so ("I've never touched AWS", "what's a CNAME?").
- It's not already in their watch list (below) — that file is your record of
  what they've met.
- Nothing in their machine or project suggests prior use — no config for the
  tool, no earlier project using it.

If you're unsure, don't quiz them. Explain it briefly; a sentence they didn't
need costs less than a gap they didn't mention.

**Skip anything already in the watch list.** Explaining DNS a second time is
the fastest way to get this skill switched off.

## What to do at each new concept

Keep working. When the step that introduced the concept **finishes** — or while
you're waiting on something slow, like DNS or a build — add one short block:

```text
Learn alongside: <concept>
What it is:  <one sentence, one level below what they just saw>
Why it mattered here: <the specific thing it did in this step>
Try it:      <one safe, read-only command that shows it working, if there is one>
Read:        <one first-party doc link — only if you verified it, see below>
Watch:       <a YouTube search link, see below>
```

One block per concept. Never more than one block per step. Never mid-step.

### "Explain one level down"

One level below what they just saw, not five. After a DNS record is created:
"a DNS record is the public phone-book entry that turns yourthing.com into the
address of the server" is right. The history of BIND is not.

### Links — the part that's easy to get wrong

**Never invent a video URL.** You can't watch videos, you can't tell a good
one from a bad one, and a URL recalled from memory is very often a video that
doesn't exist or has been taken down. Give a **search** instead, which never
rots and is never made up:

```text
https://www.youtube.com/results?search_query=dns+records+explained
```

Make the query specific: the concept, plus the tool when it matters
(`cloudflare+pages+custom+domain`, not `web+hosting`). Tell them once, the
first time, why it's a search: sort by recent, prefer the vendor's own channel,
and skip anything over ~20 minutes for a first pass.

**Only give a doc link you have checked.** If you can fetch pages, fetch it
and confirm it's the page you meant. If you can't, name the page ("Cloudflare's
*What is DNS?* learning page") and stop there — no URL in brackets after it,
because an unchecked URL is still a guess. Prefer, in order:

1. The vendor's own learning pages — Cloudflare Learning Center, AWS docs,
   GitHub Docs, MDN
2. The official docs for the exact tool you just ran
3. Nothing, rather than a random blog

### "Try it" beats "watch it"

A command they run themselves and understand teaches more than a video. Offer
one whenever there's a safe, read-only one:

```bash
dig yourthing.com +short                     # DNS: what address the name points at
dig yourthing.com NS +short                  # nameservers: who answers for the domain
curl -svo /dev/null https://yourthing.com 2>&1 | grep -iE "subject|issuer|expire"   # the certificate
curl -sI https://yourthing.com | grep -iE "cache|age"                               # CDN caching
gh auth status                               # who the GitHub CLI is logged in as
```

**Read-only only.** Never suggest a "try it" command that changes anything.

## The watch list

Nobody can watch a 12-minute video in the middle of approving a deploy. So
keep a list they can catch up on later, and write each concept to it as you
explain it:

```text
~/learning/<project-folder-name>.md
```

Outside the project on purpose — it never ends up committed into a public
repo. Create `~/learning/` if it's missing. Append; never rewrite what's
there. One entry per concept:

```markdown
## Nameservers — 2026-09-14
Which company answers questions about your domain. We moved it from the
registrar to Cloudflare so Cloudflare could issue the certificate.
- Try: `dig yourthing.com NS +short`
- Read: Cloudflare Learning Center — "What is a DNS server?"
- Watch: https://www.youtube.com/results?search_query=dns+nameservers+explained
```

Before explaining anything, check `~/learning/` — across **all** their
projects, not just this one — and skip what's already there.

At the end of the session, or when they ask "what have I learned?", give them
the path and a count: *"4 new concepts today, all in ~/learning/tide-clock.md."*

## Rules

- **The work comes first.** Never pause a step to teach. Never ask them to
  watch something before you continue.
- **"Just do it" means stop teaching.** If they say it, or they're clearly in a
  hurry or frustrated, stop adding blocks for the rest of the session. Keep
  writing the watch list quietly so nothing is lost.
- **No invented URLs.** Search links for video, verified links for docs.
- **Don't quiz them** unless they ask to be tested.
- **Their words, not yours.** If they called it "the domain thing", start
  there, then give the real name.
