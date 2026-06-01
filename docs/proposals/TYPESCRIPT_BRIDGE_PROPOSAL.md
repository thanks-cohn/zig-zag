# TypeScript Bridge Proposal

## Purpose

`zig.zg` should eventually provide a disciplined bridge from TypeScript application projects into Zig-native application projects.

This is not a claim that `zig.zg` currently compiles TypeScript.

This is not a claim that TypeScript, JavaScript, Node.js, npm, browser APIs, or framework behavior can be replaced casually.

This is a proposal for a serious migration path.

The goal is to let developers bring existing application structure with them instead of forcing a full rewrite on day one.

A serious platform does not win by telling everyone to throw away their world.

It wins by giving them a bridge.

## Core analogy

Zig can compile C and consume C libraries.

That matters because C is where decades of systems code already live.

The bridge does not erase C overnight. It gives Zig a way to enter existing reality.

`zig.zg` should eventually do something similar for application development.

TypeScript is where a huge amount of modern application structure already lives.

A future `zag` should be able to inspect, explain, migrate, and selectively translate TypeScript projects into Zig-native `zig.zg` projects.

The analogy is not perfect.

C and TypeScript are very different languages with very different runtime expectations.

But the strategic idea is similar:

```text
Zig welcomes existing C systems code.

zig.zg should eventually welcome existing TypeScript application code.
```

## Non-claims

This proposal does not claim:

```text
zig.zg currently compiles TypeScript
zig.zg is currently better than Node.js
zig.zg can currently replace npm
zig.zg can currently reproduce JavaScript runtime semantics
zig.zg can currently translate arbitrary frontend applications
zig.zg can currently translate arbitrary backend applications
```

Those would be paper-tiger claims.

The real claim is narrower and stronger:

```text
zig.zg should be designed from the beginning to support an honest, inspectable, testable migration bridge from TypeScript application projects into Zig-native application projects.
```

## Why this matters

Many new platforms fail because they ask developers to start from nothing.

But real developers already have:

```text
package.json
tsconfig.json
src directories
routes
controllers
models
schemas
scripts
tests
environment variables
deployment assumptions
framework conventions
dependencies
devDependencies
business logic
```

A migration bridge respects that.

It says:

```text
Bring your project.
We will inspect it.
We will explain it.
We will show what can move.
We will show what cannot move yet.
We will generate what is safe.
We will fail with breadcrumbs when we cannot continue.
```

That is a serious adoption strategy.

## Strategic position

The goal is not to beat Node.js by imitating Node.js.

The goal is to build a stronger application platform that can receive projects from the Node.js and TypeScript world without inheriting their worst failure modes.

`zig.zg` should compete on:

```text
diagnosability
compile-time confidence
native performance
single-toolchain clarity
explicit project structure
breadcrumb failures
smoke-tested generation
honest migration reports
```

Node.js is powerful because it has ecosystem gravity.

`zig.zg` cannot out-ecosystem Node.js at the beginning.

But it can be founded on stricter rules:

```text
No paper tiger.
No fake framework.
No vague failures.
No silent scaffolding.
No unsupported migration hidden behind marketing.
```

## The migration ladder

The TypeScript bridge should be built in phases.

Each phase must be useful on its own.

Each phase must be smoke-tested.

Each phase must obey `docs/FAILURE_CONTRACT.md`.

### Phase 1: inspect

Command:

```text
zag inspect-ts <path>
```

Purpose:

Read a TypeScript or Node-style project without modifying it.

Minimum detection:

```text
package.json
tsconfig.json
src/
scripts
dependencies
devDependencies
probable entrypoint
probable framework, only when obvious
test command, when obvious
build command, when obvious
```

Example output:

```text
TypeScript project inspection

root: ./my_app
package.json: found
tsconfig.json: found
src: found

scripts:
  build: tsc
  test: vitest
  dev: tsx src/index.ts

dependencies:
  express
  zod

devDependencies:
  typescript
  vitest
  tsx

probable entrypoint: src/index.ts
probable framework: express
```

Rules:

```text
Do not modify files.
Do not translate code.
Do not guess aggressively.
Distinguish known facts from guesses.
Fail with breadcrumbs.
```

### Phase 2: explain

Command:

```text
zag explain-ts <path>
```

Purpose:

Generate a migration report.

The report should explain:

```text
what kind of project this appears to be
what scripts exist
what runtime assumptions exist
what dependencies are present
what dependencies block migration
what files look structurally portable
what files likely require manual work
what parts are unknown
```

Example sections:

```text
Project kind
Scripts
Entrypoints
Routes
Data models
Dependencies
Migration blockers
Potentially portable files
Unsupported patterns
Next steps
```

This phase still does not translate arbitrary code.

Its value is clarity.

### Phase 3: extract structure

Command possibility:

```text
zag extract-ts <path>
```

Purpose:

Extract application structure into an intermediate report.

Possible extracted structures:

```text
route declarations
config constants
environment variable names
data model names
validation schema names
command scripts
test/build commands
static asset paths
```

The output should be inspectable and deterministic.

At this phase, the bridge is learning the shape of the project.

It is not pretending to understand all business logic.

### Phase 4: generate Zig-native skeleton

Command possibility:

```text
zag new-from-ts <source_path> <target_name>
```

Purpose:

Create a compiling Zig-native `zig.zg` project based on the inspected TypeScript project structure.

The generated project must compile.

If route names or data model names can be extracted safely, they may become placeholder-free Zig structures only if they are real, compiling, and connected to the generated app.

Unsupported TypeScript logic must be reported, not silently ignored.

Required output files may include:

```text
src/main.zig
build.zig
README.md
MIGRATION_REPORT.md
.zigzg/source-report.txt
```

Rules:

```text
Generated projects must compile.
Generated reports must be honest.
Unsupported parts must be listed.
No fake translated code.
No dead files.
No placeholder APIs.
```

### Phase 5: translate safe TypeScript structure

Translate only constrained, testable subsets.

Early candidates:

```text
interfaces
type aliases
simple enums
plain object config
route tables
constant strings/numbers/booleans
simple data model declarations
simple validation schema shapes
```

Example TypeScript:

```text
interface User {
  id: string;
  name: string;
  age: number;
}
```

Potential Zig output:

```text
pub const User = struct {
    id: []const u8,
    name: []const u8,
    age: f64,
};
```

The translator must be honest about lossy mappings.

For example:

```text
TypeScript number maps to Zig f64 by default in this mode.
```

or:

```text
TypeScript optional field detected; generated Zig type requires review.
```

Every supported construct must have tests.

Every unsupported construct must fail or be reported with breadcrumbs.

### Phase 6: translate limited application logic

Only after structure translation is real should the bridge attempt limited logic translation.

Possible supported subset:

```text
pure functions
simple conditionals
simple loops
basic string/number/boolean operations
plain object construction
basic array iteration
```

Unsupported early:

```text
closures with complex capture
dynamic property access
prototype behavior
eval
decorators
arbitrary async semantics
DOM APIs
Node stream internals
complex framework magic
```

The rule is simple:

```text
Translate only what can be proven.
Report everything else.
```

### Phase 7: framework-specific bridges

Possible future targets:

```text
Express route extraction
Fastify route extraction
Hono route extraction
NestJS structure reports
Next.js project inspection
Vite project inspection
React frontend/backend separation reports
```

These should be separate bridge modules, not one giant magic parser.

Framework support should start as inspection and explanation before translation.

## Failure contract

The TypeScript bridge must follow `docs/FAILURE_CONTRACT.md`.

Example missing package file:

```text
error: ZAG_E_TS_PACKAGE_JSON_MISSING
where: inspect-ts/project-root
what: expected package.json in TypeScript project root
path: ./package.json
when: before reading TypeScript project metadata
why: inspect-ts must start from a Node or TypeScript project directory
next: run `pwd`; run `ls`; pass a directory containing package.json
```

Example malformed JSON:

```text
error: ZAG_E_TS_PACKAGE_JSON_INVALID
where: inspect-ts/package-json
what: could not parse package.json
path: ./package.json
when: while reading TypeScript project metadata
why: package.json is not valid JSON
next: run `cat package.json`; validate the file with your editor or package manager
```

Example unsupported translation:

```text
error: ZAG_E_TS_UNSUPPORTED_CONSTRUCT
where: translate-ts/function-body
what: unsupported TypeScript construct encountered
path: src/server.ts
when: while translating function body
why: dynamic property access is not supported by this translation phase
next: keep this file manual for now; run `zag explain-ts .` for migration report
```

## Smoke test doctrine

Every bridge feature must include smoke tests.

For `zag inspect-ts`, smoke should create a tiny TypeScript fixture:

```text
fixtures/ts/basic/package.json
fixtures/ts/basic/tsconfig.json
fixtures/ts/basic/src/index.ts
```

Smoke should prove:

```text
zag inspect-ts fixtures/ts/basic
```

prints known fields:

```text
package.json: found
tsconfig.json: found
src: found
```

Smoke should also prove a failure path:

```text
zag inspect-ts fixtures/ts/not_a_ts_project
```

must fail with:

```text
ZAG_E_TS_PACKAGE_JSON_MISSING
```

If smoke does not prove the happy path and an important failure path, the feature is not done.

## Initial error codes

Future implementation should consider these stable codes:

```text
ZAG_E_TS_PACKAGE_JSON_MISSING
ZAG_E_TS_PACKAGE_JSON_INVALID
ZAG_E_TS_TSCONFIG_MISSING
ZAG_E_TS_TSCONFIG_INVALID
ZAG_E_TS_SRC_MISSING
ZAG_E_TS_ENTRYPOINT_UNKNOWN
ZAG_E_TS_UNSUPPORTED_CONSTRUCT
ZAG_E_TS_TRANSLATION_LOSSY
ZAG_E_TS_DEPENDENCY_UNSUPPORTED
ZAG_E_TS_FRAMEWORK_UNKNOWN
```

Do not add all codes before they are used.

Codes should appear when real features need them.

## Initial implementation target

The first real implementation should be:

```text
zag inspect-ts <path>
```

Minimum useful behavior:

```text
read package.json
read tsconfig.json if present
check src directory
print scripts
print dependencies
print devDependencies
guess entrypoint only from obvious fields
guess framework only from obvious dependency names
fail with breadcrumbs when package.json is missing or invalid
```

No translation.

No file modification.

No fake migration.

No dependency installation.

No external parser.

No npm invocation.

Use only what Zig 0.14.1 and the repository can support.

## What would make this big

If `zig.zg` eventually did this well, it would matter because it would give TypeScript projects a migration ramp into a native, compiled application platform.

The pitch would not be:

```text
Throw away Node.js.
```

The pitch would be:

```text
Bring your TypeScript project.
zag will inspect it.
zag will explain it.
zag will identify what can move.
zag will generate a Zig-native skeleton.
zag will translate the safe parts.
zag will report the hard parts.
zag will fail with breadcrumbs instead of mystery.
```

That is a credible bridge.

A working bridge from TypeScript application structure into Zig-native application structure would be a serious platform-level wedge.

## Relationship to Node.js

Node.js is mature, widely deployed, and backed by a massive ecosystem.

This proposal does not dismiss that.

The opportunity is different.

Many developers like TypeScript but dislike the fragility of modern JavaScript tooling.

A successful `zig.zg` TypeScript bridge could offer a path from:

```text
dynamic ecosystem complexity
```

toward:

```text
compiled structure
native performance
explicit diagnostics
smoke-tested project generation
clear migration reports
```

The goal is not to insult the old world.

The goal is to build a better road out of it.

## Long-term standard

The TypeScript bridge should obey this standard:

```text
inspect before translating
explain before modifying
compile before claiming
smoke before merging
breadcrumbs before cleverness
no paper tiger
```

If a feature cannot meet that standard, it should not land.

## Codex instruction for future implementation

Every Codex pass touching the TypeScript bridge should start with:

```text
Read docs/FAILURE_CONTRACT.md.
Read docs/TYPESCRIPT_BRIDGE_PROPOSAL.md.

Pinned Zig version: 0.14.1.
Do not migrate to Zig 0.16.
Do not use APIs from newer Zig versions.
Use the repo Makefile.

Acceptance tests:
make build
make smoke

No placeholder code.
No fake APIs.
No paper-tiger architecture.
Every added file must compile, run, test, or directly document a real contract.
Plain ASCII output only.
```

The first implementation pass should be small:

```text
Implement zag inspect-ts <path> for basic package.json and tsconfig.json inspection.
Do not translate code.
Do not modify files.
Add fixtures.
Add smoke tests.
Add breadcrumb failures.
```

## Final principle

A platform that wants to replace mature ecosystems must first learn to receive them.

`zig.zg` should not begin by demanding loyalty.

It should begin by understanding the projects developers already have.
