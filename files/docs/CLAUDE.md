# CLAUDE.md

## Project Overview
<!-- One paragraph: what this project is, what it does, who it's for. -->

## Tech Stack
<!-- Language, framework, key dependencies, deployment target. -->

## Key Conventions
<!-- Coding style, naming rules, patterns to follow or avoid. -->

## Development Workflow
<!-- How to run, test, build. Commands the assistant will need. -->
```bash
# run:
# test:
# build:
# lint:
```

## Operating Rules

### Environment
- Use the project's declared toolchain and package manager — never system-level or globally installed tools
- A dependency change must land in the project's manifest (lockfile included); never install ad hoc

### Debugging
Work this sequence — do not improvise tooling:
1. **Reproduce** — smallest command that shows the failure before changing anything
2. **Read the full error output** — before forming a hypothesis
3. **Isolate** — narrow with existing tests and `git diff`/`git log`; bisect if the regression point is unknown
4. **Instrument** — the language's built-in logging/debugger only; remove instrumentation once fixed
5. **Never add a dependency to debug** — existing tools only
6. **Verify** — run the project's declared test command yourself and confirm a real passing exit code; a fix isn't done until the real command passes, not your read of the output

## Behavior Rules
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
