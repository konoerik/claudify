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


### ADR-3: Installer script generated from blueprint, not fetched
**Date:** 2026-03-14
**Context:** Claude's WebFetch tool summarizes content rather than returning raw bytes, making per-file fetches unreliable. Generating N individual curl tool calls is also slow and noisy.
**Decision:** claudify.md embeds a shell script template. Claude parses the blueprint YAML, fills in the template, writes `.claudify-install.sh`, runs it, then deletes it. Only the blueprint YAML is fetched via curl; all file installs happen inside the generated script.
**Alternatives considered:** Fetching a static installer script from the repo (requires bash YAML parsing); per-file WebFetch calls (summarizes content); per-file curl tool calls (N round-trips, noisy).
**Consequences:** Future blueprints work automatically — the template handles any manifest. If new setup field types are added to blueprints, the template in claudify.md must be updated to cover them.


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
