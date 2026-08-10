import React from 'react';
import { AbsoluteFill } from 'remotion';
import { C, SANS, MONO, PAD } from './theme';
import { Grid } from './parts';

/**
 * 1080x1080 square still, for an image post or the Open Graph preview.
 * Same palette and typographic split as the site and the video.
 */
export const Card: React.FC = () => (
  <AbsoluteFill style={{ background: C.bg }}>
    <Grid />
    <AbsoluteFill
      style={{
        padding: PAD,
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        gap: 30,
      }}
    >
      <div
        style={{
          fontFamily: MONO,
          fontSize: 26,
          letterSpacing: '0.2em',
          textTransform: 'uppercase',
          color: C.live,
        }}
      >
        A free, open-source guide
      </div>

      <div
        style={{
          fontFamily: SANS,
          fontSize: 96,
          lineHeight: 1.02,
          letterSpacing: '-0.034em',
          fontWeight: 680,
          color: C.ink,
        }}
      >
        You built something.
        <br />
        <span style={{ color: C.live }}>Now ship it.</span>
      </div>

      {/* The transformation the whole guide is about, stated literally. */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 20, marginTop: 16, flexWrap: 'wrap' }}>
        <span
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: 14,
            padding: '16px 24px',
            borderRadius: 12,
            border: `2px solid ${C.line}`,
            background: C.surface,
            fontFamily: MONO,
            fontSize: 30,
            color: C.muted,
            textDecoration: 'line-through',
            textDecorationThickness: 2,
          }}
        >
          <span style={{ width: 13, height: 13, borderRadius: '50%', background: C.stuck }} />
          localhost:3000
        </span>
        <span style={{ fontFamily: SANS, fontSize: 34, color: C.muted }}>→</span>
        <span
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: 14,
            padding: '16px 24px',
            borderRadius: 12,
            border: `2px solid ${C.live}`,
            background: C.liveWash,
            fontFamily: MONO,
            fontSize: 30,
            color: C.ink,
          }}
        >
          <span
            style={{
              width: 13,
              height: 13,
              borderRadius: '50%',
              background: C.live,
              boxShadow: `0 0 0 6px ${C.liveWash}`,
            }}
          />
          https://yourthing.com
        </span>
      </div>

      <div
        style={{
          marginTop: 26,
          paddingTop: 30,
          borderTop: `1px solid ${C.lineSoft}`,
          display: 'flex',
          alignItems: 'baseline',
          justifyContent: 'space-between',
          gap: 20,
        }}
      >
        <span style={{ fontFamily: MONO, fontSize: 34, color: C.ink }}>shipwhatyoubuilt.com</span>
        <span style={{ fontFamily: SANS, fontSize: 27, color: C.muted }}>
          Domain, hosting and GitHub
        </span>
      </div>
    </AbsoluteFill>
  </AbsoluteFill>
);
