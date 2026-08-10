import React from 'react';
import {
  AbsoluteFill,
  Sequence,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
  Easing,
} from 'remotion';
import { C, SANS, MONO } from "./theme";
import { Stage, Rise, Eyebrow, H1, Body, Pill, LayerRow, Spine } from './parts';

// ---------------------------------------------------------------- timeline
// Scenes overlap by OVERLAP frames and only ever fade IN, so there is never a
// dip to the background between them.
const OVERLAP = 14;
const INTRO = { from: 0, dur: 130 };
const LOCAL = { from: 130, dur: 200 };
const LAYERS = { from: 320, dur: 330 };
const FLIP = { from: 640, dur: 230 };
const PITCH = { from: 860, dur: 160 };
const END = { from: 1010, dur: 160 };
export const TOTAL = END.from + END.dur; // 1170 frames @30fps = 39s

// ------------------------------------------------------------------ scene 1
// The intro doubles as the video's thumbnail, so frame 0 is fully composed —
// nothing here fades in from nothing.
const Intro: React.FC = () => {
  const frame = useCurrentFrame();
  const out = interpolate(frame, [INTRO.dur - OVERLAP, INTRO.dur], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  return (
    <AbsoluteFill style={{ opacity: out }}>
      <Stage>
        <Rise still>
          <Eyebrow>A free, open-source guide</Eyebrow>
        </Rise>
        <Rise still>
          <H1>
            Ship What
            <br />
            You Built
          </H1>
        </Rise>
        <Rise still>
          <Body size={40}>
            How to get the thing you made onto the internet — a real domain, HTTPS,
            GitHub, and deploys that happen on their own.
          </Body>
        </Rise>
        <Rise still>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 18,
              marginTop: 14,
              paddingTop: 30,
              borderTop: `1px solid ${C.lineSoft}`,
            }}
          >
            <span
              style={{
                width: 16,
                height: 16,
                borderRadius: '50%',
                background: C.live,
                boxShadow: `0 0 0 7px ${C.liveWash}`,
              }}
            />
            <span style={{ fontFamily: MONO, fontSize: 38, color: C.ink }}>
              shipwhatyoubuilt.com
            </span>
          </div>
        </Rise>
      </Stage>
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------------ scene 2
const Local: React.FC = () => {
  const frame = useCurrentFrame();
  const out = interpolate(frame, [LOCAL.dur - OVERLAP, LOCAL.dur], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  return (
    <AbsoluteFill style={{ opacity: out }}>
      <Stage>
        <Rise at={4}>
          <H1>You built something.</H1>
        </Rise>
        <Rise at={22}>
          <Body size={40}>It works. You're proud of it.</Body>
        </Rise>
        <Rise at={54}>
          <div style={{ marginTop: 20 }}>
            <Pill text="localhost:3000" state="dead" />
          </div>
        </Rise>
        <Rise at={104}>
          <Body size={44} colour={C.ink}>
            And nobody else can see it.
          </Body>
        </Rise>
      </Stage>
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------------ scene 3
const ROWS = [
  ['1', 'REGISTRAR', 'Who you bought the name from'],
  ['2', 'DNS', 'Answers “where is yourthing.com?”'],
  ['3', 'HOSTING', 'Where your code actually lives'],
  ['4', 'CERTIFICATE', 'Proves it is really you'],
] as const;

const Layers: React.FC = () => {
  const frame = useCurrentFrame();
  const out = interpolate(frame, [LAYERS.dur - OVERLAP, LAYERS.dur], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  return (
    <AbsoluteFill style={{ opacity: out }}>
      <Stage>
        <Rise at={2}>
          <Eyebrow>Four layers, four companies</Eyebrow>
        </Rise>
        <Rise at={10}>
          <H1 size={72}>Between you and a URL</H1>
        </Rise>
        <div style={{ position: 'relative', marginTop: 26 }}>
          {/* 3 gaps between 4 dots; each row is ~88px tall plus the 52px gap. */}
          <Spine at={44} height={(ROWS.length - 1) * 140} />
          <div style={{ position: 'relative', display: 'flex', flexDirection: 'column', gap: 52 }}>
            {ROWS.map(([n, name, desc], i) => (
              <LayerRow key={n} n={Number(n)} name={name} desc={desc} at={40 + i * 34} />
            ))}
          </div>
        </div>
        <Rise at={210}>
          <Body size={34} colour={C.muted}>
            Independent of each other — so no choice you make today is a trap.
          </Body>
        </Rise>
      </Stage>
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------------ scene 4
// The payoff. The amber dot from scene 2 becomes jade on a real address; that
// colour change is the whole point of the film, so it is the only hard cut.
const FLIP_AT = 96;

const Flip: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const flipped = frame >= FLIP_AT;

  const punch = spring({
    frame: frame - FLIP_AT,
    fps,
    config: { damping: 9, stiffness: 190, mass: 0.5 },
  });
  const scale = flipped ? 1 + 0.05 * Math.max(0, 1 - punch) : 1;
  const glow = flipped
    ? interpolate(frame - FLIP_AT, [0, 34], [1, 0.25], {
        extrapolateLeft: 'clamp',
        extrapolateRight: 'clamp',
      })
    : 0;

  const out = interpolate(frame, [FLIP.dur - OVERLAP, FLIP.dur], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{ opacity: out }}>
      <Stage>
        <Rise at={4}>
          <Eyebrow colour={flipped ? C.live : C.muted}>
            {flipped ? 'Live' : 'About twenty minutes later'}
          </Eyebrow>
        </Rise>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 30, marginTop: 12 }}>
          <Rise at={10}>
            <Pill text="localhost:3000" state="dead" size={34} />
          </Rise>
          <Rise at={28}>
            <div style={{ fontFamily: SANS, fontSize: 46, color: C.muted, paddingLeft: 10 }}>↓</div>
          </Rise>
          <Rise at={40}>
            <Pill
              text="https://shipwhatyoubuilt.com"
              state={flipped ? 'alive' : 'dead'}
              lock={flipped}
              glow={glow}
              scale={scale}
              size={38}
            />
          </Rise>
        </div>
        <Rise at={FLIP_AT + 20}>
          <Body size={36} colour={C.inkSoft}>
            A domain you own, over HTTPS, deploying itself when you push.
          </Body>
        </Rise>
      </Stage>
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------------ scene 5
const LINES = [
  'Two tracks: Cloudflare or AWS.',
  'Written for people who have never deployed anything.',
  'Free, open source, and it was run start to finish.',
];

const Pitch: React.FC = () => {
  const frame = useCurrentFrame();
  const out = interpolate(frame, [PITCH.dur - OVERLAP, PITCH.dur], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  return (
    <AbsoluteFill style={{ opacity: out }}>
      <Stage>
        {LINES.map((l, i) => (
          <Rise key={l} at={6 + i * 30}>
            <div style={{ display: 'flex', gap: 22, alignItems: 'baseline' }}>
              <span
                style={{
                  width: 13,
                  height: 13,
                  borderRadius: '50%',
                  background: C.live,
                  flex: 'none',
                }}
              />
              <span style={{ fontFamily: SANS, fontSize: 46, color: C.ink, lineHeight: 1.3 }}>
                {l}
              </span>
            </div>
          </Rise>
        ))}
      </Stage>
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------------ scene 6
const End: React.FC = () => (
  <AbsoluteFill>
    <Stage>
      <Rise at={2}>
        <H1>
          You built something.
          <br />
          <span style={{ color: C.live }}>Now ship it.</span>
        </H1>
      </Rise>
      <Rise at={26}>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 18,
            marginTop: 18,
            paddingTop: 32,
            borderTop: `1px solid ${C.lineSoft}`,
          }}
        >
          <span
            style={{
              width: 16,
              height: 16,
              borderRadius: '50%',
              background: C.live,
              boxShadow: `0 0 0 7px ${C.liveWash}`,
            }}
          />
          <span style={{ fontFamily: MONO, fontSize: 40, color: C.ink }}>
            shipwhatyoubuilt.com
          </span>
        </div>
      </Rise>
      <Rise at={44}>
        <Body size={32} colour={C.muted}>
          Free · open source · about an hour
        </Body>
      </Rise>
    </Stage>
  </AbsoluteFill>
);

// -------------------------------------------------------------------- film
export const LaunchVideo: React.FC = () => (
  <AbsoluteFill style={{ background: C.bg }}>
    <Sequence from={INTRO.from} durationInFrames={INTRO.dur + OVERLAP}>
      <Intro />
    </Sequence>
    <Sequence from={LOCAL.from} durationInFrames={LOCAL.dur + OVERLAP}>
      <Local />
    </Sequence>
    <Sequence from={LAYERS.from} durationInFrames={LAYERS.dur + OVERLAP}>
      <Layers />
    </Sequence>
    <Sequence from={FLIP.from} durationInFrames={FLIP.dur + OVERLAP}>
      <Flip />
    </Sequence>
    <Sequence from={PITCH.from} durationInFrames={PITCH.dur + OVERLAP}>
      <Pitch />
    </Sequence>
    <Sequence from={END.from} durationInFrames={END.dur}>
      <End />
    </Sequence>
  </AbsoluteFill>
);
