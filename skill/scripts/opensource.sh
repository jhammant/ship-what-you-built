#!/usr/bin/env bash
#
# opensource.sh — get a project ready to be a public repository, in two phases.
#
# Phase 1 (default) prepares everything and stops before the first commit.
# Phase 2 (--publish) creates the GitHub repo and pushes.
#
# The gap between them is deliberate: a first commit is permanent, so a human
# looks at it.
#
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
opensource.sh — prepare a project for a public GitHub repository

USAGE
  opensource.sh [--name NAME] [--author "Your Name"] [--dry-run]
  opensource.sh --publish --repo OWNER/NAME [--private] [--dry-run]

PHASE 1 — prepare (the default)
  · git init, if needed
  · write .gitignore, if there isn't one
  · write LICENSE (MIT), if there isn't one
  · stage everything
  · run preflight.sh
  · STOP, and tell you what to look at

  It never commits. That step is yours.

PHASE 2 — publish (--publish)
  · create the GitHub repository
  · turn on secret scanning and push protection
  · push
  Requires at least one commit to exist.

OPTIONS
  --name NAME       Repository name (default: this directory's name)
  --author NAME     Name for the LICENSE (default: git config user.name)
  --repo OWNER/NAME Where to publish. Required with --publish
  --private         Create it private instead of public
  --dry-run         Print what would happen; change nothing
  -h,--help         This text

SAFE TO RUN TWICE. It never overwrites an existing .gitignore, LICENSE or
README, and it never force-pushes.

EXAMPLES
  opensource.sh --dry-run
  opensource.sh --author "Ada Lovelace"
  git commit -m "Initial commit"
  opensource.sh --publish --repo ada/tide-clock
EOF
}

NAME=""; AUTHOR=""; REPO=""; DRY=0; PUBLISH=0; VISIBILITY="--public"
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)  usage; exit 0 ;;
    --name)     NAME="${2:?--name needs a value}"; shift 2 ;;
    --author)   AUTHOR="${2:?--author needs a value}"; shift 2 ;;
    --repo)     REPO="${2:?--repo needs a value}"; shift 2 ;;
    --private)  VISIBILITY="--private"; shift ;;
    --publish)  PUBLISH=1; shift ;;
    --dry-run)  DRY=1; shift ;;
    *)          die "Unknown option: $1 (try --help)" ;;
  esac
done

run() {
  if [ "$DRY" = "1" ]; then
    dim "  would run: $*"
  else
    "$@"
  fi
}

write_file() {
  local path="$1"
  if [ -e "$path" ]; then
    ok "$path already exists — left alone"
    cat >/dev/null   # swallow the heredoc
    return
  fi
  if [ "$DRY" = "1" ]; then
    dim "  would create: $path"
    cat >/dev/null
  else
    cat > "$path"
    ok "created $path"
  fi
}

[ "$DRY" = "1" ] && head1 "DRY RUN — nothing will change"

# ============================================================ PHASE 2: publish
if [ "$PUBLISH" = "1" ]; then
  [ -n "$REPO" ] || die "--publish needs --repo OWNER/NAME"
  have gh || die "GitHub CLI not installed. See guide/05-github.md step 1."
  gh auth status >/dev/null 2>&1 || die "Not logged in. Run: gh auth login"
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not a git repository. Run phase 1 first."
  git rev-parse HEAD >/dev/null 2>&1 || die "No commits yet. Commit first — that step is deliberately yours."

  head1 "Publishing to github.com/$REPO"

  if gh repo view "$REPO" >/dev/null 2>&1; then
    ok "repository already exists"
    if ! git remote get-url origin >/dev/null 2>&1; then
      run git remote add origin "https://github.com/$REPO.git"
    fi
    run git push -u origin HEAD
  else
    run gh repo create "$REPO" $VISIBILITY --source=. --remote=origin --push
  fi

  if [ "$VISIBILITY" = "--public" ]; then
    head1 "Safety nets"
    if [ "$DRY" = "1" ]; then
      dim "  would enable secret scanning and push protection"
    else
      if gh repo edit "$REPO" --enable-secret-scanning \
           --enable-secret-scanning-push-protection >/dev/null 2>&1; then
        ok "secret scanning + push protection on"
      else
        warn "couldn't enable secret scanning — turn it on in Settings → Code security"
      fi
    fi
  fi

  head1 "Done"
  say "  https://github.com/$REPO"
  dim "  Next: add topics (Settings → About → Topics) and a screenshot in the README."
  dim "  See guide/30-share-it.md — then add yourself to the showcase."
  exit 0
fi

# ============================================================ PHASE 1: prepare
NAME="${NAME:-$(project_slug)}"
if [ -z "$AUTHOR" ]; then
  AUTHOR="$(git config user.name 2>/dev/null || true)"
  AUTHOR="${AUTHOR:-Your Name}"
fi
YEAR="$(date +%Y)"

head1 "Preparing $NAME"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  ok "already a git repository"
else
  run git init -b main
  [ "$DRY" = "1" ] || ok "git repository created"
fi

write_file .gitignore <<'EOF'
# Secrets — never commit these
.env
.env.*
!.env.example
*.pem
*.key
credentials.json
secrets.*

# Dependencies — large, and rebuildable from the lockfile
node_modules/
venv/
.venv/
__pycache__/

# Build output — regenerated on every deploy
dist/
build/
out/
.next/
.cache/
_site/
public/build/

# Local noise
.DS_Store
Thumbs.db
*.log
.vscode/
.idea/

# Local databases
*.sqlite
*.sqlite3
*.db
EOF

write_file LICENSE <<EOF
MIT License

Copyright (c) $YEAR $AUTHOR

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

if [ -f .env ] && [ ! -f .env.example ]; then
  if [ "$DRY" = "1" ]; then
    dim "  would create .env.example (names only, values blanked)"
  else
    # Names only, and ONLY from lines that are a simple NAME= assignment.
    # A blanket 's/=.*/=/' copies comments and every continuation line of a
    # multi-line value (a PEM private key, a certificate) verbatim into a file
    # that is staged for the first public commit — and preflight can't catch it,
    # because the "-----BEGIN … KEY-----" line is the one that got stripped.
    grep -E '^[A-Za-z_][A-Za-z0-9_]*=' .env | sed 's/=.*/=/' > .env.example
    ok "created .env.example — variable names only, every value dropped"
    dim "  Read it before committing; only simple NAME=value lines were carried over."
  fi
fi

run git add -A

head1 "Preflight"
PREFLIGHT_RC=0
if [ "$DRY" = "1" ]; then
  # Dry-run skipped the git init, so preflight would report "not a git
  # repository" and fail — the script raising a false alarm about itself on
  # the very first command the guide asks a beginner to run.
  dim "  would run preflight.sh once the repository exists"
else
  "$SCRIPT_DIR/preflight.sh" || PREFLIGHT_RC=$?
fi

head1 "Over to you"
if [ "$PREFLIGHT_RC" -ne 0 ]; then
  bad "Preflight found things. Deal with those before committing."
  say ""
fi
say "  Look at what's about to be committed:"
dim "    git status"
dim "    git diff --cached"
say ""
say "  Then commit — this is the permanent bit, so it's deliberately yours:"
dim "    git commit -m \"Initial commit\""
say ""
say "  Then publish:"
dim "    $(basename "$0") --publish --repo <your-github-username>/$NAME"
say ""
exit "$PREFLIGHT_RC"
