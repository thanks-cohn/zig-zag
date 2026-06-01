#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SMOKE_DIR="$ROOT_DIR/smoke_app"
OUTPUT_FILE="$ROOT_DIR/.smoke_app_output.txt"

cleanup() {
    rm -rf "$SMOKE_DIR"
    rm -f "$OUTPUT_FILE"
}
trap cleanup EXIT INT TERM

cd "$ROOT_DIR"
rm -rf "$SMOKE_DIR"
rm -f "$OUTPUT_FILE"

make build
./zig-out/bin/zag version
./zig-out/bin/zag help
./zig-out/bin/zag doctor
./zig-out/bin/zag new smoke_app

cd smoke_app
../zig-out/bin/zag run > "$OUTPUT_FILE" 2>&1

if ! grep -F "hello from zig.zg" "$OUTPUT_FILE" >/dev/null; then
    printf '%s\n' "smoke test failed: generated app output did not contain 'hello from zig.zg'" >&2
    printf '%s\n' "generated app output:" >&2
    cat "$OUTPUT_FILE" >&2
    exit 1
fi

printf '%s\n' "smoke test passed"
