# Come up with something to build

**This page gets you one idea, small enough to finish, written down in a few
lines you can hand straight to your agent — about ten minutes reading, then
twenty or thirty deciding, most of it in conversation rather than in a text
editor.**

You've got an agent installed and signed in
([Get an AI coding agent](00-install-claude-code.md)) and an empty folder. This
is the part nobody warns you about.

---

## The blank folder is the hardest part of this guide

Everything after this page is mechanical. Domains, certificates, deploys — they
look intimidating and they are, at worst, fiddly. There is a right answer and
this guide has it.

This page has no right answer, which is why it's harder.

Here's the thing worth knowing before you start: when people say **"I can't
think of anything to build"**, they almost never mean it literally. They mean
*"I can't think of anything impressive."* Every idea that arrives gets measured
against a product built by forty people over three years, found wanting, and
quietly binned. Then the folder stays empty and the conclusion is "I'm not
creative", which is the wrong conclusion drawn from the wrong test.

So change the test. **The goal of a first project is not to impress anyone. It
is to finish and ship.** You are learning a pipeline — idea, code, repo, domain,
live URL — and you learn it exactly as well with a small thing as with a large
one. The difference is that you actually finish the small thing.

A tide clock that exists beats a social network that doesn't. It isn't close.

The failure mode here isn't an error message. It's a folder you stop opening,
and a slow drift back to thinking this stuff isn't for you. That's what we're
avoiding, and small is how.

---

## Where ideas actually come from

Not from staring at the ceiling. From five places, all of which are already in
your life.

### 1. Something you do repeatedly, by hand

The strongest signal there is. If you've done a thing three times with a
calculator, a scrap of paper, or a search engine, you've found a tool that
should exist.

Look for: a recurring calculation, a checklist you rebuild from memory, a
conversion you get wrong, something you keep re-googling because it never
sticks.

- **A recipe scaler.** Type the recipe, type "for 7 people", get the amounts
  back with sane rounding — because 1.75 eggs is not a measurement.
- **A dilution calculator.** Concentrate, target strength, container size, out
  comes the number of millilitres. Anyone who mixes cleaning fluid, plant feed,
  or coffee syrup does this arithmetic monthly and gets it wrong annually.
- **A pace and finish-time page for runners.** Distance and target time in,
  per-kilometre pace out, and the reverse.

### 2. Something living in a spreadsheet or the notes app

A spreadsheet is a tool that hasn't been built yet. So is a note that has grown
a structure — a list where every line has the same three parts.

If you find yourself maintaining a format by hand, that format is a design
document someone already wrote for you.

- **A reading-list tracker.** Title, who recommended it, whether you finished
  it. It's twelve lines of a note. It could be a page that sorts and filters.
- **A rota generator.** Names in, weeks out, nobody gets two Saturdays in a
  row. Currently a colour-coded spreadsheet that one person maintains and
  everyone else squints at.
- **A scoreboard for whatever card game your household plays.** With that one
  house rule that no generic scorer supports.

### 3. A thing you wanted and couldn't find — or found, and it was bloated

You went looking for a small tool. What you found wanted an account, showed you
adverts, and buried the one number you came for under a newsletter prompt.

That gap is a real product. "Same thing, one screen, no sign-up" is a
legitimate reason for software to exist and always has been.

- **A tide clock.** A single page that says whether the tide is coming in or
  going out at one specific beach, in words, right now.
- **A print-size calculator for photographers.** Sensor and pixel dimensions in,
  the largest sensible print size out, no shop attached.
- **A countdown to a date that matters.** Big number, nothing else, works when
  you open it, sits in a browser tab.

### 4. Something for one specific person

This is a genuinely excellent first project and it gets dismissed because it
feels too small. It is the opposite of too small — it's the only category where
you start with something most professional teams spend months buying: **a real
user, in the room, who will tell you the truth within the hour.**

You don't have to guess what's useful. You can ask. And "it's for one person" is
permission to leave out everything a general audience would need.

- A bike-gear ratio page for the friend who has opinions about gearing, with
  their exact bike's numbers already filled in.
- A five-a-side team page for whoever currently organises it in a group chat:
  who's playing this week, and the bibs-versus-skins split.
- A tuning and capo reference for someone learning an instrument, showing only
  the keys they actually play.

Ship it, watch them use it, fix the thing they stumbled on. That loop is the
entire craft, learned in one evening.

### 5. Learning something by building the smallest version of it

If there's a technique you want to understand — how maps work, how a calendar
handles time zones, how audio gets into a browser — the smallest working version
teaches you more than a fortnight of reading, and leaves you with a URL.

The trick is to keep "smallest" honest. Not "a mapping app". One map, one pin,
one thing the pin tells you.

- **A unit converter for one specific hobby** — brewing gravities, climbing
  grades, film stock speeds. Narrow enough that you have to learn the domain,
  small enough to finish.
- **A "what should I cook" picker.** You enter what's in the cupboard, it picks
  one thing and commits, because the actual problem is deciding, not searching.
- **A split-the-bill page.** Ten people, some drank, some didn't, one person
  paid. Everyone has done this badly on a phone in a loud restaurant.

> **Still empty?** Skip to
> [the interview prompt](#prompt-1--find-the-repeated-work-you-cant-see) below.
> Your agent is much better at spotting the repetitive bits of *your* week than
> you are, because you stopped noticing them years ago.

---

## What makes a good first project

Not "a good idea" — a good *first* one. These are constraints, and constraints
are what make finishing likely. Each one removes an entire category of work you
would otherwise discover halfway through.

**One screen.** Every extra screen adds navigation, state to keep in step, and a
decision about what someone sees if they land on the third screen directly. One
screen is a thing you can hold in your head and therefore finish.

**No login.** Accounts mean passwords, resets, email that has to arrive, and
you personally becoming responsible for other people's personal data. It also
drags you off the cheap hosting path immediately. Ship one thing first. Have
accounts be your second project, deliberately, not your first one by accident.

**No payments.** Taking money means identity checks, a merchant account,
refunds, tax, and a plan for fraud. All of that is learnable. None of it belongs
in evening one.

**No user-generated content you'd have to moderate.** The moment strangers can
post, you own a moderation job — unpaid, permanent, and beginning with spam not
long after anyone finds it. If people need to enter data, let it stay on
their own machine rather than arriving in your inbox.

**Data that fits in the page, or in local storage.** *Local storage* is a small
box the browser keeps for your site, on that one device — no server, no
database, nothing to back up. Be honest about the trade in the interface:
clearing browsing data or opening it on a different device loses what's there.
One line of text ("saved on this device only") turns a bug report into an
understood limitation.

**Useful on the first visit, with nothing set up.** This one is quietly the most
important. A tracker with nothing in it is a blank box that asks the visitor to
do work before they get anything. Ship with sensible defaults, or example data,
or a result that appears the instant the page loads. Otherwise the honest
description of your project is "it works, once you've spent five minutes typing".

### Why these particular rules

Because together they keep you in **Shape 1 — a static site**: files that a
browser can open, with nothing of yours left running anywhere.
[Start here](02-start-here.md#shape-1--a-static-site) explains the shapes
properly, but the short version is that Shape 1 is the fastest thing to deploy,
the cheapest to keep up, and the only one with nothing that can fall over at
three in the morning. On Track A that's roughly twenty minutes from folder to
live URL, with the domain as the only standing cost you'd normally notice —
[Start here](02-start-here.md#question-2--which-track) has the figures for both
tracks, and it's worth checking them against the hosts' own pricing pages,
because free tiers move.

Every constraint you break above moves you toward something with a server in it,
which is fine — later, on purpose, once you've been round the loop once.

---

## What makes a bad first project

Said plainly, because the kind thing here is to be direct rather than
encouraging.

**"A social network for X."** On day one it is an empty room, and an empty room
is not usable, so you can't test it, so you can't tell whether it's any good. It
also bundles every hard problem at once: accounts, feeds, notifications,
moderation, abuse.

**Anything needing accounts and passwords.** See above. You become the custodian
of other people's credentials before you've deployed anything once.

**Anything needing a continuously running server or a real database on day one.**
That's Shape 3 in
[Start here](02-start-here.md#the-honest-note-about-shape-3), and it's the one
where free tiers stop fitting. Something that must stay running is something that can be
down, and now you're on call for it, alone, for a project nobody is using yet.

**Anything whose value only appears at scale.** Marketplaces, dating apps,
ride-sharing, "the network effect kicks in at a thousand users". These are
genuinely hard businesses, not hard software, and no amount of evening coding
solves the empty-side-of-the-market problem.

**Clones of large products.** "Notion but simpler", "Spotify for podcasts",
"Photoshop in the browser". From outside, mature products look like a weekend's
work — that smoothness is years of work by a large team, and it's invisible on
purpose. Building against that comparison means measuring one evening's output
against a company, which is a reliable way to finish nothing.

### What to do instead

Don't abandon the idea. **Find the one screen of it that is useful on its own,
to one person, today — and build only that.**

| The big idea | The one screen worth building |
|---|---|
| A social network for runners | A page that turns your last run into a shareable image |
| A recipe site with accounts and saving | A recipe scaler with three recipes hardcoded |
| A project manager for small teams | A stand-up timer that goes round the names |
| A marketplace for second-hand gear | A "what's this worth" calculator for one category |

That screen is a finished thing you can show people. If it turns out to have
legs, the big version is still available to you, and you'll build it far better
having shipped something first.

---

## Using your agent to find and sharpen the idea

Your **agent** — the coding assistant you installed in
[Get an AI coding agent](00-install-claude-code.md) — is genuinely useful here,
but only if you use it the right way round.

**The technique:** an agent is far better at *cutting* than at *inventing*. Ask
it cold for app ideas and you get a plausible, forgettable list — a to-do app, a
habit tracker, a recipe site — because with nothing to go on it returns the
average of everything ever written about side projects. That list is why people
conclude this doesn't work.

Give it raw material instead — your week, your annoyance, your spreadsheet — and
ask it to *reduce*. Editing is where it's strong. Every prompt below is a
different flavour of "here's something rough, make it smaller".

Run these inside your project folder, in a conversation, before any code exists.

### Prompt 1 — Find the repeated work you can't see

For when the folder is empty and nothing has occurred to you. It works because
you've stopped noticing your own routines, and it hasn't.

```text
I want to build a small web tool, but I can't think of what.

Interview me. Ask me one question at a time — no more than eight in total —
about my week: what I do repeatedly by hand, what I keep in a spreadsheet or
a note, what I re-google, what I've complained about recently, and anything
I've wanted to exist and couldn't find.

Don't suggest anything until you've finished asking. Then give me five
candidates drawn only from my actual answers, each in one sentence, and say
for each one why you think it's a real repeated task rather than a nice idea.
```

Answer briefly and honestly, including the boring answers. The boring answers
are where the repeated work hides.

### Prompt 2 — Cut a vague idea down to its smallest useful version

For when you have something, but it's a cloud rather than a thing. Note the last
line: making it state what it dropped stops it quietly agreeing with you and
handing back the same large idea in tidier language.

```text
Here's my rough idea: <describe it in two or three sentences>.

Cut it down to the smallest version that is still genuinely useful to one
person on their first visit. Constraints: one screen, no login, no payments,
no user accounts, no server — data lives in the page or in browser local
storage.

Give me: (a) the cut-down version in three sentences, (b) an explicit list of
what you dropped, and (c) anything you dropped that you think I'll regret
dropping, and why.
```

### Prompt 3 — Stress-test the scope before you commit

Run this even when you're sure. It's the cheapest twenty seconds in the whole
guide, and it catches the "innocuous feature that is secretly three days" —
which is a thing every one of these ideas has exactly one of.

```text
This is what I'm planning to build: <paste the cut-down version>.

I have two evenings. What would make this take a week instead of an evening?
List the specific things in this plan that look small and aren't, with the
reason each one grows. Then tell me exactly what to cut to fit two evenings,
and what the thing still does after the cuts.
```

Watch for the usual suspects: dates and time zones, uploading files, anything
"real-time", anything that needs data from somebody else's website, and printing.

### Prompt 4 — Turn the agreed idea into a short brief

Do this last, and keep the output. A brief written while you're thinking clearly
is worth a great deal at the point where you're deep in the build and
rediscovering what you meant.

```text
We've agreed on this idea: <the final version>.

Write it to BRIEF.md in this folder. Keep it under 200 words, plain English,
no code. Include: what it does in one sentence, who it's for, the three things
it must do, an explicit "not doing" list, and what "finished" means so I can
tell when I've got there.
```

`BRIEF.md` is a plain text file in your project folder. When you start building
— and again when you reach [Let Claude drive](08-let-claude-drive.md) — point
the agent at it. It's also the thing you reread when you catch yourself adding a
settings screen at eleven at night.

---

## The two-evening rule

**If you can't get a usable version in two evenings, the idea is too big.**

"Usable" has a specific meaning here: you would genuinely use it yourself, once,
for real, without apologising for it first. Not finished. Not pretty. Usable.

When the rule bites, cutting is the correct response, and it's worth saying out
loud that cutting is a skill rather than a defeat. Deciding what a thing *isn't*
is most of what experienced people do, and it's the part that never appears in
tutorials. Practising it on something with no stakes is a good use of an evening.

A worked example. Here's the idea as it first arrives:

> **Before:** An app for planning group holidays. Everyone signs in, votes on
> dates, adds destinations, splits the costs, chats about it, and there's a
> shared itinerary and a packing list.

Weeks of work, most of it accounts, invitations and permissions, none of which is
the interesting part. Now cut it to the one screen that was doing the real work:

> **After:** One page. You paste in everyone's available dates, it shows the
> weekends that work for the most people, and highlights who's missing from
> each. No accounts — the state lives in the URL, so you share the link.

That's an evening, possibly two. It solves the actual painful bit — the bit that
currently takes forty messages in a group chat. And it's usable by one person on
first visit, which means you can find out tonight whether it's any good.

The costs, the chat and the packing list can follow if the date-picker turns out
to be something people want. Usually you discover they were never the point.

---

## Now pick one

You do not need the best idea. You need **an** idea, chosen in the next ten
minutes, that fits the constraints above.

If two are still tied, take the one with a real person attached — the friend,
the colleague, the team. Feedback beats cleverness, and you'll get it the same
week.

Then open the folder and start. When it's live, add it to the
[showcase](../SHOWCASE.md): a line, a URL, what it does. Everything on that list
was somebody's small idea that got finished, and none of them looked like much
in the folder either. Yours belongs there too.

---

**Next:** [Start here →](02-start-here.md)
