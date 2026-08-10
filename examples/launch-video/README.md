# The launch video for this guide

The real, working Remotion project used to make
[shipwhatyoubuilt.com/launch.mp4](https://shipwhatyoubuilt.com/launch.mp4) —
1080×1350, 35 seconds, no audio, because social feeds autoplay muted.

[Guide page: Make a launch video](../../guide/40-launch-video.md) explains the
concepts. This is the finished article to read alongside it.

```bash
npm install
npm run studio                                   # live preview while you edit
npx remotion render LaunchVideo out/launch.mp4   # the video
npx remotion still Card out/card.png             # a square still, for image posts
```

The story is told in beats, which is the part worth copying: a terminal showing
`localhost:3000` with an amber dot, the four layers assembling, then the same
dot turning jade on a real HTTPS address. One idea per beat, and the colour
flip carries the payoff.
