// The site's design tokens, lifted verbatim from site/index.html.
//
// The site is theme-aware; this picks which of its two palettes the video
// wears. LIGHT is what most people see when they visit shipwhatyoubuilt.com,
// so it is the default. Flip this one constant to render the dark cut.
export const THEME: 'light' | 'dark' = 'light';

const LIGHT = {
  bg: '#F6F7F5',
  surface: '#FFFFFF',
  sunken: '#EEF0EC',
  ink: '#14181B',
  inkSoft: '#3D4642',
  muted: '#5B6560',
  live: '#16794C',
  liveInk: '#FFFFFF',
  liveWash: 'rgba(22, 121, 76, 0.09)',
  stuck: '#9A5B18',
  stuckWash: 'rgba(154, 91, 24, 0.10)',
  line: 'rgba(20, 24, 27, 0.13)',
  lineSoft: 'rgba(20, 24, 27, 0.07)',
  grid: 'rgba(20, 24, 27, 0.045)',
  shadow: '0 1px 2px rgba(20,24,27,.05), 0 8px 24px -12px rgba(20,24,27,.16)',
};

const DARK = {
  bg: '#0F1311',
  surface: '#171C19',
  sunken: '#121614',
  ink: '#ECF1ED',
  inkSoft: '#C3CCC6',
  muted: '#8A968F',
  live: '#35C285',
  liveInk: '#06140D',
  liveWash: 'rgba(53, 194, 133, 0.13)',
  stuck: '#D08A3C',
  stuckWash: 'rgba(208, 138, 60, 0.14)',
  line: 'rgba(236, 241, 237, 0.15)',
  lineSoft: 'rgba(236, 241, 237, 0.08)',
  grid: 'rgba(236, 241, 237, 0.055)',
  shadow: '0 1px 2px rgba(0,0,0,.4), 0 8px 28px -14px rgba(0,0,0,.7)',
};

export const C = THEME === 'light' ? LIGHT : DARK;

// The site's typographic pairing: a grotesque for prose, mono for anything the
// computer said (URLs, records, commands). That split carries the meaning.
export const SANS =
  'system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif';
export const MONO =
  'ui-monospace, "SF Mono", SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace';

// One gutter and one content column, as on the site.
export const PAD = 84;
export const COL = 1080 - PAD * 2;
