#!/usr/bin/env bash

set -euo pipefail

# Ensure preset example is built so dist/index.html exists
if [ ! -f "examples/preset/dist/index.html" ]; then
  echo "Building examples/preset..."
  bun run build
  bun --cwd examples/preset build
fi

# Recreate presets directory and generated examples
mkdir -p assets/presets
rm -rf assets/presets/*

bun run packages/astro-takumi-fork/src/presets/renderExamples.ts

if command -v gomplate >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  presets=$(ls -1 assets/presets/ 2>/dev/null | jq -R . | jq -s .)
  export presets
  gomplate -f README.md.tmpl -d presets=env:///presets?type=application/json > README.md
else
  echo "gomplate/jq not found; using Node.js to render README.md..."
  node -e '
    const fs = require("fs");
    const tmpl = fs.readFileSync("README.md.tmpl", "utf8");
    const presets = fs.readdirSync("assets/presets").filter(f => f.endsWith(".png")).sort();
    const rangeRegex = /\{\{\s*range\s+\$preset\s*:=\s*\(ds "presets"\)\s*-\}\}([\s\S]*?)\{\{\s*end\s*\}\}/;
    const match = tmpl.match(rangeRegex);
    if (match) {
      const blockTmpl = match[1];
      const rendered = presets.map(file => {
        const name = file.replace(".png", "");
        return blockTmpl
          .replace(/\{\{\s*strings\.ReplaceAll "\.png" "" \$preset\s*\}\}/g, name)
          .replace(/\{\{\s*\$preset\s*\}\}/g, file);
      }).join("\n");
      const output = tmpl.replace(rangeRegex, rendered.trimStart());
      fs.writeFileSync("README.md", output, "utf8");
    }
  '
fi
echo "README.md successfully updated!"
