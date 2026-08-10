#!/usr/bin/env bash
#
# detect.sh — work out what kind of project this is and how to deploy it.
#
# Reads the current directory only. Makes no network calls and changes nothing.
#
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
detect.sh — identify a project's shape, build command and output directory

USAGE
  detect.sh [DIR] [--env]

ARGUMENTS
  DIR        Project directory to inspect (default: current directory)

OPTIONS
  --env      Print machine-readable KEY=VALUE lines on stdout instead of a
             human summary. Safe to `eval`.
  -h,--help  This text.

WHAT IT REPORTS
  SHAPE          static | backend | longrunning | unknown
                 Matches the three shapes in guide/00-start-here.md
  FRAMEWORK      vite, next, astro, cra, sveltekit, nuxt, gatsby, eleventy,
                 hugo, jekyll, plain, python, none
  BUILD_CMD      what to run to build, or empty if there's no build step
  OUTPUT_DIR     the folder to deploy, or "." for "these files as they are"
  HAS_FUNCTIONS  whether a Cloudflare functions/ directory exists
  GIT_*          repository state, and whether anything risky is tracked

EXIT CODES
  0  detected something usable
  3  the directory looks empty or unrecognisable

EXAMPLES
  detect.sh
  detect.sh ~/dev/my-game
  eval "$(detect.sh --env)" && echo "$OUTPUT_DIR"
EOF
}

TARGET="."
EMIT_ENV=0
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --env)     EMIT_ENV=1; shift ;;
    -*)        die "Unknown option: $1 (try --help)" ;;
    *)         TARGET="$1"; shift ;;
  esac
done

[ -d "$TARGET" ] || die "Not a directory: $TARGET"
cd "$TARGET"

SHAPE="unknown"; FRAMEWORK="none"; BUILD_CMD=""; OUTPUT_DIR="."
HAS_FUNCTIONS="no"; PKG_MANAGER=""; NODE_VERSION=""; NOTES=""

note() { NOTES="${NOTES}${NOTES:+; }$1"; }

# ---------------------------------------------------------------- Node projects
if [ -f package.json ]; then
  FRAMEWORK="plain"
  BUILD_CMD="$(pkg_field package.json 'scripts.build' || true)"
  [ -n "$BUILD_CMD" ] && BUILD_CMD="npm run build"

  if   [ -f pnpm-lock.yaml ];     then PKG_MANAGER="pnpm"
  elif [ -f yarn.lock ];          then PKG_MANAGER="yarn"
  elif [ -f bun.lockb ];          then PKG_MANAGER="bun"
  elif [ -f package-lock.json ];  then PKG_MANAGER="npm"
  else PKG_MANAGER="npm"; note "no lockfile committed — builds may not reproduce"
  fi
  [ -n "$BUILD_CMD" ] && case "$PKG_MANAGER" in
    pnpm) BUILD_CMD="pnpm build" ;;
    yarn) BUILD_CMD="yarn build" ;;
    bun)  BUILD_CMD="bun run build" ;;
  esac

  if   pkg_has "next";            then FRAMEWORK="next";      OUTPUT_DIR="out"
  elif pkg_has "astro";           then FRAMEWORK="astro";     OUTPUT_DIR="dist"
  elif pkg_has "@sveltejs/kit";   then FRAMEWORK="sveltekit"; OUTPUT_DIR="build"
  elif pkg_has "nuxt";            then FRAMEWORK="nuxt";      OUTPUT_DIR=".output/public"
  elif pkg_has "gatsby";          then FRAMEWORK="gatsby";    OUTPUT_DIR="public"
  elif pkg_has "@11ty/eleventy";  then FRAMEWORK="eleventy";  OUTPUT_DIR="_site"
  elif pkg_has "react-scripts";   then FRAMEWORK="cra";       OUTPUT_DIR="build"
  elif pkg_has "vite";            then FRAMEWORK="vite";      OUTPUT_DIR="dist"
  fi

  SHAPE="static"

  if [ "$FRAMEWORK" = "next" ]; then
    if grep -qE "output:[[:space:]]*['\"]export['\"]" next.config.* 2>/dev/null; then
      note "Next.js static export — deploys as files"
    else
      SHAPE="backend"
      OUTPUT_DIR=".next"
      note "Next.js WITHOUT output:'export' needs a server — add the export option, or use a host with Next support"
    fi
  fi

  if [ "$FRAMEWORK" = "sveltekit" ] && ! pkg_has "@sveltejs/adapter-static"; then
    SHAPE="backend"
    note "SvelteKit without adapter-static needs a server runtime"
  fi

  # A server entry point in the root scripts means something has to keep running.
  START_CMD="$(pkg_field package.json 'scripts.start' || true)"
  if printf '%s' "$START_CMD" | grep -qE "(node|nodemon|ts-node|tsx) .*(server|app|index)"; then
    if [ -z "$BUILD_CMD" ]; then
      SHAPE="longrunning"
      note "package.json start script runs a Node server"
    fi
  fi

  if [ -z "$BUILD_CMD" ] && [ -f index.html ]; then
    OUTPUT_DIR="."
    note "package.json present but no build script — treating the folder as static files"
  fi

  NODE_VERSION="$(pkg_field package.json 'engines.node' || true)"
fi

# -------------------------------------------------------------- Python projects
if [ -f requirements.txt ] || [ -f pyproject.toml ] || [ -f Pipfile ]; then
  if grep -rqiE '^(streamlit|gradio)' requirements.txt pyproject.toml 2>/dev/null; then
    FRAMEWORK="python"; SHAPE="longrunning"
    note "Streamlit/Gradio — Streamlit Community Cloud or Hugging Face Spaces fit this better than either track"
  elif grep -rqiE '^(flask|fastapi|django|uvicorn|gunicorn)' requirements.txt pyproject.toml 2>/dev/null; then
    FRAMEWORK="python"; SHAPE="longrunning"
    note "Python web server — see the honest note in guide/00-start-here.md; it may be convertible to Shape 2"
  elif [ "$FRAMEWORK" = "none" ]; then
    FRAMEWORK="python"; SHAPE="longrunning"
  fi
fi

# ------------------------------------------------------- Static site generators
if [ "$FRAMEWORK" = "none" ]; then
  if   [ -f config.toml ] || [ -f hugo.toml ] || [ -f hugo.yaml ]; then
    FRAMEWORK="hugo";   SHAPE="static"; BUILD_CMD="hugo";        OUTPUT_DIR="public"
  elif [ -f _config.yml ]; then
    FRAMEWORK="jekyll"; SHAPE="static"; BUILD_CMD="bundle exec jekyll build"; OUTPUT_DIR="_site"
  elif [ -f index.html ]; then
    FRAMEWORK="plain";  SHAPE="static"; BUILD_CMD="";            OUTPUT_DIR="."
  fi
fi

# Containers almost always mean something long-running.
if [ -f Dockerfile ] || [ -f docker-compose.yml ]; then
  [ "$SHAPE" = "static" ] || SHAPE="longrunning"
  note "Dockerfile present — a container host (Fly.io, Railway, Render) may be the honest answer"
fi

# ------------------------------------------------------------------- Backend-y
if [ -d functions ]; then
  HAS_FUNCTIONS="yes"
  [ "$SHAPE" = "static" ] && SHAPE="backend"
  note "functions/ directory found — Cloudflare Pages Functions"
fi
if [ -f wrangler.toml ] || [ -f wrangler.json ] || [ -f wrangler.jsonc ]; then
  note "wrangler config found — already set up for Cloudflare"
fi
if [ -d api ] && [ "$SHAPE" = "static" ]; then
  SHAPE="backend"; note "api/ directory found"
fi
if ls ./*.env >/dev/null 2>&1 || [ -f .env ]; then
  [ "$SHAPE" = "static" ] && note ".env present — check whether the browser or a server needs those values"
fi

# ------------------------------------------------------------------ Git & risk
GIT_REPO="no"; GIT_REMOTE=""; GIT_GITIGNORE="no"; GIT_TRACKED_SECRETS=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  GIT_REPO="yes"
  GIT_REMOTE="$(git remote get-url origin 2>/dev/null || true)"
  [ -f .gitignore ] && GIT_GITIGNORE="yes"
  GIT_TRACKED_SECRETS="$(git ls-files 2>/dev/null \
    | grep -Ei '(^|/)\.env($|\.)|\.pem$|\.key$|credentials' | tr '\n' ' ' || true)"
fi

[ "$SHAPE" = "unknown" ] && [ -z "$FRAMEWORK" ] && exit 3

# ------------------------------------------------------------------- Reporting
if [ "$EMIT_ENV" = "1" ]; then
  # EVERY value is %q-quoted. Several of these come from the repository itself
  # (a remote URL, a directory name, package.json), so an unquoted one is a
  # command-injection hole in any caller that eval's this output.
  emit() { printf '%s=%s\n' "$1" "$(printf '%q' "$2")"; }
  emit SHAPE               "$SHAPE"
  emit FRAMEWORK           "$FRAMEWORK"
  emit BUILD_CMD           "$BUILD_CMD"
  emit OUTPUT_DIR          "$OUTPUT_DIR"
  emit PKG_MANAGER         "$PKG_MANAGER"
  emit NODE_VERSION        "$NODE_VERSION"
  emit HAS_FUNCTIONS       "$HAS_FUNCTIONS"
  emit GIT_REPO            "$GIT_REPO"
  emit GIT_REMOTE          "$GIT_REMOTE"
  emit GIT_GITIGNORE       "$GIT_GITIGNORE"
  emit GIT_TRACKED_SECRETS "$GIT_TRACKED_SECRETS"
  exit 0
fi

head1 "$(pwd)"

case "$SHAPE" in
  static)      ok   "Shape 1 — static site. Both tracks work, ~20 minutes." ;;
  backend)     ok   "Shape 2 — site with a backend. Both tracks work, ~45 minutes." ;;
  longrunning) warn "Shape 3 — needs something running. Read the honest note in guide/00-start-here.md first." ;;
  *)           warn "Couldn't tell what this is. Say what you built and I'll work it out." ;;
esac

say ""
printf '  %-14s %s\n' "Framework"  "$FRAMEWORK" >&2
printf '  %-14s %s\n' "Build"      "${BUILD_CMD:-none needed}" >&2
printf '  %-14s %s\n' "Deploy dir" "$OUTPUT_DIR" >&2
[ -n "$PKG_MANAGER" ]  && printf '  %-14s %s\n' "Packages"  "$PKG_MANAGER" >&2
[ -n "$NODE_VERSION" ] && printf '  %-14s %s\n' "Node"      "$NODE_VERSION" >&2
[ "$HAS_FUNCTIONS" = "yes" ] && printf '  %-14s %s\n' "Functions" "functions/" >&2

head1 "Git"
if [ "$GIT_REPO" = "yes" ]; then
  ok "git repository"
  if [ -n "$GIT_REMOTE" ]; then
    printf '  %-14s %s\n' "remote" "$GIT_REMOTE" >&2
  else
    warn "no remote yet — opensource.sh sets that up"
  fi
  [ "$GIT_GITIGNORE" = "yes" ] || warn "no .gitignore — write one BEFORE the first commit"
  if [ -n "$GIT_TRACKED_SECRETS" ]; then
    bad "credential-shaped files are tracked: $GIT_TRACKED_SECRETS"
    dim "  Run preflight.sh before this goes anywhere public."
  fi
else
  warn "not a git repository yet — opensource.sh handles that"
fi

if [ -n "$NOTES" ]; then
  head1 "Worth knowing"
  printf '%s\n' "$NOTES" | tr ';' '\n' | sed 's/^ *//; s/^/  · /' >&2
fi

say ""
case "$SHAPE" in
  longrunning) dim "Next: guide/00-start-here.md#the-honest-note-about-shape-3" ;;
  *)           dim "Next: preflight.sh, then pick a track (guide/10-cloudflare.md or guide/20-aws.md)" ;;
esac
