# zig.zg


A Zig-native application platform, built one real command at a time.

zig.zg is an early attempt to give Zig the application-layer path that made ecosystems like Node.js, ASP.NET, Rails, Laravel, and similar platforms practical for everyday software.

The idea is simple:

Zig already has the language.

zig.zg is building the path.

Node.js did not win only because JavaScript existed. It won because JavaScript became a path: create the project, run the project, install packages, build services, write CLIs, serve APIs, ship tools, and stay inside one familiar world.

ASP.NET did not win only because C# existed. It won because C# developers had a serious application platform: project structure, build commands, web services, configuration, diagnostics, deployment paths, and a coherent way to build large software.

Zig has many of the traits a foundational language should have: it is small, explicit, fast, cross-compilable, close to the machine, and resistant to unnecessary magic.

But a language is not enough.

Application developers need a path.

They need a first mile.

They need obvious commands.

They need repeatable structure.

They need failure messages that do not abandon them.

They need a way to create, check, build, run, inspect, diagnose, package, and eventually deploy real applications without leaving the Zig-native world.

zig.zg exists to build that missing layer.

Not by turning Zig into JavaScript.

Not by hiding the machine.

Not by pretending the repo is already Node.js, ASP.NET, Rails, Laravel, Phoenix, or anything else mature.

That would be fake.

The claim is narrower and more serious:

Zig has the qualities of a foundational language, but it needs a practical application layer.

zig.zg is building that layer one real command at a time.

The first spine is intentionally simple:

    zag new
    zag doctor
    zag check
    zag build
    zag run

That is not the whole platform.

That is the beginning of the platform.

A full-stack language does not become full-stack by slogan. It becomes full-stack when a developer can start with nothing, create something real, verify it, build it, run it, understand what broke, and keep moving.

The long-term goal is for Zig to become viable not only for systems programming, embedded work, kernels, tools, games, allocators, and low-level infrastructure, but also for web services, APIs, background workers, admin tools, local applications, desktop utilities, deployable services, and eventually full-stack products.

The bet behind zig.zg is this:

If Zig can compile the world, it should also be able to build the app.

A developer should not have to abandon Zig the moment they move above the systems layer.

A small team should be able to choose Zig not only for the core engine, but for the surrounding application.

A builder should be able to make the service, the worker, the CLI, the local tool, the deployable binary, and the operational surface in one inspectable language.

That does not mean pretending the ecosystem is already finished.

It means refusing to accept that Zig must remain trapped below the application layer forever.

zig.zg is the climb upward.

------------------------------
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

