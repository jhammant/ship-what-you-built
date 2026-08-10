import { Config } from '@remotion/cli/config';

// Dark-only by design — never let a white frame flash through.
Config.setChromiumDisableWebSecurity(false);
Config.setVideoImageFormat('jpeg');
Config.setOverwriteOutput(true);
Config.setCodec('h264');
// LinkedIn re-encodes anyway; keep the source clean so it survives the pass.
Config.setCrf(17);
