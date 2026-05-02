# Architecture

## Quick Reference
<!-- Always read this section. Keep it under 20 lines.
     Stack, key constraints, and the most important patterns. -->

**Stack:** Bash, Markdown, YAML — no runtime dependencies
**Entry points:** `blueprints/*.yml` (applied by Claude via `/claudify`)
**Key constraints:** Hooks must be idempotent and handle missing files without hard exits; files must stay generic
**Patterns:** Blueprint declares `src` (in `files/`) → `dest` (in target project); Claude executes the install


## Decisions (ADRs)
<!-- Append new ADRs with /decide -->

### ADR-6: Keep create→run→delete script pattern; fix WSL2 CRLF via strip step
**Date:** 2026-04-03
**Context:** WSL2 users hit CRLF line ending failures when Claude Code's Write tool produced CRLF scripts. Alternative fix was to use `bash -s` heredocs to avoid writing to disk entirely, which would eliminate the CRLF problem.
**Decision:** Keep the create→run→delete pattern and add a `sed -i 's/\r//'` strip step before execution. Also added `.gitattributes` enforcing LF for all source files in the repo.
**Alternatives considered:** `bash -s << 'EOF'` heredoc approach — avoids temp files and CRLF entirely, but creates asymmetry if native Windows (PowerShell) support is ever added, since PowerShell has no heredoc equivalent. The file-based pattern is symmetric: generate a script, run it, delete it — regardless of platform.
**Consequences:** WSL2 is now supported when project files live on the Linux filesystem. The create→run→delete pattern is preserved and extensible to a future PowerShell path. The CRLF strip is a no-op on macOS and Linux.

**2026-05-02 update — parallel downloads + failure handling:** File fetches in the generated script now run as background subshells (`( ... ) & _pids+=($!)`), with `wait "$_pid"` per PID to detect individual failures. An `_ok` flag + `EXIT` trap surfaces incomplete runs. The invocation changed from `&& rm` to `; _s=$?; rm -f ...; exit $_s` so the temp script is always deleted regardless of outcome.

### ADR-5: Kit-owned rules split into `.claude/claudify.md`; `init`/`update` subcommands
**Date:** 2026-03-22
**Context:** claudify never overwrites existing files, so kit rule changes (behavior rules, context loading policy) couldn't reach projects after initial install. `CLAUDE.md` mixed user content with kit-managed sections, making selective updates impossible.
**Decision:** Split `CLAUDE.md` into two files: `CLAUDE.md` (user-owned — project content only) and `.claude/claudify.md` (kit-owned — context loading + workflow behavior rules). Rename the command to `init` and add an `update` subcommand that re-fetches only kit-managed files (hooks, commands, `.claude/claudify.md`), always overwriting. At init time, write `.claude/claudify` containing `blueprint: {name}` so `update` knows what to fetch without asking.
**Alternatives considered:** Section-level merging of `CLAUDE.md` (complex, fragile); prompting for blueprint name on every update (inconvenient); documenting manual copy-paste of new rules (not scalable).
**Consequences:** Users must use `init` instead of bare `/claudify`. Existing projects can now receive kit updates via `update`. `.claude/claudify.md` is fully kit-owned and should never be edited manually. The `.claude/claudify` record file must be kept in sync if a project switches blueprints.

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


### ADR-4: /pulse as a default command in all blueprints
**Date:** 2026-03-20
**Context:** Projects drift unintentionally — sessions accumulate tangential work that's never reconciled with original intent. Without a prompt to step back, drift goes unnoticed until it's significant.
**Decision:** Add `/pulse` as a standard command installed by every blueprint. It reads project context, presents a factual summary of intended vs. actual direction, and asks three questions (right problem / off track / avoiding something). Intentional pivots are recorded as ADRs; unintentional drift is corrected in PLAN.md and CONTEXT.md.
**Alternatives considered:** Folding the check into `/save` (too buried — users skip it when wrapping up); leaving it to the user to notice drift organically (the whole problem).
**Consequences:** Every claudified project gets a lightweight self-reflection tool. The tone is explicitly curious, not corrective, to keep it feel like a gut-check rather than an audit.

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
└── claudify.md         # The global /claudify command
```
