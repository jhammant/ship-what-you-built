import { AbsoluteFill } from 'remotion';

// ── palette · lifted straight from site/index.html (dark tokens) ──────────────
const BG = '#0F1311';
const SURFACE = '#171C19';
const INK = '#ECF1ED';
const MUTED = '#8A968F';
const LIVE = '#35C285';
const LIVE_WASH = 'rgba(53, 194, 133, 0.13)';
const STUCK = '#D08A3C';
const LINE = 'rgba(236, 241, 237, 0.15)';
const LINE_SOFT = 'rgba(236, 241, 237, 0.08)';
const GRID_LINE = 'rgba(236, 241, 237, 0.055)';

const MONO =
  'ui-monospace, "SF Mono", SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace';
const SANS =
  'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif';

const MASK =
  'radial-gradient(118% 76% at 50% 44%, rgba(0,0,0,1) 0%, rgba(0,0,0,0.5) 48%, rgba(0,0,0,0) 80%)';

const Pip: React.FC<{ colour: string; size?: number; halo?: number }> = ({
  colour,
  size = 16,
  halo = 0,
}) => (
  <div
    style={{
      width: size,
      height: size,
      borderRadius: size,
      background: colour,
      flex: 'none',
      boxShadow: halo ? `0 0 0 ${halo}px ${colour}22` : undefined,
    }}
  />
);

const Lock: React.FC<{ size?: number; colour?: string }> = ({ size = 28, colour = LIVE }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ flex: 'none' }}>
    <rect x="4.6" y="10.4" width="14.8" height="10.4" rx="2.6" stroke={colour} strokeWidth="1.9" />
    <path
      d="M8.1 10.4V7.7a3.9 3.9 0 0 1 7.8 0v2.7"
      stroke={colour}
      strokeWidth="1.9"
      strokeLinecap="round"
    />
  </svg>
);

const LAYERS = ['registrar', 'dns', 'hosting', 'certificate'];

// 1080x1080 square — the fallback image post.
export const Card: React.FC = () => (
  <AbsoluteFill style={{ background: BG }}>
    <AbsoluteFill
      style={{
        backgroundImage: `repeating-linear-gradient(0deg, ${GRID_LINE} 0px, ${GRID_LINE} 1px, transparent 1px, transparent 48px), repeating-linear-gradient(90deg, ${GRID_LINE} 0px, ${GRID_LINE} 1px, transparent 1px, transparent 48px)`,
        maskImage: MASK,
        WebkitMaskImage: MASK,
      }}
    />
    <AbsoluteFill
      style={{
        opacity: 0.16,
        background:
          'radial-gradient(52% 26% at 50% 52%, rgba(53,194,133,0.24) 0%, rgba(53,194,133,0) 72%)',
      }}
    />

    <AbsoluteFill
      style={{
        padding: '78px',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        gap: 34,
      }}
    >
      <div
        style={{
          fontFamily: MONO,
          fontSize: 24,
          letterSpacing: 5,
          textTransform: 'uppercase',
          color: MUTED,
        }}
      >
        A free, open-source guide
      </div>

      <div
        style={{
          fontFamily: SANS,
          fontSize: 86,
          fontWeight: 680,
          letterSpacing: -2.2,
          wordSpacing: 5,
          lineHeight: 1.06,
          color: INK,
        }}
      >
        You built something.
        <br />
        <span style={{ color: LIVE }}>Now ship it.</span>
      </div>

      {/* the whole promise, in one row */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 20, flexWrap: 'wrap' }}>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 14,
            padding: '16px 22px',
            borderRadius: 12,
            border: `1px solid ${LINE}`,
            background: SURFACE,
            fontFamily: MONO,
            fontSize: 30,
            color: MUTED,
            textDecoration: 'line-through',
            textDecorationThickness: 1,
          }}
        >
          <Pip colour={STUCK} size={14} />
          localhost:3000
        </div>

        <span style={{ fontFamily: MONO, fontSize: 30, color: MUTED }}>→</span>

        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 14,
            padding: '16px 22px',
            borderRadius: 12,
            border: `1px solid ${LIVE}`,
            background: LIVE_WASH,
            fontFamily: MONO,
            fontSize: 30,
            color: INK,
          }}
        >
          <Pip colour={LIVE} size={14} halo={5} />
          <Lock size={28} />
          shipwhatyoubuilt.com
        </div>
      </div>

      <div style={{ height: 1, background: LINE_SOFT, margin: '10px 0' }} />

      <div style={{ display: 'flex', gap: 14 }}>
        {LAYERS.map((l) => (
          <div
            key={l}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 10,
              padding: '11px 17px',
              borderRadius: 10,
              border: `1px solid ${LINE_SOFT}`,
              background: SURFACE,
              fontFamily: MONO,
              fontSize: 27,
              color: MUTED,
            }}
          >
            <Pip colour={LIVE} size={11} />
            {l}
          </div>
        ))}
      </div>

      <div style={{ fontFamily: SANS, fontSize: 34, color: MUTED, lineHeight: 1.45 }}>
        Two tracks — Cloudflare or AWS. Written for people
        <br />
        who've never deployed anything.
      </div>
    </AbsoluteFill>
  </AbsoluteFill>
);
