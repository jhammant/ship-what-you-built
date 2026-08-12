#!/usr/bin/env python3
"""
Render guide/*.md into site/guide/*.html, styled like the rest of the site.

The markdown files stay the single source of truth — this only produces the
readable version. Re-run it after editing anything in guide/:

    python3 tools/build-guide.py

`--check` re-renders into a temp dir and exits non-zero if the committed HTML
has drifted from the markdown. CI runs that, so the two can't silently diverge.
"""
from __future__ import annotations

import argparse
import html
import pathlib
import re
import shutil
import sys
import tempfile

try:
    import markdown
except ImportError:
    sys.exit("Needs python-markdown:  pip3 install markdown")

ROOT = pathlib.Path(__file__).resolve().parent.parent
GUIDE_SRC = ROOT / "guide"
OUT_DIR = ROOT / "site" / "guide"
REPO = "https://github.com/jhammant/ship-what-you-built"

# Order matters: it drives the sidebar and the prev/next links.
PAGES = [
    ("00-install-claude-code.md", "Stage 0 — Get an agent",  "Install Claude Code or Codex"),
    ("01-find-an-idea.md",     "Stage 0.5 — Find an idea", "What to actually build"),
    ("02-start-here.md",       "Start here",            "What did you build?"),
    ("03-your-machine.md",     "Your machine",          "Terminal and tools, incl. Windows"),
    ("04-accounts.md",         "The accounts you need", "GitHub, Cloudflare, AWS, Anthropic"),
    ("05-keys-and-access.md",  "Keys and access",       "API keys, and giving Claude access"),
    ("06-four-layers.md",      "The four layers",       "The model everything rests on"),
    ("07-github.md",           "Get it on GitHub",      "Safely, without leaking a key"),
    ("08-let-claude-drive.md", "Let Claude drive",      "The recommended path"),
    ("10-cloudflare.md",       "Track A — Cloudflare",  "Domain, Pages, auto-deploy"),
    ("20-aws.md",              "Track B — AWS",         "S3, CloudFront, Route 53, OIDC"),
    ("30-share-it.md",         "Share it",              "Previews, README, showcase"),
    ("40-launch-video.md",     "Make a launch video",   "Remotion, rendered from code"),
    ("50-getting-found.md",    "Getting it found",      "SEO, and what actually gets shared"),
    ("60-money.md",            "Making money from it",  "Ads, affiliate, subscriptions — honestly"),
    ("70-your-domain.md",      "More from one domain",  "Subdomains, and email at your address"),
    ("90-troubleshooting.md",  "When it breaks",        "Symptom → cause"),
    ("99-glossary.md",         "Glossary",              "Every term, explained"),
]

# Pages still being written are skipped rather than fatal, so the site can be
# rebuilt at any point mid-edit.
OPTIONAL: set[str] = set()


def gh_slug(text: str, seen: dict[str, int]) -> str:
    """Reproduce GitHub's heading slugs exactly.

    Verified against GitHub's own rendered output: an em-dash is stripped but
    the spaces either side are not collapsed, so "Layer 2 — DNS" becomes
    "layer-2--dns" with two hyphens. Getting this wrong would break every
    existing cross-page anchor in the guide.
    """
    s = text.strip().lower()
    s = re.sub(r"[^\w\s-]", "", s, flags=re.UNICODE)
    s = s.replace(" ", "-")
    n = seen.get(s, 0)
    seen[s] = n + 1
    return s if n == 0 else f"{s}-{n}"


def rewrite_links(body: str) -> str:
    """Point links at their on-site equivalents, or out to GitHub."""
    # Sibling guide pages keep their fragment.
    body = re.sub(r'href="([0-9]{2}-[a-z-]+)\.md(#[^"]*)?"',
                  lambda m: f'href="{m.group(1)}.html{m.group(2) or ""}"', body)
    # Things that only exist on GitHub.
    body = re.sub(r'href="(?:\.\./)+issues"', f'href="{REPO}/issues"', body)
    body = re.sub(r'href="\.\./([A-Z]+\.md)"', rf'href="{REPO}/blob/main/\1"', body)
    body = re.sub(r'href="\.\./(skill/[^"]+)"', rf'href="{REPO}/blob/main/\1"', body)
    return body


def add_heading_anchors(body: str) -> tuple[str, list[tuple[int, str, str]]]:
    """Give every h2/h3 a GitHub-compatible id and a click-to-link affordance."""
    seen: dict[str, int] = {}
    toc: list[tuple[int, str, str]] = []

    def repl(m: re.Match) -> str:
        level, inner = int(m.group(1)), m.group(2)
        text = re.sub(r"<[^>]+>", "", inner)
        slug = gh_slug(html.unescape(text), seen)
        toc.append((level, slug, html.unescape(text)))
        return (
            f'<h{level} id="{slug}">{inner}'
            f'<a class="anchor" href="#{slug}" aria-label="Link to this section">#</a>'
            f"</h{level}>"
        )

    body = re.sub(r"<h([23])>(.*?)</h\1>", repl, body, flags=re.S)
    return body, toc


def add_copy_buttons(body: str) -> str:
    """Wrap each code block so it can be copied whole.

    This is the highest-value affordance in the whole guide: several blocks are
    `cat > file <<EOF` heredocs that MUST be pasted in one piece, and pasting
    them line by line strands a beginner at a bare `>` prompt with no error.
    """
    def repl(m: re.Match) -> str:
        return (
            '<div class="codewrap">'
            '<button class="copy" type="button" aria-label="Copy code">Copy</button>'
            f"{m.group(0)}</div>"
        )

    return re.sub(r"<pre>.*?</pre>", repl, body, flags=re.S)


PAGE_CSS = """
:root{--bg:#F6F7F5;--surface:#FFF;--sunken:#EEF0EC;--ink:#14181B;--ink-soft:#3D4642;
--muted:#5B6560;--line:rgba(20,24,27,.13);--line-soft:rgba(20,24,27,.07);
--live:#16794C;--live-ink:#FFF;--live-wash:rgba(22,121,76,.09);--stuck:#9A5B18;
--mono:ui-monospace,"SF Mono",SFMono-Regular,Menlo,Consolas,monospace;
--sans:system-ui,-apple-system,"Segoe UI",Roboto,Helvetica,Arial,sans-serif}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){
--bg:#0F1311;--surface:#171C19;--sunken:#121614;--ink:#ECF1ED;--ink-soft:#C3CCC6;
--muted:#8A968F;--line:rgba(236,241,237,.15);--line-soft:rgba(236,241,237,.08);
--live:#35C285;--live-ink:#06140D;--live-wash:rgba(53,194,133,.13);--stuck:#D08A3C}}
:root[data-theme="dark"]{--bg:#0F1311;--surface:#171C19;--sunken:#121614;--ink:#ECF1ED;
--ink-soft:#C3CCC6;--muted:#8A968F;--line:rgba(236,241,237,.15);--line-soft:rgba(236,241,237,.08);
--live:#35C285;--live-ink:#06140D;--live-wash:rgba(53,194,133,.13);--stuck:#D08A3C}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);font-family:var(--sans);
line-height:1.68;font-size:1.02rem;-webkit-font-smoothing:antialiased;overflow-x:hidden}
a{color:var(--ink);text-decoration-color:var(--line);text-underline-offset:3px}
a:hover{text-decoration-color:var(--live)}
a:focus-visible,button:focus-visible{outline:2px solid var(--live);outline-offset:3px;border-radius:5px}
.shell{display:grid;grid-template-columns:17rem minmax(0,1fr);gap:2.5rem;
max-width:78rem;margin-inline:auto;padding:0 clamp(1rem,4vw,2.5rem)}
@media (max-width:900px){.shell{grid-template-columns:minmax(0,1fr);gap:0}}
.side{position:sticky;top:0;align-self:start;max-height:100vh;overflow-y:auto;
padding:2rem 0;border-right:1px solid var(--line-soft)}
@media (max-width:900px){.side{position:static;max-height:none;border-right:0;
border-bottom:1px solid var(--line-soft);padding-bottom:1rem}}
.brand{font-weight:660;letter-spacing:-.02em;text-decoration:none;display:block;margin-bottom:.35rem}
.brand small{display:block;font-weight:400;color:var(--muted);font-size:.8rem;letter-spacing:0}
.nav{list-style:none;margin:1.25rem 0 0;padding:0;display:grid;gap:.15rem}
.nav a{display:block;padding:.42rem .6rem;border-radius:7px;text-decoration:none;
font-size:.925rem;color:var(--ink-soft)}
.nav a:hover{background:var(--sunken)}
.nav a[aria-current="page"]{background:var(--live-wash);color:var(--ink);font-weight:600}
.nav small{display:block;color:var(--muted);font-size:.76rem;line-height:1.35}
.onpage{margin-top:1.5rem;border-top:1px solid var(--line-soft);padding-top:1rem}
.onpage p{margin:0 0 .5rem;font-family:var(--mono);font-size:.7rem;letter-spacing:.16em;
text-transform:uppercase;color:var(--muted)}
.onpage ul{list-style:none;margin:0;padding:0;display:grid;gap:.1rem}
.onpage a{display:block;padding:.2rem .35rem;font-size:.85rem;color:var(--muted);
text-decoration:none;border-radius:5px}
.onpage a:hover{color:var(--ink);background:var(--sunken)}
.onpage .lvl3{padding-left:1rem;font-size:.8rem}
main{padding:2.5rem 0 4rem;min-width:0;max-width:46rem}
/* grid/flex children default to min-width:auto and refuse to shrink below
   their content, which lets a wide table or code block push the whole page
   sideways instead of scrolling inside its own box. */
.shell>*,main>*,.codewrap,.tablewrap,pre,table{min-width:0}
.codewrap,.tablewrap{max-width:100%}
/* a bare URL in prose is one long unbreakable token and will push the page
   sideways on a narrow phone unless it is allowed to break. */
a,p,li,td,th,h1,h2,h3{overflow-wrap:break-word}
h1{font-size:clamp(1.9rem,1.4rem+2vw,2.7rem);line-height:1.1;letter-spacing:-.03em;
margin:0 0 1.5rem;text-wrap:balance}
h2{font-size:1.5rem;line-height:1.2;letter-spacing:-.022em;margin:2.8rem 0 .9rem;
padding-top:1.4rem;border-top:1px solid var(--line-soft);text-wrap:balance}
h3{font-size:1.13rem;letter-spacing:-.015em;margin:2rem 0 .6rem}
h2 .anchor,h3 .anchor{opacity:0;margin-left:.4rem;color:var(--muted);text-decoration:none;font-weight:400}
h2:hover .anchor,h3:hover .anchor,.anchor:focus-visible{opacity:1}
p,ul,ol{margin:0 0 1.05rem}
li{margin-bottom:.3rem}
strong{font-weight:650}
code{font-family:var(--mono);font-size:.875em;background:var(--sunken);
padding:.12em .34em;border-radius:4px;overflow-wrap:break-word}
.codewrap{position:relative;margin:0 0 1.2rem}
pre{margin:0;overflow-x:auto;background:var(--sunken);border:1px solid var(--line-soft);
border-radius:10px;padding:1rem 1.1rem;font-family:var(--mono);font-size:.845rem;line-height:1.62}
pre code{background:none;padding:0;font-size:1em}
.copy{position:absolute;top:.5rem;right:.5rem;font:inherit;font-size:.75rem;
padding:.28rem .6rem;border-radius:6px;border:1px solid var(--line);
background:var(--surface);color:var(--muted);cursor:pointer;opacity:0;transition:opacity .12s}
.codewrap:hover .copy,.copy:focus-visible{opacity:1}
.copy.done{color:var(--live);border-color:var(--live)}
@media (hover:none){.copy{opacity:1}}
blockquote{margin:0 0 1.2rem;padding:.9rem 1.1rem;border-left:3px solid var(--live);
background:var(--live-wash);border-radius:0 9px 9px 0}
blockquote > :last-child{margin-bottom:0}
blockquote h3{margin-top:.2rem}
.tablewrap{overflow-x:auto;border:1px solid var(--line);border-radius:10px;margin:0 0 1.2rem}
table{border-collapse:collapse;width:100%;min-width:30rem;font-size:.92rem}
th,td{text-align:left;padding:.65rem .9rem;border-bottom:1px solid var(--line-soft);vertical-align:top}
thead th{font-size:.75rem;letter-spacing:.1em;text-transform:uppercase;color:var(--muted)}
tbody tr:last-child td{border-bottom:0}
hr{border:0;border-top:1px solid var(--line-soft);margin:2.5rem 0}
img{max-width:100%;height:auto}
.done-toggle{display:flex;align-items:center;gap:.5rem;font-size:.8rem;color:var(--muted);
margin:.2rem 0 1.6rem;cursor:pointer;user-select:none}
.done-toggle input{accent-color:var(--live);width:1rem;height:1rem}
.pager{display:flex;flex-wrap:wrap;gap:.75rem;justify-content:space-between;
margin-top:3.5rem;padding-top:1.5rem;border-top:1px solid var(--line-soft)}
.pager a{flex:1 1 14rem;padding:.9rem 1.1rem;border:1px solid var(--line);border-radius:10px;
text-decoration:none;background:var(--surface)}
.pager a:hover{border-color:var(--live)}
.pager span{display:block;font-size:.72rem;letter-spacing:.14em;text-transform:uppercase;
color:var(--muted);font-family:var(--mono);margin-bottom:.2rem}
.pager .next{text-align:right}
@media (prefers-reduced-motion:reduce){*{transition:none!important}}
"""

PAGE_JS = """
// Copy the whole block — several are heredocs that break if pasted line by line.
document.querySelectorAll('.codewrap').forEach(function (w) {
  var btn = w.querySelector('.copy'), pre = w.querySelector('pre');
  if (!btn || !pre) return;
  btn.addEventListener('click', function () {
    navigator.clipboard.writeText(pre.innerText).then(function () {
      btn.textContent = 'Copied'; btn.classList.add('done');
      setTimeout(function () { btn.textContent = 'Copy'; btn.classList.remove('done'); }, 1600);
    }).catch(function () { btn.textContent = 'Press Ctrl+C'; });
  });
});

// Remember which pages are finished — the AWS track spans more than one sitting.
(function () {
  var KEY = 'swyb-done', box = document.getElementById('page-done');
  if (!box) return;
  var page = document.body.dataset.page;
  var read = function () { try { return JSON.parse(localStorage.getItem(KEY) || '{}'); } catch (e) { return {}; } };
  var done = read();
  box.checked = !!done[page];
  box.addEventListener('change', function () {
    var d = read();
    if (box.checked) { d[page] = true; } else { delete d[page]; }
    localStorage.setItem(KEY, JSON.stringify(d));
    paint();
  });
  function paint() {
    var d = read();
    document.querySelectorAll('.nav a[data-page]').forEach(function (a) {
      a.textContent.indexOf('✓') === 0 && (a.textContent = a.textContent.slice(1));
      var t = a.querySelector('.tick');
      if (t) t.textContent = d[a.dataset.page] ? '✓ ' : '';
    });
  }
  paint();
})();
"""


def shell(*, title: str, page_id: str, nav: str, onpage: str, body: str, pager: str) -> str:
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)} — Ship What You Built</title>
<meta name="description" content="{html.escape(title)} — part of a free, open-source guide to getting the thing you built onto a real domain.">
<meta property="og:title" content="{html.escape(title)} — Ship What You Built">
<meta property="og:description" content="A free, open-source guide to getting the thing you built onto a real domain.">
<meta property="og:image" content="https://shipwhatyoubuilt.com/preview.png">
<meta property="og:url" content="https://shipwhatyoubuilt.com/guide/{page_id}.html">
<meta property="og:type" content="article">
<meta name="twitter:card" content="summary_large_image">
<style>{PAGE_CSS}</style>
</head>
<body data-page="{page_id}">
<div class="shell">
  <aside class="side">
    <a class="brand" href="/">Ship What You Built<small>from localhost to a real domain</small></a>
    <nav><ul class="nav">{nav}</ul></nav>
    {onpage}
  </aside>
  <main>
{body}
    <label class="done-toggle"><input type="checkbox" id="page-done"> Mark this page done (saved in this browser)</label>
    <nav class="pager">{pager}</nav>
  </main>
</div>
<script>{PAGE_JS}</script>
</body>
</html>
"""


def build(out_dir: pathlib.Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    md = markdown.Markdown(extensions=["fenced_code", "tables", "attr_list", "sane_lists"])

    present = [p for p in PAGES if (GUIDE_SRC / p[0]).exists()]
    missing = [p[0] for p in PAGES if not (GUIDE_SRC / p[0]).exists()]
    if [m for m in missing if m not in OPTIONAL]:
        sys.exit("missing required page(s): " + ", ".join(m for m in missing if m not in OPTIONAL))
    if missing:
        print("  (not written yet, skipped: " + ", ".join(missing) + ")")

    for i, (fname, title, _blurb) in enumerate(present):
        src = GUIDE_SRC / fname
        page_id = fname[:-3]

        md.reset()
        body = md.convert(src.read_text())
        body = rewrite_links(body)
        body, toc = add_heading_anchors(body)
        body = add_copy_buttons(body)
        body = re.sub(r"<table>", '<div class="tablewrap"><table>', body)
        body = re.sub(r"</table>", "</table></div>", body)

        nav = "".join(
            f'<li><a href="{p[:-3]}.html"{" aria-current=\"page\"" if p == fname else ""} '
            f'data-page="{p[:-3]}"><span class="tick"></span>{html.escape(t)}'
            f"<small>{html.escape(b)}</small></a></li>"
            for p, t, b in present
        )

        items = "".join(
            f'<li><a class="lvl{lvl}" href="#{slug}">{html.escape(text)}</a></li>'
            for lvl, slug, text in toc
        )
        onpage = f'<div class="onpage"><p>On this page</p><ul>{items}</ul></div>' if items else ""

        parts = []
        if i > 0:
            p, t, _ = present[i - 1]
            parts.append(f'<a class="prev" href="{p[:-3]}.html"><span>Previous</span>{html.escape(t)}</a>')
        if i < len(present) - 1:
            p, t, _ = present[i + 1]
            parts.append(f'<a class="next" href="{p[:-3]}.html"><span>Next</span>{html.escape(t)}</a>')

        (out_dir / f"{page_id}.html").write_text(
            shell(title=title, page_id=page_id, nav=nav, onpage=onpage,
                  body=body, pager="".join(parts))
        )

    # Prune output from pages that have since been renamed or removed.
    # Without this, a renumber leaves the old HTML live on the site, still
    # linking to files that no longer exist.
    keep = {f"{p[0][:-3]}.html" for p in present} | {"index.html"}
    for stale in sorted(out_dir.glob("*.html")):
        if stale.name not in keep:
            stale.unlink()
            print(f"  removed stale page: {stale.name}")

    (out_dir / "index.html").write_text(
        f'<!doctype html><meta charset="utf-8">'
        f'<meta http-equiv="refresh" content="0; url=00-start-here.html">'
        f'<title>Ship What You Built — the guide</title>'
        f'<p><a href="00-start-here.html">Start here</a></p>'
    )
    return len(present)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true",
                    help="fail if the committed HTML no longer matches the markdown")
    args = ap.parse_args()

    if args.check:
        tmp = pathlib.Path(tempfile.mkdtemp())
        build(tmp)
        drift = [f.name for f in sorted(tmp.glob("*.html"))
                 if not (OUT_DIR / f.name).exists()
                 or (OUT_DIR / f.name).read_text() != f.read_text()]
        shutil.rmtree(tmp)
        if drift:
            print("Guide HTML is out of date with the markdown: " + ", ".join(drift))
            print("Run:  python3 tools/build-guide.py")
            sys.exit(1)
        print("Guide HTML matches the markdown.")
        return

    n = build(OUT_DIR)
    print(f"Rendered {n} guide pages into {OUT_DIR.relative_to(ROOT)}/")


if __name__ == "__main__":
    main()
