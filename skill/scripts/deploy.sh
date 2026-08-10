#!/usr/bin/env bash
#
# deploy.sh — put the current version live.
#
# Remembers how this project deploys, so after the first run it takes no
# arguments. Config lives in ~/.config/shipwhatyoubuilt/<project>.conf
#
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
deploy.sh — build if needed, upload, bust the cache, report the URL

USAGE
  deploy.sh [options]

FIRST RUN — tell it how this project deploys (it remembers):

  Track A, Cloudflare Pages:
    deploy.sh --host cloudflare --project my-pages-project --dir dist

  Track B, AWS S3 + CloudFront:
    deploy.sh --host aws --bucket my-bucket --dist E1234ABCDEF --dir dist

  Deploys happen from GitHub (Pages connected to a repo, or Actions):
    deploy.sh --host git

AFTERWARDS
    deploy.sh

OPTIONS
  --host HOST     cloudflare | aws | git
  --project NAME  Cloudflare Pages project name
  --bucket NAME   S3 bucket
  --dist ID       CloudFront distribution ID
  --dir DIR       Folder to deploy (default: auto-detected)
  --domain NAME   Your domain, used for the "it's live" check
  --build         Force the build step even if the output folder exists
  --no-build      Skip the build step
  --no-wait       Don't wait for the CDN cache to finish clearing
  --dry-run       Show every command; run none of them
  -h,--help       This text

NOTES
  · Safe to run twice.
  · With --host aws it uses `aws s3 sync --delete`, which removes files from
    the bucket that no longer exist locally. It will refuse to run if the
    directory to deploy is empty — that combination wipes a live site.
  · With --host git, deploying means pushing. This just does that, and points
    you at the run.
EOF
}

HOST=""; CF_PROJECT=""; S3_BUCKET=""; CLOUDFRONT_DIST_ID=""; DIR=""; DOMAIN=""
BUILD_CMD=""; FORCE_BUILD=0; NO_BUILD=0; NO_WAIT=0; DRY=0

load_config || true
SAVED_DEPLOY_DIR="${DEPLOY_DIR:-}"

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)  usage; exit 0 ;;
    --host)     HOST="${2:?}"; shift 2 ;;
    --project)  CF_PROJECT="${2:?}"; shift 2 ;;
    --bucket)   S3_BUCKET="${2:?}"; shift 2 ;;
    --dist)     CLOUDFRONT_DIST_ID="${2:?}"; shift 2 ;;
    --dir)      DIR="${2:?}"; shift 2 ;;
    --domain)   DOMAIN="${2:?}"; shift 2 ;;
    --build)    FORCE_BUILD=1; shift ;;
    --no-build) NO_BUILD=1; shift ;;
    --no-wait)  NO_WAIT=1; shift ;;
    --dry-run)  DRY=1; shift ;;
    *)          die "Unknown option: $1 (try --help)" ;;
  esac
done

run() {
  if [ "$DRY" = "1" ]; then dim "  would run: $*"; else "$@"; fi
}

[ "$DRY" = "1" ] && head1 "DRY RUN — nothing will change"

# ------------------------------------------------------- work out the details
if [ -z "$HOST" ]; then
  bad "I don't know how this project deploys yet."
  say ""
  say "  Tell me once and I'll remember:"
  dim "    deploy.sh --host cloudflare --project <name> --dir <folder>"
  dim "    deploy.sh --host aws --bucket <name> --dist <id> --dir <folder>"
  dim "    deploy.sh --host git"
  exit 1
fi

DETECTED_DIR=""; DETECTED_BUILD=""
# Only these two keys are eval'd, and detect.sh %q-quotes everything it emits.
# Never eval the whole block: values like GIT_REMOTE come from the repository,
# so a hostile clone could otherwise run commands here.
DETECT_ENV="$("$SCRIPT_DIR/detect.sh" --env 2>/dev/null || true)"
SAFE_ENV="$(printf '%s\n' "$DETECT_ENV" | grep -E '^(OUTPUT_DIR|BUILD_CMD)=' || true)"
if [ -n "$SAFE_ENV" ]; then
  eval "$SAFE_ENV"
  DETECTED_DIR="${OUTPUT_DIR:-}"
  DETECTED_BUILD="${BUILD_CMD:-}"
fi
# Precedence: --dir, then the folder remembered from last time, then detection,
# then ".". DEPLOY_DIR used to be written and never read, so a bare re-run fell
# through to "." and synced the whole source tree — .git and .env included —
# over the live site with --delete.
DIR="${DIR:-${SAVED_DEPLOY_DIR:-}}"
DIR="${DIR:-$DETECTED_DIR}"
DIR="${DIR:-.}"
BUILD_CMD="${DETECTED_BUILD:-}"

# --dry-run must not persist anything. Otherwise a dry run used to sanity-check
# a guessed bucket name silently becomes the remembered setting for real runs.
if [ "$DRY" = "1" ]; then
  dim "  would remember: HOST=$HOST DIR=$DIR${S3_BUCKET:+ S3_BUCKET=$S3_BUCKET}${CF_PROJECT:+ CF_PROJECT=$CF_PROJECT}${CLOUDFRONT_DIST_ID:+ DIST=$CLOUDFRONT_DIST_ID}${DOMAIN:+ DOMAIN=$DOMAIN}"
else
  save_config HOST "$HOST"
  [ -n "$CF_PROJECT" ]          && save_config CF_PROJECT "$CF_PROJECT"
  [ -n "$S3_BUCKET" ]           && save_config S3_BUCKET "$S3_BUCKET"
  [ -n "$CLOUDFRONT_DIST_ID" ]  && save_config CLOUDFRONT_DIST_ID "$CLOUDFRONT_DIST_ID"
  [ -n "$DOMAIN" ]              && save_config DOMAIN "$DOMAIN"
  save_config DEPLOY_DIR "$DIR"
fi

# ----------------------------------------------------------------- build step
if [ "$NO_BUILD" = "0" ] && [ -n "$BUILD_CMD" ]; then
  if [ "$FORCE_BUILD" = "1" ] || [ ! -d "$DIR" ] || [ "$DIR" = "." ]; then
    if [ "$DIR" != "." ]; then
      head1 "Building"
      run sh -c "$BUILD_CMD"
    fi
  else
    dim "Skipping build ($DIR already exists — use --build to force)"
  fi
fi

# --------------------------------------------------------------- sanity check
# Skipped under --dry-run: dry-run deliberately doesn't build, so the output
# folder legitimately may not exist yet, and dying here would abort before
# printing the deploy command the dry run exists to show.
if [ "$HOST" != "git" ] && [ "$DRY" = "0" ]; then
  [ -d "$DIR" ] || die "Nothing to deploy: '$DIR' doesn't exist. Did the build fail?"
  if [ -z "$(ls -A "$DIR" 2>/dev/null)" ]; then
    die "Refusing to deploy: '$DIR' is empty. With --delete that would wipe the live site."
  fi
  if [ ! -f "$DIR/index.html" ]; then
    warn "No index.html in '$DIR' — the site's front page may 404."
  fi
  # The empty-directory guard above only catches the empty case. A wrong-but-
  # populated directory (typically the project root) is the realistic disaster,
  # so name the directory plainly and refuse the obviously-wrong one.
  if [ -d "$DIR/.git" ] || [ -f "$DIR/.env" ]; then
    bad "'$DIR' looks like your project root, not a build output folder."
    dim "  It contains $( [ -d "$DIR/.git" ] && printf '.git/ '; [ -f "$DIR/.env" ] && printf '.env ')— publishing it would expose your history and secrets."
    dim "  Pass the built folder explicitly:  deploy.sh --dir dist"
    exit 1
  fi
  say "  deploying: $(cd "$DIR" && pwd)"
fi

# ------------------------------------------------------------------- dispatch
case "$HOST" in

  cloudflare)
    [ -n "$CF_PROJECT" ] || die "Need --project <cloudflare pages project name>"
    have npx || die "npx not found — install Node.js"
    head1 "Deploying to Cloudflare Pages: $CF_PROJECT"
    run npx --yes wrangler@latest pages deploy "$DIR" --project-name "$CF_PROJECT" --commit-dirty=true
    ;;

  aws)
    [ -n "$S3_BUCKET" ] || die "Need --bucket <s3 bucket>"
    have aws || die "AWS CLI not found. See guide/20-aws.md part 2.3."
    head1 "Uploading to s3://$S3_BUCKET"
    run aws s3 sync "$DIR" "s3://$S3_BUCKET/" --delete

    if [ -n "$CLOUDFRONT_DIST_ID" ]; then
      head1 "Clearing the CloudFront cache"
      if [ "$DRY" = "1" ]; then
        dim "  would invalidate /* on $CLOUDFRONT_DIST_ID"
      else
        INV_ID="$(aws cloudfront create-invalidation \
          --distribution-id "$CLOUDFRONT_DIST_ID" --paths "/*" \
          --query 'Invalidation.Id' --output text)"
        ok "invalidation $INV_ID created"
        if [ "$NO_WAIT" = "0" ]; then
          dim "  waiting for it to finish (a couple of minutes)…"
          aws cloudfront wait invalidation-completed \
            --distribution-id "$CLOUDFRONT_DIST_ID" --id "$INV_ID"
          ok "cache cleared — the new version really is live"
        fi
      fi
    else
      warn "No CloudFront distribution recorded — the CDN will keep serving the old version."
      dim "  Add it with: deploy.sh --dist <distribution-id>"
    fi
    ;;

  git)
    head1 "Deploying by pushing"
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not a git repository."
    if [ -n "$(git status --porcelain)" ]; then
      warn "You have uncommitted changes. Commit them first, or they won't ship:"
      git status --short >&2
      exit 1
    fi
    run git push
    if have gh && [ "$DRY" = "0" ]; then
      dim "  watching the run…"
      gh run watch --exit-status 2>/dev/null || \
        dim "  (no Actions run — your host is probably building from the push directly)"
    fi
    ;;

  *) die "Unknown host '$HOST'. Use cloudflare, aws, or git." ;;
esac

# ------------------------------------------------------------------ live check
if [ "$DRY" = "0" ] && [ -n "${DOMAIN:-}" ]; then
  head1 "Checking"
  CODE="$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "https://$DOMAIN" || true)"
  CODE="${CODE:-000}"
  case "$CODE" in
    200|30*) ok "https://$DOMAIN → $CODE" ;;
    000)     bad "https://$DOMAIN didn't respond. See guide/90-troubleshooting.md" ;;
    *)       warn "https://$DOMAIN → $CODE" ;;
  esac
fi

head1 "Done"
[ -n "${DOMAIN:-}" ] && say "  https://$DOMAIN"
dim "  Still seeing the old version? That's your browser. Cmd/Ctrl+Shift+R."
