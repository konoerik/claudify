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
Reproduce the failure with the smallest command that shows it and read the full error output before changing anything. Debug with what the project already has — the language's built-in logging or debugger, existing tests, `git diff`/`git log`, and bisect when the regression point is unknown — and never add a dependency to debug. Remove instrumentation once fixed. A fix is done when you have run the project's declared test command yourself and it exits 0, not when the output looks right.

## Behavior Rules
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
