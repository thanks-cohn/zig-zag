# zig.zg

The Full-Stack Application Platform for Zig

> One language. One toolchain. One deployment artifact.

zig.zg exists to bring first-class full-stack application development to Zig without sacrificing the things that make Zig special: simplicity, performance, portability, inspectability, and explicit control.

The goal is not to turn Zig into JavaScript.

The goal is to make it possible to build complete products in Zig.

Web applications.
APIs.
Desktop software.
Background workers.
WebAssembly applications.
Local-first tools.
Entire businesses.

All from a unified platform built around Zig's philosophy rather than against it.

-------------------------------------------------------------------------------
WHY?
-------------------------------------------------------------------------------

Modern application development has become fragmented.

A typical application might require:

- JavaScript for the frontend
- TypeScript for tooling
- Node.js for backend services
- Docker for deployment
- Multiple package managers
- Several build systems
- Large dependency trees
- Gigabytes of runtime overhead

Meanwhile Zig already provides:

- Native compilation
- Cross compilation
- Memory control
- Small binaries
- Fast startup
- Excellent tooling

The missing piece is the application layer.

zig.zg aims to provide that layer.

-------------------------------------------------------------------------------
WHY "zag"?
-------------------------------------------------------------------------------

zig.zg intentionally separates itself from Zig's existing command structure.

Instead of:

    zig dev
    zig deploy
    zig web

which could collide with present or future Zig commands, zig.zg introduces:

    zag

Examples:

    zag new blog
    zag dev
    zag build
    zag test
    zag deploy
    zag doctor
    zag wasm

This creates a clean separation:

    Zig      = Language
    zig.zg   = Platform
    zag      = Toolchain

Every Zig deserves a Zag.

-------------------------------------------------------------------------------
VISION
-------------------------------------------------------------------------------

The ideal zig.zg application looks like:

    myapp/
    ├── pages/
    ├── api/
    ├── components/
    ├── assets/
    ├── jobs/
    ├── migrations/
    ├── tests/
    ├── zag.toml
    └── src/

Development:

    zag dev

Testing:

    zag test

Production:

    zag build

Deployment:

    zag deploy

Result:

    myapp

One executable.

No runtime required.

No node_modules.

No dependency forests.

No mystery.

-------------------------------------------------------------------------------
DESIGN PRINCIPLES
-------------------------------------------------------------------------------

* Native First
* Single Language
* Single Artifact
* Explicit Over Magic
* Local First
* Inspectable
* Portable
* WebAssembly Friendly

-------------------------------------------------------------------------------
REPOSITORY OUTLINE
-------------------------------------------------------------------------------

    zig.zg/
    ├── cli/
    │   └── zag
    ├── runtime/
    ├── router/
    ├── http/
    ├── websocket/
    ├── templates/
    ├── ui/
    ├── wasm/
    ├── jobs/
    ├── db/
    ├── auth/
    ├── cache/
    ├── deploy/
    ├── examples/
    ├── benchmarks/
    ├── docs/
    └── tests/

-------------------------------------------------------------------------------
BENCHMARK TARGETS
-------------------------------------------------------------------------------

These are aspirational project goals, not current measurements.

Hello World API Throughput

    Express.js        ~70,000 req/sec
    Fastify          ~120,000 req/sec
    ASP.NET Core     ~500,000 req/sec
    Go Fiber         ~450,000 req/sec
    zig.zg Goal      ~750,000+ req/sec

Startup Time

    Node.js          20-100 ms
    ASP.NET          100-300 ms
    Go               1-10 ms
    zig.zg Goal      <1 ms

Idle Memory

    Node.js          30-80 MB
    ASP.NET          40-120 MB
    Go               5-20 MB
    zig.zg Goal      <5 MB

-------------------------------------------------------------------------------
ROADMAP
-------------------------------------------------------------------------------

[ ] Milestone 0 - Foundation

    - zag CLI
    - configuration system
    - logging
    - HTTP server
    - project generator

[ ] Milestone 1 - Backend

    - routing
    - middleware
    - JSON
    - static files
    - testing support

[ ] Milestone 2 - Frontend

    - components
    - templates
    - asset pipeline
    - SPA support
    - SSR support

[ ] Milestone 3 - Full Stack

    - authentication
    - sessions
    - database integration
    - background jobs
    - deployment tooling

[ ] Milestone 4 - WebAssembly

    - browser target
    - WASI support
    - universal rendering
    - portable applications

[ ] Milestone 5 - Ecosystem

    - package registry
    - plugin system
    - project templates
    - production deployment stack

[ ] Milestone 6 - Beyond Web

    - desktop support
    - embedded support
    - mobile support
    - alternative operating system targets

-------------------------------------------------------------------------------
LONG-TERM GOAL
-------------------------------------------------------------------------------

The goal of zig.zg is not merely to become another web framework.

The goal is to become for Zig what:

- Node.js became for JavaScript
- ASP.NET became for C#
- Rails became for Ruby
- Laravel became for PHP

A place where application development feels natural.

A place where people can build entire products without abandoning the language they love.

A place where Zig can express its full potential.

If Zig is the engine, zig.zg aims to be the road.
