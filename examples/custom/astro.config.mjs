import { defineConfig } from "astro/config";
import * as fs from "node:fs";
import { createRequire } from "node:module";
import astroTakumi from "astro-takumi-fork";
import { customOgMediaLayout } from "./src/customRenderer.ts";

const require = createRequire(import.meta.url);
const fontPath = require.resolve("@fontsource/roboto/files/roboto-latin-400-normal.woff");

// https://astro.build/config
export default defineConfig({
  site: "http://example.com",
  integrations: [
    astroTakumi({
      options: {
        fonts: [fs.readFileSync(fontPath)],
        verbose: true,
      },
      render: customOgMediaLayout,
    }),
  ],
});
