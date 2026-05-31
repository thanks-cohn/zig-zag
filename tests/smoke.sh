#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/zag-smoke.XXXXXX")
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

cd "$ROOT_DIR"
zig build
./zig-out/bin/zag version
./zig-out/bin/zag doctor

cd "$TMP_DIR"
"$ROOT_DIR/zig-out/bin/zag" new smoke_app
cd smoke_app
zig build
zig build run
