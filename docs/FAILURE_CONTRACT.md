# zag Failure Contract

`zag` must not fail silently, vaguely, or lazily.

Failure is part of the user interface.

A serious tool does not merely say that something broke. It shows the user where to put their hands next.

This document defines the public failure contract for `zag`.

The goal is not noisy logging. The goal is useful diagnostic breadcrumbs.

Success should stay short.

Failure should teach.

## Core idea

Every important failure should answer six questions:

```text
error: stable error code
where: command/module/stage that failed
what: operation that failed
path: file or directory involved, when relevant
when: phase or step where the failure happened
why: likely cause, when known
next: concrete command or file to inspect
```

This is the `error/where/what/path/when/why/next` schema.

The schema exists so that a user, script, maintainer, bug report, or future AI agent can usually understand the failure without guessing.

## Example

```text
error: ZAG_E_NO_BUILD_ZIG
where: zag run/current-project
what: expected build.zig in current directory
path: ./build.zig
when: before running zig build run
why: zag run must be used inside a Zig project
next: run `pwd`; run `ls`; or create a project with `zag new my_app`
```

This is better than:

```text
failed
```

or:

```text
build.zig missing
```

because it explains the failure in a way that is searchable, testable, and actionable.

## Field meanings

### error

A stable, machine-searchable error code.

Examples:

```text
ZAG_E_UNKNOWN_COMMAND
ZAG_E_BAD_PROJECT_NAME
ZAG_E_PROJECT_EXISTS
ZAG_E_TEMPLATE_MISSING
ZAG_E_ZIG_NOT_FOUND
ZAG_E_NOT_WRITABLE
ZAG_E_NO_BUILD_ZIG
ZAG_E_CHILD_FAILED
ZAG_E_IO
```

Error codes should be stable enough for smoke tests, documentation, bug reports, and scripts.

Do not rename error codes casually.

### where

The command, module, subsystem, or stage where the failure occurred.

Good examples:

```text
zag run/current-project
zag new/project-name
doctor/templates/basic
doctor/toolchain
process/child
```

Bad examples:

```text
somewhere
unknown
main
```

`where` should point toward the responsible area of the system.

### what

The specific operation that failed.

Good examples:

```text
expected build.zig in current directory
could not create project directory
unknown command requested
template source file is missing
child command failed
```

`what` should describe the direct failure, not the whole philosophy of the program.

### path

The file or directory involved, when relevant.

Examples:

```text
./build.zig
templates/basic/src/main.zig
smoke_app
/home/user/project
```

If no path is relevant, omit this field.

Do not invent a path.

### when

The phase or step where the failure occurred.

For CLI tools, `when` usually means the operational phase, not a wall-clock timestamp.

Good examples:

```text
before running zig build run
while copying template files
while validating project name
while checking Zig toolchain
after child process exited
```

Timestamps may be useful later for persistent logs, but normal CLI errors should prefer phase over clock time.

### why

The likely cause, when known.

Good examples:

```text
zag run must be used inside a Zig project
project name cannot contain path separators
template directory is incomplete or repo checkout is damaged
Zig 0.14.1 is not first in PATH
```

If the cause is not known, say so plainly or omit the field.

Do not lie.

Do not pretend certainty when the program only has a guess.

### next

A concrete inspection or recovery step.

Good examples:

```text
run `pwd`; run `ls`
run `git status`; inspect `templates/basic/src/main.zig`
choose a simple project name like `my_app`
run `make build`; run `make smoke`
```

Bad examples:

```text
try again
fix the issue
contact support
```

`next` should reduce helplessness.

## Success output

Success should be short and calm.

Good:

```text
created project: hello
next steps:
cd hello
zig build
zig build run
```

Good:

```text
[PASS] templates/basic found
```

Avoid turning normal success paths into debug spam.

The failure contract is not an excuse to make every command loud.

## Failure output

Failure output should be rich enough to diagnose the issue.

A command does not need every field for every failure, but serious failures should usually include:

```text
error
where
what
why
next
```

Include `path` when a file or directory is involved.

Include `when` when the phase matters.

## Smoke test doctrine

Smoke tests must prove reality.

Every feature should update smoke tests when practical.

Smoke tests should include:

1. Happy path proof.
2. At least one important failure path.
3. Error code checks for breadcrumb failures.
4. Output checks for important user-visible behavior.

For example, if `zag run` is implemented, smoke should prove:

```text
zag new smoke_app
cd smoke_app
../zig-out/bin/zag run
```

prints:

```text
hello from zig.zg
```

And smoke should also prove that running `zag run` outside a Zig project fails with:

```text
ZAG_E_NO_BUILD_ZIG
```

If smoke does not prove the feature, the feature is not done.

## No paper tiger rule

Do not add fake architecture.

Do not add placeholder code.

Do not add unused abstractions.

Do not add files that exist only to make the repository look bigger.

Every added file must compile, run, test, document a real contract, or be directly used by something that compiles, runs, or tests.

A small working system is better than a grand imaginary platform.

## Product standard

`zag` is intended to become the foundation of `zig.zg`, a serious application platform.

The long-term ambition is to compete with major developer ecosystems.

That ambition does not justify fake scaffolding.

It raises the standard for every small step.

Each pass should make the system more:

```text
real
testable
diagnosable
dependable
inspectable
boring in success
useful in failure
```

## Codex requirements

Every Codex pass should respect this contract.

Standing rules:

```text
Pinned Zig version: 0.14.1.
Do not migrate to Zig 0.16.
Do not use APIs from newer Zig versions.
Do not assume system `zig` is correct.
Use the repo Makefile.

Acceptance tests:
make build
make smoke

No placeholder code.
No fake APIs.
No paper-tiger architecture.
Plain ASCII output only.
```

When implementing or changing a command, Codex should ask:

```text
What happens when this fails?
Does the user know where?
Does the user know what?
Does the user know why, if knowable?
Does the user know what to inspect next?
Does smoke prove the important path?
```

## The standard

The standard is simple:

```text
Success stays quiet.
Failure points.
Smoke proves.
