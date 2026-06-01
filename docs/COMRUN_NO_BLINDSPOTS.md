# The No-Blindspots Policy

## ComRun Recording Standard

### Purpose

The purpose of ComRun is not merely to record builds, logs, dependencies, or execution results.

Its purpose is to eliminate unknowns.

Every successful execution represents a moment in which a machine, a toolchain, a configuration, and a collection of dependencies cooperated to produce a result. Historically, much of this information has been discarded, scattered across multiple systems, or never recorded at all.

The consequence is familiar:

> It worked yesterday.
>
> It worked on another machine.
>
> It worked before the upgrade.
>
> Nobody knows why.

The No-Blindspots Policy exists to make such situations increasingly rare.

---

## Principle

A successful execution should never leave behind less information than was available at the moment of success.

If a machine knew something when it succeeded, that information should be considered valuable.

If that information contributed to the result, it should be eligible for preservation.

ComRun exists to preserve that knowledge.

---

## Definition of a Blindspot

A blindspot is any missing piece of information that materially impairs the ability to:

- Understand a result
- Reproduce a result
- Compare results
- Diagnose a failure
- Explain a change
- Reconstruct an environment

Blindspots create uncertainty.

Uncertainty increases maintenance cost.

Maintenance cost limits longevity.

The No-Blindspots Policy treats preventable uncertainty as a technical debt to be reduced wherever practical.

---

## Recording Philosophy

ComRun follows a simple rule:

Record reality, not assumptions.

A system should not merely record what it expected to happen.

It should record what actually happened.

Where practical, observed facts should be preferred over manually maintained descriptions.

Observed environments are more reliable than remembered environments.

Observed dependencies are more reliable than assumed dependencies.

Observed execution details are more reliable than reconstructed explanations.

---

## Scope

The No-Blindspots Policy encourages the preservation of information relating to:

### Machine Identity

- Operating system
- Distribution
- Kernel version
- Architecture
- CPU information
- Memory information
- Filesystem information
- Storage information
- Host information

### Toolchain Identity

- Compiler version
- Build configuration
- Optimization settings
- Target platform
- Package sources
- Dependency resolution information

### Execution Identity

- Commands executed
- Arguments supplied
- Working directory
- Exit status
- Runtime duration
- Resource consumption

### Dependency Identity

- Direct dependencies
- Transitive dependencies
- Resolved versions
- Package hashes
- Runtime libraries

### Artifact Identity

- Executables
- Generated files
- Checksums
- Build artifacts
- Reports

---

## Preservation Over Convenience

Storage is inexpensive.

Lost information is often expensive.

When a choice exists between preserving useful execution knowledge and discarding it, ComRun should favor preservation unless a compelling reason exists to do otherwise.

Future debugging sessions frequently depend on details that appeared unimportant at the time of execution.

The No-Blindspots Policy acknowledges this reality.

---

## Historical Accountability

Every successful execution becomes part of a project's operational history.

ComRuns are intended to serve as durable records of what actually occurred, not simplified summaries of what was intended to occur.

A project should accumulate knowledge over time rather than repeatedly rediscover it.

The objective is not merely reproducibility.

The objective is institutional memory.

---

## Standard

ComRun implementations should seek to reduce blindspots whenever practical and technically feasible.

New sources of meaningful execution information should be considered candidates for recording.

The default question should not be:

> Why record this?

The default question should be:

> What capability is lost if this information disappears?

---

## Closing Statement

Software systems are often expected to remember less than the people who operate them.

ComRun rejects this assumption.

A machine that participated in a successful execution possesses knowledge that may be valuable in the future.

The No-Blindspots Policy establishes a simple expectation:

Preserve reality.

Reduce uncertainty.

Leave behind enough evidence that success can be understood, explained, and reproduced long after the original moment has passed.
