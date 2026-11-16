#!/usr/bin/env bash
# Static build of the demo for Vercel.
# Vercel's build image has no nightly Rust / wasm-bindgen / wasm-snip toolchain,
# so the WASM rewriter is taken from packages/core/rewriter/prebuilt when it
# has not been built locally. Refresh that folder after changing rewriter code:
#   cd packages/core/rewriter/wasm && RELEASE=1 bash build.sh
#   cp -r out/wasm.js out/wasm.d.ts out/snippets ../prebuilt/ && cp out/optimized.wasm ../prebuilt/scramjet.wasm
set -euo pipefail
cd "$(dirname "$0")/.."

REWRITER=packages/core/rewriter
if [ ! -f "$REWRITER/wasm/out/wasm.js" ] || [ ! -f packages/core/dist/scramjet.wasm ]; then
	echo "Using prebuilt rewriter"
	mkdir -p "$REWRITER/wasm/out" packages/core/dist
	cp -r "$REWRITER/prebuilt/wasm.js" "$REWRITER/prebuilt/wasm.d.ts" "$REWRITER/prebuilt/snippets" "$REWRITER/wasm/out/"
	cp "$REWRITER/prebuilt/scramjet.wasm" packages/core/dist/scramjet.wasm
fi

pnpm exec rspack build --mode production

# Vercel cannot host the wisp WebSocket server, so the deployed demo needs an
# external one. Override by setting VITE_WISP_URL in the Vercel project.
export VITE_WISP_URL="${VITE_WISP_URL:-wss://wisp.mercurywork.shop/}"
pnpm --filter @mercuryworkshop/scramjet-demo build
