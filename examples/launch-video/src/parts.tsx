import React from 'react';
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig, Easing } from 'remotion';
import { C, SANS, MONO, PAD } from './theme';

/** The site's faint routing grid, radially masked. Deliberately subliminal. */
export const Grid: React.FC = () => (
  <AbsoluteFill
    style={{
      backgroundImage: `linear-gradient(${C.grid} 1px, transparent 1px),
                        linear-gradient(90deg, ${C.grid} 1px, transparent 1px)`,
      backgroundSize: '48px 48px',
      WebkitMaskImage:
        'radial-gradient(ellipse 78% 62% at 50% 44%, #000 0%, transparent 78%)',
      maskImage: 'radial-gradient(ellipse 78% 62% at 50% 44%, #000 0%, transparent 78%)',
    }}
  />
);

/**
 * Fade-and-lift. `at` is the frame it begins, relative to the Sequence.
 *
 * `still` renders the finished state with no animation — used for anything on
 * frame 0, because that frame is the video's thumbnail on social feeds and a
 * half-faded title card makes a poor one.
 */
export const Rise: React.FC<{
  at?: number;
  y?: number;
  still?: boolean;
  children: React.ReactNode;
}> = ({ at = 0, y = 22, still = false, children }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  if (still) return <div>{children}</div>;
  const s = spring({ frame: frame - at, fps, config: { damping: 200, mass: 0.6 } });
  return (
    <div style={{ opacity: s, transform: `translateY(${(1 - s) * y}px)` }}>{children}</div>
  );
};

/** Uppercase mono eyebrow — the site's section label. */
export const Eyebrow: React.FC<{ children: React.ReactNode; colour?: string }> = ({
  children,
  colour = C.live,
}) => (
  <div
    style={{
      fontFamily: MONO,
      fontSize: 26,
      letterSpacing: '0.2em',
      textTransform: 'uppercase',
      color: colour,
    }}
  >
    {children}
  </div>
);

export const H1: React.FC<{ children: React.ReactNode; size?: number }> = ({
  children,
  size = 92,
}) => (
  <div
    style={{
      fontFamily: SANS,
      fontSize: size,
      lineHeight: 1.04,
      letterSpacing: '-0.032em',
      fontWeight: 680,
      color: C.ink,
    }}
  >
    {children}
  </div>
);

export const Body: React.FC<{ children: React.ReactNode; size?: number; colour?: string }> = ({
  children,
  size = 36,
  colour = C.inkSoft,
}) => (
  <div style={{ fontFamily: SANS, fontSize: size, lineHeight: 1.45, color: colour }}>
    {children}
  </div>
);

/**
 * The site's address pill, exactly as it appears in the hero: rounded 10px,
 * 1px border, a status dot, mono text. `state` drives the whole meaning —
 * amber and struck through when it only runs locally, jade when it is live.
 */
export const Pill: React.FC<{
  text: string;
  state: 'dead' | 'alive';
  lock?: boolean;
  glow?: number;
  scale?: number;
  size?: number;
}> = ({ text, state, lock = false, glow = 0, scale = 1, size = 40 }) => {
  const alive = state === 'alive';
  return (
    <div
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: 18,
        padding: '22px 32px',
        borderRadius: 14,
        border: `2px solid ${alive ? C.live : C.line}`,
        background: alive ? C.liveWash : C.surface,
        transform: `scale(${scale})`,
        boxShadow: glow > 0 ? `0 0 ${44 * glow}px ${14 * glow}px ${C.liveWash}` : 'none',
        whiteSpace: 'nowrap',
      }}
    >
      <span
        style={{
          width: 16,
          height: 16,
          borderRadius: '50%',
          flex: 'none',
          background: alive ? C.live : C.stuck,
          boxShadow: alive ? `0 0 0 7px ${C.liveWash}` : 'none',
        }}
      />
      {lock && (
        <svg width="26" height="26" viewBox="0 0 24 24" fill="none" style={{ flex: 'none' }}>
          <rect x="4" y="10" width="16" height="11" rx="2.5" stroke={C.live} strokeWidth="2.2" />
          <path d="M8 10V7a4 4 0 0 1 8 0v3" stroke={C.live} strokeWidth="2.2" />
        </svg>
      )}
      <span
        style={{
          fontFamily: MONO,
          fontSize: size,
          color: alive ? C.ink : C.muted,
          textDecoration: alive ? 'none' : 'line-through',
          textDecorationThickness: 2,
        }}
      >
        {text}
      </span>
    </div>
  );
};

/**
 * One row of the four-layer diagram, matching the site's inline SVG: a jade
 * dot on a dashed spine, a mono uppercase name, and a plain-English job.
 */
export const LayerRow: React.FC<{
  n: number;
  name: string;
  desc: string;
  at: number;
  dim?: number;
}> = ({ n, name, desc, at, dim = 1 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = spring({ frame: frame - at, fps, config: { damping: 200, mass: 0.7 } });
  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'flex-start',
        gap: 30,
        opacity: s * dim,
        transform: `translateX(${(1 - s) * -26}px)`,
      }}
    >
      <div
        style={{
          width: 26,
          height: 26,
          borderRadius: '50%',
          background: C.live,
          flex: 'none',
          marginTop: 12,
          boxShadow: `0 0 0 8px ${C.bg}`,
        }}
      />
      <div>
        <div
          style={{
            fontFamily: MONO,
            fontSize: 30,
            fontWeight: 600,
            letterSpacing: '0.05em',
            color: C.ink,
          }}
        >
          {n} · {name}
        </div>
        <div style={{ fontFamily: SANS, fontSize: 32, color: C.muted, marginTop: 6 }}>{desc}</div>
      </div>
    </div>
  );
};

/**
 * The dashed spine the layer dots sit on, drawing downward as they arrive.
 *
 * Coordinates are relative to the row container, whose first child is the
 * 26px dot — so the centre line is x=12, not the page gutter. (It was
 * PAD + 13 here, which double-counted the Stage's own padding and put the
 * dashes straight through the text.)
 */
export const Spine: React.FC<{ at: number; height: number; top?: number }> = ({
  at,
  height,
  top = 25,
}) => {
  const frame = useCurrentFrame();
  const grow = interpolate(frame - at, [0, 70], [0, height], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.cubic),
  });
  return (
    <div
      style={{
        position: 'absolute',
        left: 12,
        top,
        width: 2,
        height: grow,
        backgroundImage: `repeating-linear-gradient(${C.line} 0 8px, transparent 8px 16px)`,
      }}
    />
  );
};

/** Every scene sits on the same ground, gutter and grid as the site. */
export const Stage: React.FC<{ children: React.ReactNode; justify?: string }> = ({
  children,
  justify = 'center',
}) => (
  <AbsoluteFill style={{ background: C.bg }}>
    <Grid />
    <AbsoluteFill
      style={{
        padding: `0 ${PAD}px`,
        display: 'flex',
        flexDirection: 'column',
        justifyContent: justify,
        gap: 34,
      }}
    >
      {children}
    </AbsoluteFill>
  </AbsoluteFill>
);
