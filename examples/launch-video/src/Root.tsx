import { Composition } from 'remotion';
import { Card } from './Card';
import { LaunchVideo, TOTAL } from './LaunchVideo';

export const RemotionRoot: React.FC = () => (
  <>
    {/* 1080x1350 vertical — LinkedIn video post. Frame 0 is the thumbnail. */}
    <Composition
      id="LaunchVideo"
      component={LaunchVideo}
      durationInFrames={TOTAL}
      fps={30}
      width={1080}
      height={1350}
    />
    {/* 1080x1080 square — fallback image post. */}
    <Composition id="Card" component={Card} durationInFrames={1} fps={30} width={1080} height={1080} />
  </>
);
