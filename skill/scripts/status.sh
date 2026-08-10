#!/usr/bin/env bash
#
# status.sh — is it live, and which layer is broken if it isn't?
#
# Read-only. Walks the four layers from guide/01-three-layers.md in order, so
# the first thing that fails is the thing to fix.
#
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
status.sh — check a live site, layer by layer

USAGE
  status.sh [DOMAIN]

  With no argument it uses the domain saved for this project by deploy.sh.

WHAT IT CHECKS
  Layer 1/2  nameservers, and whether the name resolves at all
  Layer 3    whether the server answers, and with what
  Layer 4    the certificate — who issued it, and when it expires
  Extras     www vs apex, HTTP→HTTPS redirect, Open Graph tags,
             and (if configured) the state of your host

EXIT CODES
  0  the site is up
  1  something is wrong — the output says which layer
  2  no domain given and none saved

EXAMPLES
  status.sh
  status.sh shipwhatyoubuilt.com
EOF
}

DOMAIN_ARG=""
case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  "")        ;;
  -*)        die "Unknown option: $1 (try --help)" ;;
  *)         DOMAIN_ARG="$1" ;;
esac

# Config may define DOMAIN, HOST, S3_BUCKET, CLOUDFRONT_DIST_ID, CF_PROJECT.
load_config >/dev/null 2>&1 || true
DOMAIN="${DOMAIN_ARG:-${DOMAIN:-}}"

if [ -z "$DOMAIN" ]; then
  bad "No domain. Pass one, or record it: deploy.sh --domain yourthing.com"
  exit 2
fi

DOMAIN="$(printf '%s' "$DOMAIN" | sed -e 's|^https\?://||' -e 's|/.*$||')"
PROBLEMS=0
fail() { PROBLEMS=$((PROBLEMS + 1)); }

head1 "$DOMAIN"

# ------------------------------------------------------------- layers 1 and 2
head1 "Layers 1–2 · DNS"
if have dig; then
  # Ask the local resolver first, then public ones. A local miss is very often a
  # stale NEGATIVE cache — the resolver remembering "no such name" from before
  # the domain was delegated. Calling that a broken domain sends people off to
  # fix DNS that is already correct, so only report failure if nobody answers.
  # Emits "<source>|<answer>" on one line, because a plain assignment inside
  # $( ) happens in a subshell and never reaches the caller.
  dig_first() {          # dig_first <type> [filter-regex]
    local type="$1" filt="${2:-.}" out srv
    for srv in "" "@1.1.1.1" "@8.8.8.8"; do
      if [ -z "$srv" ]; then
        out="$(dig "$DOMAIN" "$type" +short 2>/dev/null | grep -E "$filt" || true)"
      else
        out="$(dig "$srv" "$DOMAIN" "$type" +short 2>/dev/null | grep -E "$filt" || true)"
      fi
      if [ -n "$out" ]; then
        printf '%s|%s' "${srv:-your resolver}" "$(printf '%s' "$out" | sort | tr '\n' ' ')"
        return 0
      fi
    done
    printf '|'
    return 1
  }

  NS_RAW="$(dig_first NS '.' || true)"
  NS_SRC="${NS_RAW%%|*}"; NS="${NS_RAW#*|}"
  if [ -n "$NS" ]; then
    ok "nameservers: $NS"
    [ "$NS_SRC" = "your resolver" ] || dim "  (your resolver had nothing; answered by ${NS_SRC#@})"
    case "$NS" in
      *cloudflare*)  dim "  → Cloudflare is authoritative (Track A)" ;;
      *awsdns*)      dim "  → Route 53 is authoritative (Track B)" ;;
    esac
  else
    bad "no nameservers on any resolver — not registered, or registration hasn't propagated"
    fail
  fi

  A_RAW="$(dig_first A '^[0-9]' || true)"
  A_SRC="${A_RAW%%|*}"; ADDR="${A_RAW#*|}"
  STALE_LOCAL=0
  if [ -n "$ADDR" ]; then
    ok "resolves to: $ADDR"
    if [ "$A_SRC" != "your resolver" ]; then
      STALE_LOCAL=1
      warn "your own resolver returned nothing — it's holding a stale cache"
      dim "  The site is fine for everyone else. Flush yours:"
      dim "    macOS:  sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
      dim "    Linux:  resolvectl flush-caches      Windows: ipconfig /flushdns"
    fi
  else
    bad "does not resolve to an address on any resolver"
    dim "  Check the A/ALIAS record exists in whichever zone is authoritative above."
    fail
  fi

  # Local vs public disagreement — catches "works for everyone but me".
  # Skipped when we already said the local cache is stale, so the two notes
  # can't contradict each other.
  if [ "$STALE_LOCAL" = "0" ]; then
    LOCAL="$(dig "$DOMAIN" A +short 2>/dev/null | grep -E '^[0-9]' | sort | tr '\n' ' ' || true)"
    PUB="$(dig @1.1.1.1 "$DOMAIN" A +short 2>/dev/null | grep -E '^[0-9]' | sort | tr '\n' ' ' || true)"
    if [ -n "$LOCAL" ] && [ -n "$PUB" ] && [ "$LOCAL" != "$PUB" ]; then
      dim "  note: your resolver and 1.1.1.1 return different addresses."
      dim "  Usually a CDN answering by location — only a problem if the site misbehaves."
    fi
  fi
else
  warn "dig not installed — skipping DNS checks"
fi

# ------------------------------------------------------------------- layer 3
head1 "Layer 3 · The server"
CODE="$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "https://$DOMAIN" || echo "000")"
SERVER="$(curl -sI --max-time 15 "https://$DOMAIN" 2>/dev/null | tr -d '\r' \
  | sed -n 's/^[Ss]erver: //p' | head -1 || true)"
case "$CODE" in
  200)  ok "https://$DOMAIN → 200" ;;
  30*)  ok "https://$DOMAIN → $CODE (redirect)" ;;
  404)  bad "404 — the server answers but can't find the page"
        dim "  Usually the wrong output directory, or index.html isn't at its root."
        fail ;;
  403)  bad "403 — the server refuses"
        dim "  Track B: bucket policy or Origin Access Control. See guide/90-troubleshooting.md"
        fail ;;
  000)  bad "no response at all"
        dim "  DNS resolves but nothing is serving. Has the deploy finished?"
        fail ;;
  *)    warn "https://$DOMAIN → $CODE"; fail ;;
esac
[ -n "$SERVER" ] && dim "  served by: $SERVER"

WWW_CODE="$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "https://www.$DOMAIN" || echo "000")"
case "$WWW_CODE" in
  200|30*) ok "www.$DOMAIN → $WWW_CODE" ;;
  000)     warn "www.$DOMAIN doesn't resolve — people do type it"
           dim "  Add www as a second custom domain / alias record." ;;
  *)       warn "www.$DOMAIN → $WWW_CODE" ;;
esac

HTTP_CODE="$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "http://$DOMAIN" || echo "000")"
case "$HTTP_CODE" in
  30*) ok "plain HTTP redirects to HTTPS" ;;
  200) warn "plain HTTP serves the site without redirecting to HTTPS" ;;
esac

# ------------------------------------------------------------------- layer 4
head1 "Layer 4 · Certificate"
if have openssl; then
  CERT="$(printf '' | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null \
    | openssl x509 -noout -issuer -subject -enddate 2>/dev/null || true)"
  if [ -n "$CERT" ]; then
    ISSUER="$(printf '%s' "$CERT" | sed -n 's/^issuer=.*O *= *\([^,]*\).*/\1/p' | head -1)"
    ENDDATE="$(printf '%s' "$CERT" | sed -n 's/^notAfter=//p')"
    ok "valid certificate${ISSUER:+, issued by $ISSUER}"
    if [ -n "$ENDDATE" ]; then
      EXP_EPOCH="$(date -j -f "%b %e %T %Y %Z" "$ENDDATE" +%s 2>/dev/null \
                || date -d "$ENDDATE" +%s 2>/dev/null || true)"
      if [ -n "$EXP_EPOCH" ]; then
        DAYS=$(( (EXP_EPOCH - $(date +%s)) / 86400 ))
        if   [ "$DAYS" -lt 0 ];  then bad "EXPIRED $((0 - DAYS)) days ago"; fail
        elif [ "$DAYS" -lt 14 ]; then warn "expires in $DAYS days — auto-renewal may have stopped"
        else dim "  expires in $DAYS days (renewal is automatic on both tracks)"
        fi
      else
        dim "  expires: $ENDDATE"
      fi
    fi
  else
    bad "couldn't read a certificate"
    dim "  Not issued yet, still validating, or issued for a different name."
    fail
  fi
else
  warn "openssl not installed — skipping certificate checks"
fi

# ----------------------------------------------------------------- share-ready
head1 "Shareable?"
# 200 KB, not 20 KB: real pages push og: tags a long way down the <head>
# (github.com's sits past byte 25000), and a short read reports a false
# "no og:image" — the exact kind of wrong all-clear this script must not give.
HTML="$(curl -sL --max-time 15 "https://$DOMAIN" 2>/dev/null | head -c 200000 || true)"
if [ -n "$HTML" ]; then
  # One tag per line, so attribute ORDER doesn't matter — plenty of sites write
  # content= before property=, and both single and double quotes occur.
  META="$(printf '%s' "$HTML" | tr '<' '\n<' | grep -i 'og:image\|og:title' || true)"
  OG_IMAGE="$(printf '%s' "$META" | grep -i 'og:image' \
    | sed -n -e 's/.*content="\([^"]*\)".*/\1/p' -e "s/.*content='\([^']*\)'.*/\1/p" | head -1)"
  OG_TITLE="$(printf '%s' "$META" | grep -ci 'og:title' || true)"
  if [ -n "$OG_IMAGE" ]; then
    ok "Open Graph image set"
    case "$OG_IMAGE" in
      http*) IMG_CODE="$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$OG_IMAGE" || echo 000)"
             if [ "$IMG_CODE" = "200" ]; then
               dim "  and it loads ($OG_IMAGE)"
             else
               warn "but it returns $IMG_CODE — the preview will be blank"; fail
             fi ;;
      *)     bad "og:image is a relative path ('$OG_IMAGE') — it must be a full https:// URL"
             dim "  This is the commonest reason link previews come out empty."
             fail ;;
    esac
  else
    warn "no og:image — links to this will share as a bare blue link"
    dim "  See guide/30-share-it.md step 1."
  fi
  [ "${OG_TITLE:-0}" -gt 0 ] || dim "  no og:title either"
fi

# -------------------------------------------------------------- host specifics
load_config >/dev/null 2>&1 || true
if [ -n "${HOST:-}" ]; then
  head1 "Host"
  case "$HOST" in
    aws)
      if have aws && [ -n "${CLOUDFRONT_DIST_ID:-}" ]; then
        ST="$(aws cloudfront get-distribution --id "$CLOUDFRONT_DIST_ID" \
              --query 'Distribution.Status' --output text 2>/dev/null || echo "?")"
        if [ "$ST" = "Deployed" ]; then
          ok "CloudFront: Deployed"
        else
          warn "CloudFront: $ST (still rolling out)"
        fi
      fi
      [ -n "${S3_BUCKET:-}" ] && have aws && \
        dim "  bucket: $(aws s3 ls "s3://$S3_BUCKET" --recursive --summarize 2>/dev/null \
             | sed -n 's/.*Total Objects: /objects: /p' | head -1)"
      ;;
    cloudflare) dim "  Cloudflare Pages project: ${CF_PROJECT:-unknown}" ;;
    git)        have gh && gh run list --limit 3 2>/dev/null | sed 's/^/  /' >&2 || true ;;
  esac
fi

head1 "Result"
if [ "$PROBLEMS" -eq 0 ]; then
  ok "Everything checks out."
  exit 0
fi
bad "$PROBLEMS problem(s) — fix the earliest layer listed first."
dim "  guide/90-troubleshooting.md"
exit 1
