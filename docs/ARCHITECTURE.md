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

### ADR-9: Operating rules per-template in CLAUDE-{type}.md — uv/venv mandate, fixed debugging methodology
**Date:** 2026-07-16
**Context:** Blueprints shipped code-style conventions (CONVENTIONS.md) but no rules for *how Claude operates* in a project: which environment to run commands in, and how to debug. In practice Claude would fall back to system Python instead of the project venv, and improvise debugging approaches — sometimes pulling in new dependencies — burning tokens on ad-hoc tooling.
**Decision:** Each CLAUDE-{type}.md template gains an `## Operating Rules` section with two parts. **Environment:** Python blueprints mandate `uv` + local `.venv`, never system Python, with all commands via `uv run` and dependency changes only through `uv add`/`uv remove` (python-only additionally forbids packages outright; simple-web forbids npm/bundlers; generic requires the project's declared toolchain). **Debugging:** a fixed 5-step sequence — reproduce → read the full error → isolate (existing tests + git) → instrument (built-in tools only, removed after) → never add a dependency to debug — tailored per stack (e.g. python-tui: `self.log()` + `textual console`, since the app owns stdout). Rules live in the templates on a per-blueprint basis; duplication across the Python variants is accepted. Development Workflow blocks were aligned (`uv run ...`), and simple-web dropped `npx serve`.
**Alternatives considered:** Kit-owned `.claude/claudify.md` (updatable via `/claudify update` and deduplicated, but the file is deliberately stack-agnostic and shared — stack rules don't belong there); CONVENTIONS.md `## Operating` section (only loaded when writing code — operating rules must be in the always-loaded CLAUDE.md).
**Consequences:** CLAUDE.md is user-owned, so operating rules reach existing projects only via manual copy — `/claudify update` cannot refresh them. Rule wording is duplicated across four Python templates and must be kept in sync by hand when it evolves. The uv mandate is now a kit default; projects that genuinely use pip/poetry must edit their CLAUDE.md after init.

### ADR-8: Blueprint `permissions` section — Claude-merged allowlist in settings.json, opt-in ask tier
**Date:** 2026-07-15
**Context:** Fresh claudified projects prompt for permission on every read-only shell command (cat, ls, grep, git diff …), adding friction to the first session. Blueprints had no way to ship tool permissions. `.claude/settings.json` is user-owned and may already exist with user entries, so neither of the kit's file semantics fits: init's skip-if-exists would silently drop the grants, and update's always-overwrite would destroy user configuration.
**Decision:** Blueprints gain a `permissions` section with two tiers: `allow[]` — a universal read-only command list (file inspection + git status/diff/log/show), auto-granted; and `ask[]` — blueprint-specific run/test rules (`rule` + `purpose`, e.g. pytest, flask) offered interactively at init only. Claude performs the merge itself via Read/Edit as a skill step — not inside the installer script — adding only missing entries to `permissions.allow`, never removing entries, never touching `deny`. `update` re-merges `allow[]` only, keeping it non-interactive.
**Alternatives considered:** Shipping `settings.json` as a `files[]` entry (skip-if-exists drops grants for projects with existing settings; overwrite destroys them); merging inside the bash installer via `jq` (new dependency, violates the no-dependencies constraint) or `python3` (not guaranteed, and ADR-3's script exists to batch downloads, not to edit JSON).
**Consequences:** Permission rules can't be path-scoped to the project directory — `Bash(cat:*)` allows cat anywhere; the allow tier is therefore restricted to genuinely read-only commands. Every blueprint must carry the (duplicated) universal list; tests enforce its presence. New `ask` rules added to a blueprint are only offered at init, so existing projects must enable them manually. Merge correctness depends on Claude following the skill instructions rather than deterministic code.

### ADR-7: Portable runner line — `tr` for CRLF strip, no `exit`, curl timeouts
**Date:** 2026-07-11
**Context:** The 2026-05-02 runner invocation (`; _s=$?; rm -f ...; exit $_s`) ended with `exit`, which kills Claude Code's persistent Bash session — installer output was lost ("Bash completed with no output") and subsequent commands started in a fresh shell at a different working directory, so installs appeared missing or genuinely failed on re-run (macOS/Linux; documented in bug-report-claudify-exit.md). Separately, `sed -i 's/\r//'` is GNU-only syntax: BSD sed on macOS consumes the pattern as the `-i` backup suffix and misparses the filename as the sed script, so the CRLF strip errored and never ran on Mac. The parallel curl calls also had no timeout, so a stalled connection could block the `wait` loop indefinitely.
**Decision:** Runner line is now `tr -d '\r' < SCRIPT > SCRIPT.tmp && mv SCRIPT.tmp SCRIPT; bash SCRIPT; rm -f SCRIPT` — portable CRLF strip, always-delete, and no `exit` so the harness shell survives. Added `--max-time 60` to the parallel curl lines in both templates. Success/failure is conveyed through script output (the `_ok` flag + EXIT trap), not the invocation's exit status.
**Alternatives considered:** Dual-syntax sed fallback (`sed -i.bak ... || sed -i ...`) — works but keeps two code paths; keeping `exit $_s` for status propagation — fundamentally incompatible with Claude Code's persistent-shell model.
**Consequences:** The Bash tool's exit status now reflects the trailing `rm`, not the installer — the skill must parse output text, which it already does. WSL2 CRLF handling is preserved via `tr` (POSIX, identical everywhere). Curl stalls are bounded at 60s per file.

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
