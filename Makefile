ZIG := ./.tools/zig-x86_64-linux-0.14.1/zig

.PHONY: build test smoke clean doctor version help

build:
	$(ZIG) build

test: smoke

smoke:
	PATH="$(PWD)/.tools/zig-x86_64-linux-0.14.1:$$PATH" ./tests/smoke.sh

doctor: build
	./zig-out/bin/zag doctor

version: build
	./zig-out/bin/zag version

help: build
	./zig-out/bin/zag help

clean:
	rm -rf .zig-cache zig-out hello smoke_app
