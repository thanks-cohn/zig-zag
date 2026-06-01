# zig.zg

The full-stack application platform for Zig.

CLI name: `zag`.

zig.zg exists to become a practical application platform for Zig across backend,
frontend, WebAssembly, desktop, mobile, and operating-system runtimes. The first
milestone is deliberately small: establish a CLI that developers can trust.

## Current Status

The first real CLI foundation works now:

- zag builds
- zag version works
- zag help works
- zag doctor performs real checks
- zag new creates a compilable Zig project
- zag run executes generated apps from inside a project
- smoke test proves generated app builds and runs

Not implemented yet:

- HTTP runtime
- routing
- frontend rendering
- WebAssembly targets
- desktop or mobile runtimes
- deployment tooling


## Quick Start

Requirements:

- Zig installed and available on `PATH`
- A writable working directory

Build the CLI with the pinned toolchain from the repo Makefile:

```sh
make build
```

Check the local environment:

```sh
./zig-out/bin/zag doctor
```

Create a new Zig app:

```sh
./zig-out/bin/zag new my_app
cd my_app
zig build
../zig-out/bin/zag run
```

Run the smoke test with the repo Makefile:

```sh
make smoke
```

## Commands

```sh
zag version
zag help
zag doctor
zag new <name>
zag run
```

### `zag version`

Prints:

```text
zag 0.0.1
zig.zg application platform bootstrap
```

### `zag help`

Prints usage text and lists the supported commands.

### `zag doctor`

Runs real checks for the minimum working environment:

- the current directory is writable
- `zig version` can run
- `templates/basic` exists
- `templates/basic/build.zig` exists
- `templates/basic/src/main.zig` exists

Failure messages use breadcrumb errors where they have been standardized.

## Breadcrumb errors

zag failures are being standardized so users can search for stable error codes
and quickly find the broken step. Standardized failures include:

- an error code
- where the failure happened
- what operation failed
- the path involved, when relevant
- why it probably failed, when known
- the next command or file to inspect

Example shape:

```text
error: ZAG_E_NO_BUILD_ZIG
where: run/project-root
what: build.zig was not found in the current directory
path: build.zig
why: zag run must be used inside a Zig project
next: run `pwd`; inspect the current directory for `build.zig`
```

Not every possible failure is perfect yet, but command failures covered by the
current smoke test now use this breadcrumb shape.

### `zag new <name>`

Creates a compilable Zig project using the `templates/basic` template. The
command refuses invalid project names and refuses to overwrite an existing file
or directory.

Generated projects contain:

```text
<name>/
├── build.zig
└── src/
    └── main.zig
```

Generated projects support:

```sh
zig build
zig build run
```

From inside a generated project, zag can run the app too:

```sh
../zig-out/bin/zag run
```

### `zag run`

Runs `zig build run` in the current directory. The command must be used from inside a Zig project containing `build.zig`, and it forwards the app output directly to the terminal.

The generated app prints:

```text
hello from zig.zg
```

## Repository Structure

```text
zig-zag/
├── build.zig
├── Makefile
├── README.md
├── src/
│   ├── main.zig
│   ├── cli.zig
│   ├── errors.zig
│   ├── log.zig
│   ├── project.zig
│   ├── doctor.zig
│   └── paths.zig
├── templates/
│   └── basic/
│       ├── build.zig
│       └── src/
│           └── main.zig
└── tests/
    └── smoke.sh
```

