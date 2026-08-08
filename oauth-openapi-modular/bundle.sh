#!/usr/bin/env bash
# Bundle the multi-file spec into a single distributable file, then lint it.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p dist
npx -y @redocly/cli@latest bundle openapi.yaml -o dist/oauth-openapi.bundled.yaml
npx -y @stoplight/spectral-cli@latest lint dist/oauth-openapi.bundled.yaml
echo "OK -> dist/oauth-openapi.bundled.yaml"
