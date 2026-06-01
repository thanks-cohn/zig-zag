#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SMOKE_DIR="$ROOT_DIR/smoke_app"
EXISTING_DIR="$ROOT_DIR/existing_app"
NOT_ZIG_DIR="$ROOT_DIR/not_a_zig_project"
OUTPUT_FILE="$ROOT_DIR/.smoke_app_output.txt"
ERROR_FILE="$ROOT_DIR/.smoke_error_output.txt"

cleanup() {
    rm -rf "$SMOKE_DIR" "$EXISTING_DIR" "$NOT_ZIG_DIR"
    rm -f "$OUTPUT_FILE" "$ERROR_FILE"
}
trap cleanup EXIT INT TERM

expect_failure_contains() {
    command_text=$1
    expected_text=$2
    shift 2

    rm -f "$ERROR_FILE"
    if "$@" > "$ERROR_FILE" 2>&1; then
        printf '%s\n' "smoke test failed: expected command to fail: $command_text" >&2
        cat "$ERROR_FILE" >&2
        exit 1
    fi

    if ! grep -F "$expected_text" "$ERROR_FILE" >/dev/null; then
        printf '%s\n' "smoke test failed: missing '$expected_text' from: $command_text" >&2
        printf '%s\n' "command output:" >&2
        cat "$ERROR_FILE" >&2
        exit 1
    fi
}

cd "$ROOT_DIR"
cleanup

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

cd "$ROOT_DIR"
expect_failure_contains "./zig-out/bin/zag does-not-exist" "ZAG_E_UNKNOWN_COMMAND" ./zig-out/bin/zag does-not-exist
expect_failure_contains "./zig-out/bin/zag new ../bad" "ZAG_E_BAD_PROJECT_NAME" ./zig-out/bin/zag new "../bad"

mkdir existing_app
expect_failure_contains "./zig-out/bin/zag new existing_app" "ZAG_E_PROJECT_EXISTS" ./zig-out/bin/zag new existing_app

mkdir not_a_zig_project
cd not_a_zig_project
expect_failure_contains "../zig-out/bin/zag run" "ZAG_E_NO_BUILD_ZIG" ../zig-out/bin/zag run

printf '%s\n' "smoke test passed"
