import { Composition } from 'remotion';
import { Card } from './Card';
import { LaunchVideo } from './LaunchVideo';

export const RemotionRoot: React.FC = () => (
  <>
    {/* 1080x1350 vertical — LinkedIn video post. 1050 frames @ 30fps = 35s. */}
    <Composition
      id="LaunchVideo"
      component={LaunchVideo}
      durationInFrames={1050}
      fps={30}
      width={1080}
      height={1350}
    />
    {/* 1080x1080 square — fallback image post. */}
    <Composition id="Card" component={Card} durationInFrames={1} fps={30} width={1080} height={1080} />
  </>
);
