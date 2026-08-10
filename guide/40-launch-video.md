# Make a launch video

**You'll end with:** a 30-second video of your project, written as code in your
repository, rendered to an `.mp4` from the terminal — and regenerable in one
command every time the product changes.

**Time:** ~45 minutes for your first one. About ten for the next.
**Cost:** nothing. No editing software, no subscription, no stock footage site.

This chapter is optional. Everything before it got your thing online. This is
about getting it *seen*, and it is the single biggest lever left.

---

## 1. Why bother

On LinkedIn, X, Instagram and almost everywhere else, a video is the strongest
thing you can put in a post. It occupies more of the screen, it holds the thumb
for longer, and every one of those platforms would rather show it than show your
link.

But here is the part that changes everything about how you build it:

> **It autoplays muted.** Nearly nobody turns the sound on. Your video has to
> work with no audio at all — which means no voiceover, no music cue, no
> "as you can see here". Every single thing you want to communicate has to be on
> the screen, in text, large enough to read on a phone held at arm's length.

That is not a limitation you work around. It is the brief. A launch video is
closer to a **slide deck that animates itself** than to a film, and once you
accept that, making one stops being intimidating.

It also solves a real problem: you already made a static preview image in
[Share it](30-share-it.md). A video is that image, but it can show a *sequence* —
the problem, then the thing, then the URL — which a single still cannot.

---

## 2. What Remotion is

**[Remotion](https://www.remotion.dev)** lets you write a video as React
components — the same kind of function-that-returns-markup you'd write for a web
page. It renders each component once per frame in a headless browser (a real
Chrome with no window), then stitches those frames into an `.mp4`.

The value is not that it's easier than a video editor. Sometimes it isn't. The
value is that **your video is code**:

- It lives in your repository, next to the thing it advertises.
- `git diff` shows what changed between v1 and v2 of your video.
- Your product changed? Edit two lines, re-render, post the new one. No
  reopening a 4 GB project file and hunting for the layer you need.
- **Claude can edit it.** This is the real reason. Describing a design change in
  English and having it appear is dramatically faster than dragging keyframes,
  and it works precisely because the video is text.

If you have never opened video editing software in your life, this is an
advantage rather than a gap.

---

## 3. Getting started

Do this in a **new folder, next to your project** — not inside it. The video is
its own small project with its own dependencies, and keeping them separate means
your site's build never has to care that Remotion exists.

```bash
cd ~/dev
npx create-video@latest
```

It asks for a folder name and a template. **Pick the blank / "Hello World"
one.** The fancier templates are impressive and you will spend an hour
unpicking them.

Then:

```bash
cd my-launch-video
npm install
npm run dev
```

> Some scaffolds name that script `studio` rather than `dev`. Look in
> `package.json` — whichever one runs `remotion studio` is the right one.

### What you just got

```text
my-launch-video/
├── src/
│   ├── index.ts        ← one line: hands your Root to Remotion
│   ├── Root.tsx        ← the list of videos this project can render
│   └── HelloWorld.tsx  ← an actual video
├── package.json
└── tsconfig.json
```

That is genuinely all of it. `index.ts` is three lines and you will never touch
it again:

```tsx
import { registerRoot } from 'remotion';
import { RemotionRoot } from './Root';
registerRoot(RemotionRoot);
```

### The Studio

`npm run dev` opens the **Remotion Studio** in your browser at
`http://localhost:3000`. It is the closest thing here to a normal video editor,
and it has three parts:

- **Left:** the list of compositions — the videos this project knows how to
  render. Click one to load it.
- **Middle:** a live preview. Press space to play.
- **Bottom:** a **timeline** with a playhead and a frame counter. Drag it and
  the preview jumps to that exact frame. You can also step one frame at a time
  with the arrow keys, which you will do constantly.

The important behaviour: **save a file and the preview updates immediately**,
holding your position in the timeline. That is the whole development loop. Park
the playhead on the frame you're fiddling with, put the editor and the Studio
side by side, and change numbers until it looks right.

---

## 4. The mental model, and the seven things that make it work

Here is the idea the entire tool rests on, and it is worth reading twice:

> **A video is a pure function of the frame number.**
>
> Remotion asks your component "what does frame 412 look like?", screenshots the
> answer, then asks about frame 413. Nothing is remembered between frames.
> Nothing "moves". There is no playback, no state, no timeline object. There is
> only: given this number, draw this picture.

Everything below is a consequence of that.

### `useCurrentFrame()` — the number

```tsx
import { useCurrentFrame } from 'remotion';

export const Counter: React.FC = () => {
  const frame = useCurrentFrame();
  return <h1>Frame {frame}</h1>;
};
```

That is a complete, working video. It counts. Every animation you ever write is
this hook plus arithmetic.

### `fps` and `durationInFrames` — the exchange rate

There are no seconds anywhere in Remotion. There are frames, and there is
**fps** (frames per second), which converts between the two:

```text
durationInFrames ÷ fps = seconds
1085 ÷ 30 = 36.2 seconds
```

**Use 30 fps.** It is the default, every social platform re-encodes to something
like it anyway, and it makes the mental arithmetic easy: one second is thirty
frames, so a beat that should last three seconds is ninety frames.

### `<Composition>` — declaring a video

`Root.tsx` is a list of the videos this project can produce. Each one is a
`<Composition>`:

```tsx
import { Composition } from 'remotion';
import { RouteVideo } from './RouteVideo';

export const RemotionRoot: React.FC = () => (
  <>
    <Composition
      id="RouteVideo"
      component={RouteVideo}
      durationInFrames={1085}
      fps={30}
      width={1080}
      height={1350}
    />
  </>
);
```

The **`id`** is the name you type on the command line to render it, and the name
that appears in the Studio's sidebar. One project can hold as many compositions
as you like — a vertical cut, a square cut, and a one-frame still image, all
sharing the same components.

### `<AbsoluteFill>` — the layer

A `<div>` that is absolutely positioned and fills the frame edge to edge. It is
the background, the safe area, and the layering primitive all at once — stack
two of them and the second sits on top of the first.

In practice you wrap it once, in a helper, so every scene in your video shares
the same padding and background without repeating yourself:

```tsx
const Shell: React.FC<{ children: React.ReactNode; gap?: number }> = ({ children, gap = 36 }) => (
  <AbsoluteFill
    style={{
      background: '#0B0E14',
      padding: '70px 74px',
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'center',
      gap,
    }}
  >
    {children}
  </AbsoluteFill>
);
```

Flexbox inside an `AbsoluteFill` is how essentially all of this gets laid out.
No absolute pixel positions, no "nudge it left by 4" — the same CSS you'd use
for a web page.

### `<Sequence>` — scheduling, and the trick that makes it manageable

`<Sequence>` shows its children only during a window of frames. But the reason
it matters is subtler and much more useful:

> **Inside a `<Sequence from={95}>`, `useCurrentFrame()` returns `0` at the
> video's frame 95.** Time is shifted, not just clipped.

So every scene can be written as if the video starts when *it* starts. You never
do global-frame arithmetic. Here is a real, shipped timeline — six scenes,
1085 frames, 36 seconds:

```tsx
export const RouteVideo: React.FC = () => (
  <AbsoluteFill style={{ background: BG }}>
    <Sequence from={0}   durationInFrames={95}>  <Title />   </Sequence>
    <Sequence from={95}  durationInFrames={180}> <Pools />   </Sequence>
    <Sequence from={275} durationInFrames={235}> <Decide />  </Sequence>
    <Sequence from={510} durationInFrames={250}> <Loop />    </Sequence>
    <Sequence from={760} durationInFrames={185}> <Privacy /> </Sequence>
    <Sequence from={945} durationInFrames={140}> <Outro />   </Sequence>
  </AbsoluteFill>
);
```

Read that as the storyboard, because that is exactly what it is. Each `from` is
the previous `from` plus the previous `durationInFrames`, and the last one lands
on 1085 — which is the `durationInFrames` on the `<Composition>`. Keep those two
numbers agreeing and most timing bugs never happen.

`<Title />`, `<Pools />` and the rest are just components in the same file, each
one written as though it were the only thing in the world.

### `interpolate()` — mapping frames to values

The workhorse. "As the frame goes from *here* to *there*, take this value from
*this* to *that*."

```tsx
import { interpolate, Easing } from 'remotion';

const frame = useCurrentFrame();

// Between frames 22 and 54, grow a rule from 0% to 100% wide.
const rule = interpolate(frame, [22, 54], [0, 100], {
  extrapolateRight: 'clamp',
  easing: Easing.out(Easing.cubic),
});

return <div style={{ height: 3, background: ACCENT, width: `${rule}%` }} />;
```

Two things that will bite you exactly once:

- **`extrapolateRight: 'clamp'`.** Without it, `interpolate` keeps going.
  At frame 500 that rule is 1500% wide. Clamp both ends
  (`extrapolateLeft: 'clamp'` too) unless you specifically want the value to
  keep running.
- **`easing`.** Linear motion looks mechanical. `Easing.out(Easing.cubic)`
  starts fast and settles — right for something arriving.
  `Easing.inOut(Easing.cubic)` is right for something travelling across the
  screen.

### `spring()` — natural motion, without thinking about easing

`spring()` returns a number that travels from 0 to 1 with physics, which reads
as more alive than any easing curve you'd pick by hand.

```tsx
import { spring, useCurrentFrame, useVideoConfig } from 'remotion';

const frame = useCurrentFrame();
const { fps } = useVideoConfig();

const s = spring({ frame: frame - start, fps, config: { damping: 200 } });
```

- `frame - start` is how you delay it. The spring only begins once `frame`
  passes `start`.
- `useVideoConfig()` gives you `fps`, `width`, `height` and
  `durationInFrames` — the spring needs `fps` because springs are defined in
  real time.
- `damping: 200` means **no wobble** — it arrives and stops. The default
  overshoots slightly, which is charming for a bouncing ball and wrong for a
  headline.

### The one helper that does most of the work

Put those two together and you get the component that, in practice, animates
almost everything in a launch video:

```tsx
const Rise: React.FC<{ start: number; children: React.ReactNode; distance?: number }> = ({
  start,
  children,
  distance = 26,
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
```

One spring drives **both** the fade and the movement, so they can never drift
out of step. Now your entire scene is written in plain English:

```tsx
<Shell>
  <Rise start={2}>  <Eyebrow>Five places a task could run</Eyebrow> </Rise>
  <Rise start={8}>  <Headline>Which one gets it?</Headline>         </Rise>
  <Rise start={22}> <Row name="Claude" />                            </Rise>
  <Rise start={33}> <Row name="Codex" />                             </Rise>
  <Rise start={44}> <Row name="Kimi" />                              </Rise>
</Shell>
```

Staggering `start` by 11 frames per row is the whole "list animates in" effect.
That is roughly 90% of the motion in a good launch video, and you now know all
of it.

---

## 5. Rendering

```bash
npx remotion render RouteVideo out/route-launch.mp4
```

The composition `id`, then where to put the file. That's it. A 36-second
1080×1350 video takes a couple of minutes on a laptop and lands at around 3 MB —
comfortably inside every platform's limit.

Put it in `package.json` so you never have to remember it:

```json
{
  "scripts": {
    "dev": "remotion studio",
    "render": "remotion render RouteVideo out/route-launch.mp4"
  }
}
```

### Render a still frame

This is the command you will use most, and not for the reason you'd expect:

```bash
npx remotion still RouteVideo out/rv-220.png --frame=220
```

**As a fallback post:** some places still prefer an image, and a frame from your
own video is a better one than a screenshot.

**As your iteration loop:** rather than watching a 36-second video back to check
one beat, render the first frame of each scene as a PNG and look at all six at
once. Pick the frame numbers straight out of your `<Sequence>` list:

```bash
for f in 40 180 420 640 850 1010; do
  npx remotion still RouteVideo out/nv-$f.png --frame=$f
done
```

**And as an image generator.** A composition with `durationInFrames={1}` is not
really a video at all — it's a designed PNG, made from the same components and
the same palette as your video:

```tsx
<Composition id="Og" component={LaunchCard}
  durationInFrames={1} fps={30} width={1200} height={630} />
```

```bash
npx remotion still Og preview.png
```

That is the exact 1200×630 Open Graph image from
[Share it](30-share-it.md) — the picture that appears when someone pastes your
link — now produced by one command and guaranteed to match your video.

---

## 6. Sizes that matter

Set these on the `<Composition>` (`width` and `height`). If you want two shapes,
make two compositions pointing at the same component rather than editing numbers
back and forth.

| Size | Ratio | Use it for |
|---|---|---|
| **1080×1350** | 4:5 vertical | **The default.** LinkedIn and Instagram feeds. The tallest thing the feed allows, so it takes the most screen for the same scroll |
| **1080×1080** | 1:1 square | Safe absolutely everywhere — X, Slack, Discord, anywhere you're unsure |
| **1920×1080** | 16:9 landscape | YouTube, embedding in your README or site, anything shown on a monitor |
| **1200×630** | 1.91:1 still | Not a video. The Open Graph preview image for your link ([chapter 30](30-share-it.md)) |

If in doubt, **1080×1350**. If you're posting the same video to several places
and can only be bothered making one, **1080×1080** never looks wrong anywhere.

> Full-screen vertical (1080×1920, 9:16) is for Stories, Reels, Shorts and
> TikTok. It's a different edit with a different pace, not a re-crop, so don't
> reach for it just to cover more platforms.

---

## 7. Get Claude to do it

Here is the honest fastest path: **describe the video, let Claude write it, then
fix it in the Studio.** You now understand enough of the model to review what
comes back and to say precisely what's wrong with it, which is the part that
matters.

First, give Claude the official Remotion instructions — the Remotion team ship a
skill for exactly this, and it stops the guessing about current API shapes:

```bash
npx remotion skills add
```

Then, from inside the video folder, paste something like this — changing the
project, the colours and the beats to yours:

> Build me a launch video for **Tide Clock** in this Remotion project.
>
> **Composition:** id `Launch`, **1080×1350**, **30 fps**, **1080 frames**
> (36 seconds).
>
> **Palette:** background `#0B0E14`, panel `#0F141B`, border `#1E2630`,
> text `#C9D1D9`, dim text `#6E7681`, accent `#D97757`, green `#3FB950`,
> cyan `#56D4DD`.
>
> **Fonts:** system stacks only — no webfonts, no `@import`.
> Sans: `-apple-system, BlinkMacSystemFont, "Segoe UI", Inter, Helvetica, Arial, sans-serif`.
> Mono: `ui-monospace, SFMono-Regular, Menlo, Consolas, monospace`.
>
> **No audio.** It must read completely with the sound off.
>
> **The beats, in order — one `<Sequence>` each:**
>
> 1. **0–105** (3.5 s) — The problem, one huge line: *"You can't tell from the
>    kitchen window whether it's safe to swim."* Accent rule draws underneath it.
> 2. **105–330** (7.5 s) — The answer: *"Tide Clock"*, one supporting line, and
>    the tagline *today's tides for your nearest beach*.
> 3. **330–600** (9 s) — **The hero beat.** A mocked-up phone screen showing the
>    tide curve, with the "safe to swim" window highlighting in green as it
>    animates in. This is the beat that has to be good.
> 4. **600–810** (7 s) — How it's built: three stacked rows, staggered in —
>    *no app to install*, *works offline*, *free forever*.
> 5. **810–960** (5 s) — *Open source, MIT licensed* with the GitHub repo path
>    in mono.
> 6. **960–1080** (4 s) — Hold on the URL, **tide-clock.example.com**, large and
>    still. Nothing else moving.
>
> **Structure:** one component per beat in one file, plus a shared `Shell`
> (AbsoluteFill, background, padding, flex column) and a `Rise` helper that
> springs `opacity` and `translateY` together with a `start` prop. Stagger list
> items by about 11 frames.
>
> Text must be readable at phone size — nothing under about 24px at this
> resolution. Render a still at frames 40, 200, 450, 700, 880 and 1020 when
> you're done so I can check each beat.

### Why that prompt works

It leaves nothing to guess, and that is the entire trick:

- **The story is specified beat by beat, with frame numbers**, so Claude is
  arranging content rather than inventing a narrative. Note that the frames add
  up exactly to 1080 — a budget that balances is the single most useful thing
  you can hand over.
- **The colours are hex codes**, not "make it look modern". Six hex values buy
  you more design consistency than six paragraphs of adjectives.
- **The dimensions and fps are named**, so nothing has to be resized later, and
  "is this text big enough" has an actual answer.
- **The constraints are stated as constraints** — no audio, no webfonts, minimum
  text size. These are the three things that silently ruin a launch video, and
  each is one line to prevent.
- **It names the hero beat.** Every video has one beat that does the work. Say
  which, or effort gets spread evenly across six beats that are all fine and
  none memorable.

### Then iterate in the Studio, not in the chat

Keep `npm run dev` running the whole time. When something's off, **look at it,
scrub to the frame, and describe the fix in frames and pixels**:

> The headline in beat 3 collides with the phone mock between frames 380 and
> 420. Drop the headline to 52px and start the phone at frame 400 instead of 360.

That is a ten-second fix. Trying to describe the same problem from memory,
without the playhead parked on it, is how you end up with three rounds of
"a bit more". Seeing it is always faster than describing it.

---

## 8. What makes a launch video actually good

Short list. All of it earned the hard way.

- **Open on the problem, not the product.** Nobody knows what your thing is
  called and nobody is waiting to find out. "You can't tell from the window
  whether the tide is in" earns the next three seconds. A logo does not.
- **One idea per beat.** If a beat needs two sentences to explain, it's two
  beats. The commonest fault in a first video is four points crammed into three
  seconds, which lands as none.
- **Text large enough for a phone.** Check it by shrinking the Studio preview to
  roughly thumbnail size. If you can't read it there, it doesn't exist.
- **No audio dependency at all.** No voiceover, no "listen to this". Ship it
  with a silent track and assume nobody will ever hear it — because they won't.
- **Under 40 seconds.** 30 is better. Watch-through rate is what the feed
  rewards, and a complete 25-second video beats an abandoned 90-second one every
  time.
- **End on the URL, and hold it.** Last beat, four seconds, nothing else moving.
  This is the only frame with a job beyond attention: it has to be readable
  long enough to be typed.

And one that sits underneath all of them: **watch it once with your eyes
half-shut**, the way people actually see it while scrolling. If the shape of it
still tells the story, it works.

---

## 9. When it breaks

| Symptom | Cause and fix |
|---|---|
| `Chrome Headless Shell` not found, or render exits instantly on a fresh machine | Remotion needs its own browser. `npx remotion browser ensure`. On a bare Linux box you may also be missing Chrome's system libraries — the error names them |
| Looking for a system `ffmpeg` to install | You don't need one. Remotion 4 bundles its own renderer. If a tutorial tells you to `brew install ffmpeg`, it was written for Remotion 3 |
| Fonts look right in the Studio but wrong in the rendered file | Almost always a bare CSS `@import`. The renderer screenshots each frame the moment it's ready, which can be before the webfont has downloaded — so it silently falls back. **Never use `@import` in a Remotion project.** Use a system font stack (as in the prompt above), or `npx remotion add @remotion/google-fonts` and its `loadFont()`, which tells the renderer to wait |
| `Cannot find module` or type errors after adding a Remotion package | Mismatched versions across `@remotion/*`. `npx remotion versions` reports it; install with `npx remotion add <package>` rather than `npm install` so versions stay locked together |
| The file is too large for the platform | Raise `--crf` (higher number, smaller file — try `--crf 28`), or shorten it. Shortening is nearly always the better answer |
| The last beat is cut off, or the video ends mid-animation | The final `<Sequence>`'s `from + durationInFrames` overruns the `durationInFrames` on the `<Composition>`. Add the sequence durations up — they must equal the composition's, exactly |
| A beat is blank | A `<Sequence from={N}>` with an inner animation whose `start` is written in *global* frames. Inside a Sequence, frame counting restarts at 0 — `start` is relative to that scene |
| Preview stutters or drops frames | Preview only. It renders live in a browser tab; the final render is frame-exact and unaffected. Don't chase it |
| Platform rejects the upload for having no audio | Remotion adds a silent audio track by default for exactly this reason. If you disabled it, put it back: `--enforce-audio-track` |

---

## And then post it

You have a video, a still from it, and an Open Graph image — all three generated
from the same file, all three regenerable when the product moves.

The advice in [Share it](30-share-it.md) still applies: lead with the thing, put
the link in the post rather than the first comment, say what surprised you. Add
the video, and add yourself to the [showcase](../SHOWCASE.md).

When you ship v2, change the two lines that are now wrong, run `npm run render`,
and post again. That is the whole point of having built it out of code.

---

**Next:** [When it breaks →](90-troubleshooting.md) — for when the render, the
deploy, or the DNS doesn't do what it said it would.
