import {
  AbsoluteFill,
  Easing,
  Sequence,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';

// ── palette · lifted straight from site/index.html (dark tokens) ──────────────
const BG = '#0F1311'; // near-black with a green bias
const SURFACE = '#171C19';
const SUNKEN = '#121614';
const INK = '#ECF1ED';
const INK_SOFT = '#C3CCC6';
const MUTED = '#8A968F';
const LIVE = '#35C285'; // jade — means "live"
const LIVE_WASH = 'rgba(53, 194, 133, 0.13)';
const STUCK = '#D08A3C'; // amber — means "not live yet"
const STUCK_WASH = 'rgba(208, 138, 60, 0.13)';
const LINE = 'rgba(236, 241, 237, 0.15)';
const LINE_SOFT = 'rgba(236, 241, 237, 0.08)';
const GRID_LINE = 'rgba(236, 241, 237, 0.055)';

// Mono means "the computer said this". Sans means "a human is talking to you".
const MONO =
  'ui-monospace, "SF Mono", SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace';
const SANS =
  'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif';

const PAD = 84; // frame gutter
const COL = 1080 - PAD * 2; // 912 — the one content width everything sits in

// ── shared bits ───────────────────────────────────────────────────────────────

// Faint routing grid: 48px squares under a radial mask. Subliminal, never read.
const Grid: React.FC<{ opacity?: number }> = ({ opacity = 1 }) => {
  const mask =
    'radial-gradient(118% 74% at 50% 44%, rgba(0,0,0,1) 0%, rgba(0,0,0,0.5) 48%, rgba(0,0,0,0) 80%)';
  return (
    <AbsoluteFill
      style={{
        opacity,
        backgroundImage: `repeating-linear-gradient(0deg, ${GRID_LINE} 0px, ${GRID_LINE} 1px, transparent 1px, transparent 48px), repeating-linear-gradient(90deg, ${GRID_LINE} 0px, ${GRID_LINE} 1px, transparent 1px, transparent 48px)`,
        maskImage: mask,
        WebkitMaskImage: mask,
      }}
    />
  );
};

const Pip: React.FC<{ colour: string; size?: number; halo?: number; glow?: number }> = ({
  colour,
  size = 18,
  halo = 0,
  glow = 0,
}) => (
  <div
    style={{
      width: size,
      height: size,
      borderRadius: size,
      background: colour,
      flex: 'none',
      boxShadow: halo ? `0 0 0 ${halo}px ${colour}22, 0 0 ${glow}px ${colour}` : undefined,
    }}
  />
);

const Lock: React.FC<{ size?: number; colour?: string; opacity?: number }> = ({
  size = 32,
  colour = LIVE,
  opacity = 1,
}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ opacity, flex: 'none' }}>
    <rect x="4.6" y="10.4" width="14.8" height="10.4" rx="2.6" stroke={colour} strokeWidth="1.9" />
    <path
      d="M8.1 10.4V7.7a3.9 3.9 0 0 1 7.8 0v2.7"
      stroke={colour}
      strokeWidth="1.9"
      strokeLinecap="round"
    />
  </svg>
);

// Eased entrance. Everything in this film arrives this way except the flip.
const Rise: React.FC<{ start: number; distance?: number; children: React.ReactNode }> = ({
  start,
  distance = 24,
  children,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const s = spring({ frame: frame - start, fps, config: { damping: 200 } });
  return (
    <div style={{ opacity: s, transform: `translateY(${interpolate(s, [0, 1], [distance, 0])}px)` }}>
      {children}
    </div>
  );
};

// Scenes only fade IN — the outgoing one stays put underneath until it's covered,
// so there is never a dip to black between beats.
const useSceneIn = (frames = 16) =>
  interpolate(useCurrentFrame(), [0, frames], [0, 1], {
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.quad),
  });

const Scene: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <AbsoluteFill style={{ background: BG, opacity: useSceneIn() }}>
    <Grid />
    {children}
  </AbsoluteFill>
);

// ── beats 1 + 2 · the terminal, and the sentence underneath it ────────────────
// One scene, because the localhost line has to survive the cut to be the hook.
const Terminal: React.FC = () => {
  const frame = useCurrentFrame();

  const CMD = 'npm run dev';
  const typedChars = Math.floor(interpolate(frame, [14, 52], [0, CMD.length], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  }));
  const typing = frame < 56;
  const caretOn = Math.floor(frame / 14) % 2 === 0;

  const readyIn = interpolate(frame, [64, 78], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.quad),
  });
  const localIn = interpolate(frame, [84, 100], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.quad),
  });

  // Beat 2: the chrome recedes, the localhost line greys but stays.
  const ease = { extrapolateLeft: 'clamp' as const, extrapolateRight: 'clamp' as const, easing: Easing.inOut(Easing.cubic) };
  const chrome = interpolate(frame, [118, 148], [1, 0.14], ease);
  const localDim = interpolate(frame, [118, 148], [1, 0.52], ease);
  const lift = interpolate(frame, [118, 156], [0, -150], ease);
  const shrink = interpolate(frame, [118, 156], [1, 0.94], ease);

  const row = { display: 'flex', alignItems: 'center' as const, gap: 14, minHeight: 58 };

  return (
    <Scene>
      {/* the terminal */}
      <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center' }}>
        <div
          style={{
            width: COL,
            transform: `translateY(${lift}px) scale(${shrink})`,
            background: SURFACE,
            border: `1px solid ${LINE}`,
            borderRadius: 18,
            overflow: 'hidden',
            boxShadow: '0 1px 2px rgba(0,0,0,.4), 0 30px 70px -30px rgba(0,0,0,.85)',
          }}
        >
          <div
            style={{
              display: 'flex',
              gap: 10,
              padding: '20px 26px',
              borderBottom: `1px solid ${LINE_SOFT}`,
              background: SUNKEN,
              opacity: chrome,
            }}
          >
            <Pip colour={LINE} size={13} />
            <Pip colour={LINE} size={13} />
            <Pip colour={LINE} size={13} />
          </div>

          <div style={{ padding: '30px 34px 34px', fontFamily: MONO, fontSize: 34 }}>
            <div style={{ ...row, opacity: chrome }}>
              <span style={{ color: MUTED }}>$</span>
              <span style={{ color: INK }}>{CMD.slice(0, typedChars)}</span>
              {typing && caretOn ? (
                <span
                  style={{
                    display: 'inline-block',
                    width: 17,
                    height: 36,
                    background: INK,
                    marginLeft: -6,
                  }}
                />
              ) : null}
            </div>

            <div style={{ ...row, opacity: readyIn * chrome, color: MUTED }}>ready in 412 ms</div>

            <div style={{ ...row, opacity: localIn * localDim, gap: 20 }}>
              <span style={{ color: MUTED }}>Local:</span>
              <Pip colour={STUCK} size={17} halo={5} glow={14} />
              {/* it doesn't disappear — it just stops mattering */}
              <span style={{ color: INK }}>http://localhost:3000</span>
            </div>
          </div>
        </div>
      </AbsoluteFill>

      {/* the sentence */}
      <AbsoluteFill>
        <div style={{ position: 'absolute', left: PAD, top: 726, width: COL }}>
          <Rise start={148} distance={26}>
            <div
              style={{
                fontFamily: SANS,
                fontSize: 84,
                fontWeight: 620,
                letterSpacing: -1.8,
                wordSpacing: 5,
                lineHeight: 1.12,
                color: MUTED,
              }}
            >
              It works.
            </div>
          </Rise>
          <Rise start={182} distance={26}>
            <div
              style={{
                fontFamily: SANS,
                fontSize: 84,
                fontWeight: 700,
                letterSpacing: -1.8,
                wordSpacing: 5,
                lineHeight: 1.12,
                color: INK,
              }}
            >
              Nobody can see it.
            </div>
          </Rise>
        </div>
      </AbsoluteFill>
    </Scene>
  );
};

// ── beats 3 + 4 · the four layers, then the payoff ────────────────────────────
// Also one scene: the stack has to physically collapse into the address bar.
const LAYERS: [string, string][] = [
  ['1 · REGISTRAR', 'Who you bought the name from.'],
  ['2 · DNS', 'Where is it?'],
  ['3 · HOSTING', 'The actual files.'],
  ['4 · CERTIFICATE', "Proves it's you."],
];

const ROW_H = 92;
const ROW_GAP = 46;
const FLIP = 268; // the frame the whole film is built around

const Layers: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const clamp = { extrapolateLeft: 'clamp' as const, extrapolateRight: 'clamp' as const };
  const cubic = { ...clamp, easing: Easing.inOut(Easing.cubic) };

  // the thin line drawing downward as the layers land
  const trail = interpolate(frame, [16, 172], [0, 1], { ...clamp, easing: Easing.out(Easing.cubic) });

  // the collapse
  const fold = interpolate(frame, [200, 242], [0, 1], cubic);
  // The stack must be GONE before the bar is legible, or the two read on top of
  // each other. Front-loaded fade: mostly invisible by the time it has moved.
  const stackOut = interpolate(frame, [200, 226], [1, 0], {
    ...clamp,
    easing: Easing.out(Easing.quad),
  });

  // the address bar — starts the frame the stack finishes vanishing
  const arrive = spring({ frame: frame - 226, fps, config: { damping: 200 } });
  const flipped = frame >= FLIP;
  const punch = interpolate(frame, [FLIP, FLIP + 6, FLIP + 26], [1, 1.045, 1], {
    ...clamp,
    easing: Easing.out(Easing.quad),
  });

  const barColour = flipped ? LIVE : LINE;
  const bloom = interpolate(frame, [FLIP - 2, FLIP + 4, FLIP + 70], [0, 0.5, 0.13], clamp);

  // two jade pulses shoved outward from the bar's own edges
  const pulse = (k: number) => {
    const s = FLIP + k * 14;
    const t = interpolate(frame, [s, s + 54], [0, 1], { ...clamp, easing: Easing.out(Easing.cubic) });
    return { spread: t * 66, o: frame >= s ? (1 - t) * 0.5 : 0 };
  };

  const CHIPS = ['registrar', 'dns', 'hosting', 'certificate'];

  return (
    <Scene>
      {/* jade bloom — the frame itself exhales when the dot flips */}
      <AbsoluteFill
        style={{
          opacity: bloom,
          background:
            'radial-gradient(58% 34% at 50% 50%, rgba(53,194,133,0.30) 0%, rgba(53,194,133,0.09) 45%, rgba(53,194,133,0) 72%)',
        }}
      />

      {/* the stack */}
      <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center' }}>
        <div
          style={{
            width: COL,
            opacity: stackOut,
            transform: `scale(${interpolate(fold, [0, 1], [1, 0.9])})`,
          }}
        >
          <Rise start={4} distance={14}>
            <div
              style={{
                fontFamily: MONO,
                fontSize: 26,
                letterSpacing: 5,
                textTransform: 'uppercase',
                color: MUTED,
                marginBottom: 56,
                opacity: interpolate(frame, [190, 214], [1, 0], clamp),
              }}
            >
              What's between you and live
            </div>
          </Rise>

          <div style={{ position: 'relative' }}>
            {/* the connecting line, drawn downward */}
            <div
              style={{
                position: 'absolute',
                left: 9,
                top: 34,
                width: 2,
                height: ((ROW_H + ROW_GAP) * 3 - 42) * trail * (1 - fold),
                backgroundImage: `repeating-linear-gradient(180deg, ${LINE} 0px, ${LINE} 6px, transparent 6px, transparent 16px)`,
              }}
            />

            <div style={{ display: 'flex', flexDirection: 'column', gap: ROW_GAP }}>
              {LAYERS.map(([name, job], i) => {
                const s = spring({ frame: frame - (16 + i * 38), fps, config: { damping: 200 } });
                return (
                  <div
                    key={name}
                    style={{
                      display: 'flex',
                      alignItems: 'flex-start',
                      gap: 30,
                      minHeight: ROW_H,
                      opacity: s,
                      transform: `translateX(${interpolate(s, [0, 1], [40, 0])}px) translateY(${
                        fold * (1.5 - i) * 62
                      }px)`,
                    }}
                  >
                    <div style={{ paddingTop: 9 }}>
                      <Pip colour={INK_SOFT} size={20} />
                    </div>
                    <div>
                      <div
                        style={{
                          fontFamily: MONO,
                          fontSize: 34,
                          fontWeight: 600,
                          letterSpacing: 2,
                          color: INK,
                        }}
                      >
                        {name}
                      </div>
                      <div
                        style={{
                          fontFamily: SANS,
                          fontSize: 34,
                          color: MUTED,
                          marginTop: 8,
                          lineHeight: 1.3,
                        }}
                      >
                        {job}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </AbsoluteFill>

      {/* the address bar it collapses into */}
      <AbsoluteFill style={{ alignItems: 'center', justifyContent: 'center' }}>
        <div
          style={{
            opacity: arrive,
            transform: `translateY(${interpolate(arrive, [0, 1], [26, 0])}px) scale(${punch})`,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
          }}
        >
          <div style={{ position: 'relative', width: COL }}>
            {[0, 1].map((k) => {
              const { spread, o } = pulse(k);
              return (
                <div
                  key={k}
                  style={{
                    position: 'absolute',
                    left: -spread,
                    right: -spread,
                    top: -spread,
                    bottom: -spread,
                    borderRadius: 18 + spread,
                    border: `2px solid ${LIVE}`,
                    opacity: o,
                  }}
                />
              );
            })}

            <div
              style={{
                position: 'relative',
                display: 'flex',
                alignItems: 'center',
                gap: 22,
                width: '100%',
                boxSizing: 'border-box',
                padding: '30px 36px',
                borderRadius: 18,
                border: `1.5px solid ${barColour}`,
                background: flipped ? LIVE_WASH : SURFACE,
                boxShadow: flipped
                  ? `0 0 0 6px rgba(53,194,133,0.07), 0 26px 64px -28px rgba(53,194,133,0.55)`
                  : '0 1px 2px rgba(0,0,0,.4), 0 26px 64px -30px rgba(0,0,0,.8)',
              }}
            >
              <Pip colour={flipped ? LIVE : STUCK} size={20} halo={6} glow={flipped ? 26 : 14} />
              {flipped ? <Lock size={34} colour={LIVE} /> : null}
              <span
                style={{
                  fontFamily: MONO,
                  fontSize: 38,
                  color: flipped ? INK : MUTED,
                  letterSpacing: -0.4,
                  whiteSpace: 'nowrap',
                }}
              >
                {flipped ? 'https://shipwhatyoubuilt.com' : 'http://localhost:3000'}
              </span>
            </div>
          </div>

          {/* the four layers, resolved */}
          <div style={{ display: 'flex', gap: 16, marginTop: 58 }}>
            {CHIPS.map((c, i) => (
              <Rise key={c} start={302 + i * 13} distance={12}>
                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 11,
                    padding: '12px 18px',
                    borderRadius: 10,
                    border: `1px solid ${LINE_SOFT}`,
                    background: SURFACE,
                    fontFamily: MONO,
                    fontSize: 30,
                    color: MUTED,
                  }}
                >
                  <Pip colour={LIVE} size={12} />
                  {c}
                </div>
              </Rise>
            ))}
          </div>
        </div>
      </AbsoluteFill>
    </Scene>
  );
};

// ── beat 5 · what it actually is ──────────────────────────────────────────────
const PITCH: [string, number][] = [
  ['A free guide.', 10],
  ['Two tracks: Cloudflare or AWS.', 54],
  ["Written for people who've\nnever deployed anything.", 100],
];

const Pitch: React.FC = () => {
  const frame = useCurrentFrame();
  return (
    <Scene>
      <AbsoluteFill
        style={{
          padding: `0 ${PAD}px`,
          justifyContent: 'center',
          alignItems: 'flex-start',
        }}
      >
        <div style={{ display: 'flex', flexDirection: 'column', gap: 42, width: COL }}>
          {PITCH.map(([text, at], i) => {
            const next = PITCH[i + 1];
            // once the next line lands, this one settles back
            const settle = next
              ? interpolate(frame, [next[1], next[1] + 22], [1, 0.42], {
                  extrapolateLeft: 'clamp',
                  extrapolateRight: 'clamp',
                  easing: Easing.inOut(Easing.quad),
                })
              : 1;
            return (
              <Rise key={text} start={at} distance={22}>
                <div
                  style={{
                    fontFamily: SANS,
                    fontSize: 54,
                    fontWeight: 640,
                    letterSpacing: -1,
                    wordSpacing: 3,
                    lineHeight: 1.26,
                    color: INK,
                    opacity: settle,
                    whiteSpace: 'pre-wrap',
                  }}
                >
                  {text}
                </div>
              </Rise>
            );
          })}
        </div>
      </AbsoluteFill>
    </Scene>
  );
};

// ── beat 6 · end card ─────────────────────────────────────────────────────────
const End: React.FC = () => {
  const frame = useCurrentFrame();
  const rule = interpolate(frame, [46, 84], [0, 380], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.cubic),
  });

  return (
    <Scene>
      <AbsoluteFill
        style={{
          opacity: 0.13,
          background:
            'radial-gradient(56% 30% at 50% 56%, rgba(53,194,133,0.22) 0%, rgba(53,194,133,0) 72%)',
        }}
      />
      <AbsoluteFill style={{ padding: `0 ${PAD}px`, justifyContent: 'center' }}>
        <div style={{ width: COL }}>
          <Rise start={6} distance={26}>
            <div
              style={{
                fontFamily: SANS,
                fontSize: 84,
                fontWeight: 680,
                letterSpacing: -2,
                wordSpacing: 5,
                lineHeight: 1.08,
                color: INK,
              }}
            >
              You built something.
            </div>
          </Rise>
          <Rise start={26} distance={26}>
            <div
              style={{
                fontFamily: SANS,
                fontSize: 84,
                fontWeight: 680,
                letterSpacing: -2,
                wordSpacing: 5,
                lineHeight: 1.08,
                color: LIVE,
              }}
            >
              Now ship it.
            </div>
          </Rise>

          <div style={{ height: 1, width: rule, background: LINE, margin: '52px 0 44px' }} />

          <Rise start={60} distance={18}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 20 }}>
              <Pip colour={LIVE} size={16} halo={5} glow={18} />
              <span style={{ fontFamily: MONO, fontSize: 44, color: INK, letterSpacing: -0.5 }}>
                shipwhatyoubuilt.com
              </span>
            </div>
          </Rise>

          <Rise start={84} distance={16}>
            <div style={{ fontFamily: SANS, fontSize: 34, color: MUTED, marginTop: 26 }}>
              Free · open source · about an hour
            </div>
          </Rise>
        </div>
      </AbsoluteFill>
    </Scene>
  );
};

// ── the film ──────────────────────────────────────────────────────────────────
// 1050 frames @ 30fps = 35s. Sequences overlap by 14 so nothing ever dips.
export const LaunchVideo: React.FC = () => (
  <AbsoluteFill style={{ background: BG }}>
    <Sequence from={0} durationInFrames={284}>
      <Terminal />
    </Sequence>
    <Sequence from={270} durationInFrames={464}>
      <Layers />
    </Sequence>
    <Sequence from={720} durationInFrames={194}>
      <Pitch />
    </Sequence>
    <Sequence from={900} durationInFrames={150}>
      <End />
    </Sequence>
  </AbsoluteFill>
);
