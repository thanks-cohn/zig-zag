# zig.zg

The full-stack application platform for Zig.

CLI name: `zag`.

zig.zg exists to become a practical application platform for Zig across backend,
frontend, WebAssembly, desktop, mobile, and operating-system runtimes. The first
milestone is deliberately small: establish a CLI that developers can trust.

## Current Status

This repository currently contains the first working foundation:

- `zag` is a Zig CLI built by the repository root `build.zig`.
- `zag version` prints the CLI version.
- `zag help` prints supported commands.
- `zag doctor` checks:
  - Zig can be executed with `zig version`.
  - The current directory is writable.
  - The templates directory can be found.
  - The basic project template can be found.
- `zag new <name>` creates a real Zig project from `templates/basic`.
- A generated project contains:

  ```text
  <name>/
  ├── build.zig
  └── src/
      └── main.zig
  ```

- A generated project is expected to support:

  ```sh
  zig build
  zig build run
  ```

- `tests/smoke.sh` builds `zag`, runs the basic commands, generates an app, and
  builds and runs the generated app.

Not implemented yet:

- HTTP runtime
- routing
- frontend rendering
- WebAssembly targets
- desktop or mobile runtimes
- deployment tooling

Those features should grow from this foundation rather than from placeholders.

## Quick Start

Requirements:

- Zig installed and available on `PATH`
- A writable working directory

Build the CLI:

```sh
zig build
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
zig build run
```

Run the smoke test:

```sh
./tests/smoke.sh
```

## Commands

```sh
zag version
zag help
zag new <name>
zag doctor
```

### `zag version`

Prints the current `zag` version.

### `zag help`

Prints usage and supported commands.

### `zag new <name>`

Creates a compilable Zig project using the `templates/basic` template. The
command refuses to overwrite an existing directory and accepts only a single
project directory name containing letters, numbers, `-`, or `_`.

### `zag doctor`

Checks the minimum environment needed for the first milestone. Failure messages
explain what failed, why it likely failed, and which command or file to inspect
next.

## Repository Structure

```text
zig-zag/
├── build.zig
├── README.md
├── src/
│   ├── main.zig
│   ├── cli.zig
│   ├── log.zig
│   ├── fs.zig
│   └── project.zig
├── templates/
│   └── basic/
│       ├── build.zig
│       └── src/
│           └── main.zig
└── tests/
    └── smoke.sh
```

## Philosophy

This is not a toy and not a theatrical demo. The project should prefer small,
real, compiling foundations over invented APIs. Each milestone should increase
trust: clear commands, understandable failures, real generated code, and no fake
framework surface area.

The first win is not routing, frontend rendering, or WebAssembly. The first win
is that a developer can clone the repository, build `zag`, create a Zig app,
build it, run it, and understand what to inspect if something fails.
