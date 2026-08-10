# Contributing

Two kinds of contribution, and the first one is the one I actually want.

---

## Add your project to the showcase

You followed the guide, your thing is live — put it on
**[SHOWCASE.md](SHOWCASE.md)**.

The only rule is that **the URL has to load**. It doesn't have to be polished,
finished, or impressive. Half-finished things that work are the best entries.

### The two-minute way (no terminal)

1. Open **[SHOWCASE.md](SHOWCASE.md)**.
2. Click the **pencil icon**, top right of the file.
3. GitHub says *"You need to fork this repository to propose changes"* — click
   **Fork this repository**. That makes your own copy. You aren't editing mine,
   and you can't break anything.
4. Add one row at the bottom of the table, above the comment block:

   ```markdown
   | [Tide Clock](https://tide-clock.example.com) | Today's tide times for your nearest beach | A | [repo](https://github.com/you/tide-clock) |
   ```

5. **Commit changes…** → **Create a new branch and start a pull request** →
   **Propose changes** → **Create pull request**.

That's it. If that was your first pull request: congratulations, you're now an
open-source contributor, and it happened in a browser tab.

### The terminal way

```bash
gh repo fork jhammant/ship-what-you-built --clone
cd ship-what-you-built
git checkout -b add-my-project
# edit SHOWCASE.md
git commit -am "Add <project> to showcase"
gh pr create --fill
```

### What I'll do

Merge it, usually within a day or two. If something needs changing I'll say so
in the pull request rather than just closing it — the point of this repo is that
the process isn't scary.

**What gets turned away:** dead links, anything that's purely an advert with no
working thing behind it, and anything hostile. That's the whole list.

---

## Fix or improve the guide

Cloud providers rename menus, change free tiers and deprecate runtimes
constantly. A guide like this is wrong somewhere within months of being written,
and I'd rather know.

**Especially welcome:**

- **"This step doesn't match what I see."** Screenshot or exact wording, please.
- **A step that failed**, with the complete error text.
- **A price or free-tier limit that's now wrong.**
- **A gotcha that cost you an hour** and isn't in the troubleshooting page. These
  are the most valuable contributions here — every one saves somebody else that
  hour.
- **A third track.** Fly.io, Vercel, Railway and Netlify are all reasonable
  answers for [Shape 3](guide/02-start-here.md#the-honest-note-about-shape-3).
  If you want to write one, open an issue first so we can agree the shape before
  you spend an evening on it.

### House style

The guide has a voice. Roughly:

- **Say why, not just what.** "Run this command" teaches nothing. "Run this
  command, because X" means they can debug it at 11pm without you.
- **Name the failure mode.** Every step that can go wrong should say what going
  wrong looks like.
- **Assume no prior knowledge, but no stupidity.** The reader has never set up
  DNS. They are not an idiot. Those are different things.
- **Don't hardcode prices.** Give the shape and link to the live pricing page.
- **Label your code fences** — ` ```bash `, ` ```yaml `, ` ```text `. Never a
  bare ` ``` `.
- **British spelling**, though honestly nobody will mind.

### Testing a change

If you change a command, **run it**. If you change a script, run it with
`--help` and `--dry-run` and then for real. A guide that confidently gives you a
command that doesn't work is worse than no guide.

---

## Reporting a security problem

If you find something in this repo that leaks credentials, weakens someone's
account, or teaches an unsafe pattern, please open an issue — there's nothing
secret in here, so there's no need for private disclosure. Unsafe advice in a
beginner guide is a real bug and I'll treat it as one.

---

## Code of conduct

Be decent. This repo exists so that people who feel out of their depth can ship
something, and the fastest way to ruin that is to make someone feel stupid for
asking. Condescension gets moderated the same as abuse.
