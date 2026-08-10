#!/usr/bin/env bash
#
# og-image.sh — generate the 1200x630 preview image that social platforms show.
#
# Renders a card with headless Chrome. No design work, no image editor, no
# external service.
#
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
og-image.sh — make the image that appears when someone shares your link

USAGE
  og-image.sh --title "Tide Clock" \
              --subtitle "Today's tide times for your nearest beach" \
              --domain tide-clock.example.com \
              [--accent "#1F9D63"] [--light] [--out preview.png]

OPTIONS
  --title     Big text. Keep it under ~40 characters or it will wrap oddly.
  --subtitle  One line under it. Under ~70 characters.
  --domain    Shown in the footer. Usually your site.
  --accent    Hex accent colour (default a jade green).
  --light     Light card instead of dark.
  --out       Output path (default: preview.png in the current directory).
  --keep-html Keep the intermediate HTML, so you can restyle it.
  -h,--help   This text.

WHY 1200x630
  Every platform crops preview images to roughly 1.91:1. Any other ratio gets
  your title sliced off. This size is the one they all agree on.

AFTERWARDS
  Reference it from your page's <head> with an ABSOLUTE url — a relative path
  is the number one reason previews come out blank, because the scraper is not
  on your site:

    <meta property="og:image" content="https://yourdomain.com/preview.png">

  Then deploy, and validate BEFORE you post anywhere:
    https://www.linkedin.com/post-inspector/
  Platforms cache the first version they see, so a broken one can stick around
  for days. Post Inspector has a re-scrape button.

REQUIRES
  Google Chrome, Chromium, or Microsoft Edge installed.
EOF
}

TITLE=""; SUBTITLE=""; DOMAIN=""; ACCENT="#1F9D63"; OUT="preview.png"; LIGHT=0; KEEP=0
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)   usage; exit 0 ;;
    --title)     TITLE="${2:?}"; shift 2 ;;
    --subtitle)  SUBTITLE="${2:?}"; shift 2 ;;
    --domain)    DOMAIN="${2:?}"; shift 2 ;;
    --accent)    ACCENT="${2:?}"; shift 2 ;;
    --out)       OUT="${2:?}"; shift 2 ;;
    --light)     LIGHT=1; shift ;;
    --keep-html) KEEP=1; shift ;;
    *)           die "Unknown option: $1 (try --help)" ;;
  esac
done

[ -n "$TITLE" ] || die "Need --title (see --help)"

CHROME=""
for c in \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  "/Applications/Chromium.app/Contents/MacOS/Chromium" \
  "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
  "$(command -v google-chrome || true)" \
  "$(command -v chromium || true)" \
  "$(command -v chromium-browser || true)" \
  "$(command -v microsoft-edge || true)"; do
  [ -n "$c" ] && [ -x "$c" ] && { CHROME="$c"; break; }
done
[ -n "$CHROME" ] || die "No Chrome/Chromium/Edge found — install one, or screenshot the HTML yourself."

if [ "$LIGHT" = "1" ]; then
  BG="#F6F7F5"; INK="#14181B"; MUTED="#5B6560"; LINE="rgba(20,24,27,0.13)"
else
  BG="#0F1311"; INK="#ECF1ED"; MUTED="#8A968F"; LINE="rgba(236,241,237,0.14)"
fi

esc() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g'; }

HTML="$(dirname "$OUT")/.og-card.html"
[ "$(dirname "$OUT")" = "." ] && HTML="./.og-card.html"

cat > "$HTML" <<EOF
<!doctype html><html lang="en"><head><meta charset="utf-8"><title>og</title><style>
*{margin:0;padding:0;box-sizing:border-box}
body{width:1200px;height:630px;background:$BG;color:$INK;
  font-family:system-ui,-apple-system,"Segoe UI",Helvetica,Arial,sans-serif;
  display:flex;flex-direction:column;justify-content:space-between;
  padding:72px 76px 60px;position:relative;overflow:hidden}
body::before{content:"";position:absolute;inset:0;
  background-image:linear-gradient($LINE 1px,transparent 1px),linear-gradient(90deg,$LINE 1px,transparent 1px);
  background-size:48px 48px;opacity:.35;
  -webkit-mask-image:radial-gradient(ellipse 70% 90% at 80% 26%,#000 0%,transparent 72%)}
.z{position:relative;z-index:1}
.eyebrow{font-family:ui-monospace,"SF Mono",Menlo,Consolas,monospace;font-size:19px;
  letter-spacing:.22em;text-transform:uppercase;color:$ACCENT}
h1{font-size:76px;line-height:1.0;letter-spacing:-.034em;font-weight:680;
  margin-top:24px;text-wrap:balance;max-width:16ch}
p{margin-top:24px;font-size:29px;line-height:1.35;color:$MUTED;max-width:26ch;letter-spacing:-.01em}
footer{position:relative;z-index:1;display:flex;align-items:center;gap:16px;
  border-top:1px solid $LINE;padding-top:26px}
.dot{width:12px;height:12px;border-radius:50%;background:$ACCENT;flex:none;
  box-shadow:0 0 0 6px ${ACCENT}28}
.domain{font-family:ui-monospace,"SF Mono",Menlo,Consolas,monospace;font-size:26px}
</style></head><body>
<div class="z">
  <div class="eyebrow">$(esc "${DOMAIN:-live}")</div>
  <h1>$(esc "$TITLE")</h1>
  $( [ -n "$SUBTITLE" ] && printf '<p>%s</p>' "$(esc "$SUBTITLE")" )
</div>
<footer><span class="dot"></span><span class="domain">$(esc "${DOMAIN:-}")</span></footer>
</body></html>
EOF

ABS_HTML="$(cd "$(dirname "$HTML")" && pwd)/$(basename "$HTML")"
"$CHROME" --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
  --screenshot="$OUT" --window-size=1200,630 "file://$ABS_HTML" >/dev/null 2>&1

[ -f "$OUT" ] || die "Chrome did not produce $OUT"
[ "$KEEP" = "1" ] || rm -f "$HTML"

ok "wrote $OUT (1200x630)"
say ""
dim "  Add this to your page's <head> — absolute URL, not a relative path:"
say "    <meta property=\"og:image\" content=\"https://${DOMAIN:-yourdomain.com}/$(basename "$OUT")\">"
say ""
dim "  Then deploy, and check it at https://www.linkedin.com/post-inspector/"
dim "  before you post anywhere — platforms cache the first version they see."
