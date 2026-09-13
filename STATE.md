# Ship What You Built — state as of 2026-09-14

## What this is
A beginner guide (`guide/*.md`, rendered to `site/guide/` by
`tools/build-guide.py`) plus Claude Code skills for getting a project online at
a real domain. Live at https://shipwhatyoubuilt.com, deployed by
`.github/workflows/deploy.yml` on any push to `main` touching `site/**`.

## Where it stands
Done:
- **learn-alongside skill** (`learn-alongside/SKILL.md`, commit `00ba749`), from
  a reader's suggestion: at each concept new to the user, a short block (what it
  is, why it mattered, a read-only command to try, a verified doc, a YouTube
  *search* link) plus a watch list in `~/learning/<project>.md`.
- Guide section "Learn alongside it" in `guide/08-let-claude-drive.md`, README
  install note, site HTML rebuilt. Deployed and verified live (page 200, anchor
  `#learn-alongside-it` present, skill file reachable on GitHub).
- Tested headless in a throwaway dir: Sonnet invokes the skill from "teach me as
  we go" and follows it end to end. Haiku did not invoke it unprompted, so the
  guide tells readers to name the skill.

In progress: nothing.

Broken or blocked: nothing. Deploy log warns that `actions/checkout@v4` and
`aws-actions/configure-aws-credentials@v4` run on deprecated Node 20.

## Next steps
1. Post the reply to the LinkedIn comment (drafted, on the clipboard at close),
   ideally with the link to `/guide/08-let-claude-drive.html#learn-alongside-it`.
2. Bump the two GitHub Actions to Node 24-based versions before GitHub removes
   Node 20.
3. Optionally retest the skill on Opus and against a real deploy, not just a
   `dig` lookup.

## Open questions
- Credit the commenter by name in the guide? It currently says "suggested by a
  reader".
- Should the first-site skill hand off to learn-alongside automatically when the
  user's handover says "I want to understand it"?

## Ideas worth keeping
- **Search links, not content links, for anything the model can't verify.** A
  recalled video URL is often invented or dead; a search URL is never either.
- **A watch list outside the repo doubles as memory of what the user knows** —
  check it before explaining, so nothing is taught twice, and it can never be
  committed into a public project.
- **Test skills with a headless run on the smallest model you support.**
  Triggering from the description alone is model-dependent.

---
_Updated by `forkcode close` on 2026-09-14T00:55+01:00_
