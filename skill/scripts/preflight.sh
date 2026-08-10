#!/usr/bin/env bash
#
# preflight.sh — the check to run before a repository becomes public.
#
# Read-only. Changes nothing, ever. Publishing is permanent, so this looks for
# the things that can't be taken back.
#
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
preflight.sh — look for anything you'd regret publishing

USAGE
  preflight.sh [DIR] [--staged] [--quiet]

ARGUMENTS
  DIR        Project directory (default: current directory)

OPTIONS
  --staged   Check only what is staged for the next commit, rather than every
             tracked file. Useful as a last look before `git commit`.
  --quiet    Print findings only — no "all clear" lines.
  -h,--help  This text.

WHAT IT CHECKS
  1. Credential-shaped FILES that are tracked by git (.env, *.pem, *.key)
  2. Credential-shaped STRINGS inside tracked files (AWS, OpenAI, Anthropic,
     GitHub, Stripe, Google, Slack keys, and private key blocks)
  3. Whether .env ever appeared in git history, even if deleted since
  4. Whether .gitignore actually covers .env
  5. Files big enough to suggest something unintended got committed
  6. Whether your real email address is going into commits

EXIT CODES
  0  nothing found
  1  findings — read them before you push
  2  not a git repository

IT IS NOT A GUARANTEE. It catches known key formats and obvious mistakes. It
cannot know that `config.js` line 40 is your neighbour's address. Read your own
diff as well.
EOF
}

TARGET="."; STAGED=0; QUIET=0
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --staged)  STAGED=1; shift ;;
    --quiet)   QUIET=1; shift ;;
    -*)        die "Unknown option: $1 (try --help)" ;;
    *)         TARGET="$1"; shift ;;
  esac
done

[ -d "$TARGET" ] || die "Not a directory: $TARGET"
cd "$TARGET"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  bad "Not a git repository. Run 'git init' first, or see guide/05-github.md."
  exit 2
}

FINDINGS=0
found() { FINDINGS=$((FINDINGS + 1)); }
clear_() { [ "$QUIET" = "1" ] || ok "$*"; }

if [ "$STAGED" = "1" ]; then
  FILE_LIST="$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)"
  SCOPE="staged for commit"
else
  FILE_LIST="$(git ls-files 2>/dev/null || true)"
  SCOPE="tracked by git"
fi

if [ -z "$FILE_LIST" ]; then
  warn "Nothing is $SCOPE yet — run 'git add .' first, then check again."
  exit 0
fi

head1 "1. Credential-shaped files ($SCOPE)"
# .env.example / .env.sample / .env.template are meant to be committed — they
# carry names, not values. opensource.sh creates one deliberately and whitelists
# it in .gitignore, so flagging it made the toolchain condemn its own output.
RISKY="$(printf '%s\n' "$FILE_LIST" \
  | grep -Ei '(^|/)\.env($|\.)|\.pem$|\.key$|\.p12$|\.pfx$|(^|/)id_rsa|credentials\.json$|(^|/)secrets?\.(json|ya?ml|txt)$' \
  | grep -Eiv '\.(example|sample|template|dist)$' \
  || true)"
if [ -n "$RISKY" ]; then
  bad "These are $SCOPE and should almost certainly not be:"
  printf '%s\n' "$RISKY" | sed 's/^/    /' >&2
  dim "    Fix:  git rm --cached <file>   then add it to .gitignore"
  found
else
  clear_ "no .env / .pem / .key files $SCOPE"
fi

head1 "2. Credential-shaped strings"
# Each pattern is prefix + required length, so this file never matches itself.
PATTERNS='AKIA[0-9A-Z]{16}
ASIA[0-9A-Z]{16}
sk-ant-[A-Za-z0-9_-]{24,}
sk-proj-[A-Za-z0-9_-]{24,}
sk-[A-Za-z0-9]{32,}
gh[pousr]_[A-Za-z0-9]{30,}
github_pat_[A-Za-z0-9_]{30,}
xox[baprs]-[A-Za-z0-9-]{10,}
(sk|rk)_live_[A-Za-z0-9]{20,}
AIza[0-9A-Za-z_-]{35}
-----BEGIN [A-Z ]*PRIVATE KEY-----'

HITS=""
while IFS= read -r pat; do
  [ -n "$pat" ] || continue
  # -e matters: several patterns begin with '-' and would be read as options.
  if [ "$STAGED" = "1" ]; then
    h="$(git diff --cached -U0 | grep -E -e '^\+' | grep -nE -e "$pat" || true)"
  else
    h="$(git grep -nIE -e "$pat" -- . 2>/dev/null || true)"
  fi
  [ -n "$h" ] && HITS="${HITS}${h}"$'\n'
done <<< "$PATTERNS"

# The scanner's own pattern list is not a finding.
HITS="$(printf '%s' "$HITS" | grep -v 'skill/scripts/preflight.sh' || true)"

if [ -n "$HITS" ]; then
  bad "Something matches a known key format:"
  # REDACT before printing. This output lands in the terminal, the shell
  # scrollback and any transcript — printing the live key in full would widen
  # exactly the leak this script exists to contain. Enough prefix is kept for
  # the user to recognise which key it is.
  printf '%s\n' "$HITS" | head -20 | cut -c1-200 \
    | sed -E 's/(AKIA|ASIA)[0-9A-Z]{16}/\1‹REDACTED›/g;
              s/(sk-ant-|sk-proj-|sk-|gh[pousr]_|github_pat_|xox[baprs]-|AIza)[A-Za-z0-9_-]{6,}/\1‹REDACTED›/g;
              s/((sk|rk)_live_)[A-Za-z0-9]{6,}/\1‹REDACTED›/g' \
    | sed 's/^/    /' >&2
  dim "    If any of these are real: ROTATE THE KEY FIRST, then clean history."
  dim "    Deleting the file in a later commit does not help."
  found
else
  clear_ "no known key formats found"
fi

head1 "3. History"
ENV_IN_HISTORY="$(git log --all --pretty=format: --name-only --diff-filter=A 2>/dev/null \
  | sort -u | grep -Ei '(^|/)\.env($|\.)|\.pem$|\.key$' || true)"
if [ -n "$ENV_IN_HISTORY" ]; then
  bad "These were committed at some point, and are still in history:"
  printf '%s\n' "$ENV_IN_HISTORY" | sed 's/^/    /' >&2
  dim "    Anyone who clones this repo can read them, even if deleted since."
  dim "    Rotate the credentials, then rewrite history with git-filter-repo or BFG."
  found
else
  clear_ "no credential files in history"
fi

head1 "4. .gitignore"
if [ ! -f .gitignore ]; then
  bad "There is no .gitignore. Write one before the first commit — see guide/05-github.md."
  found
elif ! grep -qE '^[[:space:]]*\.env([[:space:]]*$|\*|\.\*)' .gitignore; then
  warn ".gitignore doesn't mention .env. Add these lines:"
  dim "    .env"
  dim "    .env.*"
  dim "    !.env.example"
  found
else
  clear_ ".gitignore covers .env"
fi

head1 "5. Large files"
BIG=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  sz=$(wc -c < "$f" 2>/dev/null | tr -d ' ')
  [ "${sz:-0}" -gt 5242880 ] && BIG="${BIG}    $(printf '%5s MB  %s' "$((sz / 1048576))" "$f")"$'\n'
done <<< "$FILE_LIST"
if [ -n "$BIG" ]; then
  warn "Files over 5 MB — deliberate, or did a build folder slip in?"
  printf '%s' "$BIG" >&2
  found
else
  clear_ "nothing unexpectedly large"
fi

head1 "6. Your email address"
EMAIL="$(git config user.email 2>/dev/null || true)"
if [ -z "$EMAIL" ]; then
  warn "git has no user.email set — commits will be attributed oddly."
  found
elif printf '%s' "$EMAIL" | grep -q 'users.noreply.github.com'; then
  clear_ "commits use your GitHub no-reply address"
else
  warn "Commits will publish: $EMAIL"
  dim "    Fine if that's intended. To keep it private, enable"
  dim "    'Keep my email addresses private' in GitHub Settings → Emails,"
  dim "    then: git config --global user.email '<id>+<user>@users.noreply.github.com'"
fi

head1 "Result"
if [ "$FINDINGS" -eq 0 ]; then
  ok "Nothing found. Still read your own diff — this can't spot a home address in a test fixture."
  exit 0
fi
bad "$FINDINGS thing(s) to look at before this goes public."
say ""
dim "Remember the order if something did leak: rotate the credential FIRST."
dim "Public commits are scraped by bots within seconds. Once the key is dead,"
dim "the rest is tidying."
exit 1
