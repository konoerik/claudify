# Architecture

## Quick Reference
<!-- Always read this section. Keep it under 20 lines.
     Stack, key constraints, and the most important patterns. -->

**Stack:** Bash, Markdown, YAML — no runtime dependencies
**Entry points:** `blueprints/*.yml` (applied by Claude), `audit.sh` (shell, standalone)
**Key constraints:** Hooks must be idempotent and handle missing files without hard exits; files must stay generic
**Patterns:** Blueprint declares `src` (in `files/`) → `dest` (in target project); Claude executes the install


## Decisions (ADRs)
<!-- Append new ADRs with /decide -->

### ADR-1: CONTEXT.md as the only always-loaded file
**Date:** 2026-03-14
**Context:** Loading all project docs every session wastes tokens, especially as files grow with completed work.
**Decision:** Only CONTEXT.md is auto-loaded. All other files (PLAN.md, ARCHITECTURE.md, ROADMAP.md) are loaded conditionally based on task relevance, as specified in CLAUDE.md.
**Alternatives considered:** Loading everything always; using a single merged doc.
**Consequences:** CONTEXT.md must be kept accurate and short. The stop hook is responsible for keeping it fresh.

### ADR-2: PLAN.md sections over separate files
**Date:** 2026-03-14
**Context:** Projects were accumulating BACKLOG.md, TASKS.md, TODO.md etc. with no consistent convention.
**Decision:** Single PLAN.md with ## Active / ## Backlog / ## Done sections. Claude reads only ## Active by default.
**Alternatives considered:** Separate files per status; native Tasks tool only.
**Consequences:** guard-naming.sh hook blocks creation of disallowed filenames. ## Done is ephemeral — archived by stop hook.


## Detail
<!-- Directory layout, extension points, etc. Load on demand. -->

```
claudify/
├── docs/                # This repo's CONTEXT, PLAN, ARCHITECTURE, ROADMAP
├── blueprints/          # YAML manifests — declare what to install and where
├── files/
│   ├── docs/           # Document templates (CLAUDE.md, CONTEXT.md, etc.)
│   ├── hooks/          # Hook scripts (flat; dest path sets the event type)
│   └── commands/       # Slash command prompt files
└── audit.sh            # Standalone shell tool — checks a project for drift
```
