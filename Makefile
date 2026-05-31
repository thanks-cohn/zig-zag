.PHONY: build test smoke clean

build:
	zig build

test: smoke

smoke:
	tests/smoke.sh

clean:
	rm -rf zig-out .zig-cache smoke_app .smoke_app_output.txt
