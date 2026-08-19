# Architecture

## Quick Reference
<!-- Always read this section. Keep it under 20 lines.
     Stack, key constraints, and the most important patterns. -->

**Stack:** Bash, Markdown, YAML — no runtime dependencies
**Entry points:** `blueprints/*.yml` (applied by Claude via `/claudify`)
**Key constraints:** Hooks must be idempotent and handle missing files without hard exits; files must stay generic
**Patterns:** Blueprint declares `src` (in `files/`) → `dest` (in target project); Claude executes the install


## Decisions (ADRs)
<!-- Append new ADRs with /log -->

### ADR-14: Stub-first workflow rule stays language-agnostic in the shared `claudify.md`; concrete stub shape is owned per-blueprint by `CONVENTIONS.md`
**Date:** 2026-08-18
**Context:** ADR-13's follow-up work added a stub-first workflow rule (write contract + no-op body + named test cases, pause for fresh-context review) to `files/docs/claudify.md ## Behavior Rules` — the one file shared byte-identical across every blueprint. The rule's wording baked in Python vocabulary directly ("docstring," "`Raises`/edge-case enumeration"). A live-fire test against a fresh subagent confirmed the mechanism worked (it discovered and followed the pause-for-review rule with zero prompting). But a follow-up question — does this generalize past Python? — surfaced that Go has no exceptions (`Raises` doesn't apply; errors are returned values) and no named-test-function convention (idiomatic Go tests are table-driven, not one function per named scenario). The shared rule, as worded, would misdescribe the correct stub shape for any blueprint written for a non-exception, non-pytest-style language, even though each `CONVENTIONS-{type}.md` already has its own correctly-localized `## Stub` section (confirmed already true for all 5 shipped blueprints: Google-style docstrings for the four Python blueprints, JSDoc + `@throws` for simple-web).
**Decision:** Reworded the shared rule to describe the stub-first mechanism only, in paradigm-neutral terms (a documented contract + failure modes + a list of unimplemented test cases, in whatever form is idiomatic — deferring the concrete shape entirely to that project's own `## Stub` section in `docs/CONVENTIONS.md`). Also added an explicit guard: if a project has no `## Stub` section (true today for the `generic` blueprint, which ships no `CONVENTIONS.md` at all), the agent should ask before inventing one, rather than defaulting to Python's shape.
**Alternatives considered:** Duplicating a language-specific version of the rule into each `CLAUDE-{type}.md` — rejected because those files already explicitly delegate "workflow rules" to `claudify.md` (established in ADR-5), and duplicating would reintroduce the exact multi-copy drift problem ADR-5 was built to avoid, for a rule whose actual mechanism doesn't vary by language at all — only its concrete vocabulary does, which `CONVENTIONS.md` already owns.
**Consequences:** No architectural refactor was needed — the existing two-layer split (`claudify.md` = universal mechanism, `CONVENTIONS-{type}.md` = per-blueprint shape) already supported this once the shared rule stopped presupposing Python's vocabulary. Follow-up work for whoever builds a future non-Python blueprint (`node-typescript`, `go`, etc. — currently backlog-only): they must design that blueprint's own `## Stub` example from its actual test/contract idioms (e.g. table-driven cases and doc-comment error prose for Go) rather than copy-pasting the Python shape, and there's still no automated test enforcing that a `## Stub` section exists before the workflow rule is meaningful for that blueprint — left as a known gap, not yet backlogged as its own item.

### ADR-13: Add-ons v1 shipped — `/claudify add`, marker-section wiring, update reassembly
**Date:** 2026-08-18
**Context:** The add-ons design (composable doc+command units, orthogonal to blueprints — see the PLAN.md backlog entry) had been fully specified but not built. Needed to prove the mechanism end-to-end before adding more add-ons to the roster: install a doc/command/rule bundle, record what's installed, and have `update` correctly reconstruct it after overwriting the kit-owned rules file.
**Decision:** Built the `/claudify add {name}` subcommand, a blank `## Add-ons` marker section (`<!-- claudify:addons:start/end -->`) in the kit-owned `files/docs/claudify.md`, an append-only `addons:` line in `.claude/claudify`, and a new reassembly step in `## Steps: update` that re-fetches each installed add-on's command/hook files and re-injects its context rule after the base-file overwrite blanks the marker section. Two add-ons shipped as the initial set: `transcripts` (doc + `/ingest` command + gitignored raw dir — built first, as a full worked exemplar to pressure-test the design) and `people` (doc only, no command or setup — built second, to validate the minimal end of the schema). Both hand-verified end-to-end: install, then update, confirming user-owned docs survive the update untouched and the marker section round-trips byte-identical.
**Alternatives considered:** Designing the subcommand mechanism up front from the spec alone — rejected in favor of building `transcripts` first as a concrete exemplar, which surfaced three findings the spec had missed: recording must append (not use the blueprint `setup[].writefile` step, which always overwrites and would destroy the `blueprint:` line or other installed add-ons); add-ons can softly depend on each other's docs without requiring them (`/ingest` checks for `PEOPLE.md` if present); and update's existing file filter (only `.claude/commands|hooks/`) already does the right thing per add-on manifest with no new logic needed.
**Consequences:** Add-ons v1 is functionally complete and generalizes across the full schema range — no command, no setup, and full doc+command+setup shapes all install identically through the same installer-script template. Effort is deliberately pausing here rather than continuing through the candidate roster (links, glossary, experiments, runbook, datasets, sources) — the plan is to get real usage of `people`/`transcripts` first before building more. `tests/run.sh` gained an add-on integrity section (src files exist, `context` field non-empty, marker pair present) so future add-ons get the same coverage as blueprints.

### ADR-12: Kit-managed docs stay in bare `docs/` — relocation rejected
**Date:** 2026-07-17
**Context:** The backlog held a docs-relocation task (leaning `docs/{subdir}/`) to avoid filename collisions with real project docs (ARCHITECTURE.md, ROADMAP.md) and to keep doc-site pipelines from publishing CONTEXT.md session state. Deciding whether to land it before add-ons v1, since add-ons multiply the number of kit-managed docs.
**Decision:** Kit-managed docs stay in bare `docs/`. A claudify-named subdir would read as "kit internals, don't touch," undermining the kit's core premise that these docs are the *user's* docs — living project documentation they own and edit, not tool state. Bare `docs/` also renders cleanly on GitHub, which is part of the kit's value. Collision risk is accepted until it actually bites in a real project. The prerequisite ordering before add-ons v1 is dropped; add-on docs (PEOPLE.md, TRANSCRIPTS.md, …) land in bare `docs/` like everything else.
**Alternatives considered:** `docs/{subdir}/` (preserves ADR-5's ownership split but visually marks the docs as kit territory); `.claude/docs/` (worse — outright claims them as tool internals). Both solve a collision problem that hasn't yet occurred in practice.
**Consequences:** The original analysis stays parked in the backlog entry in case a collision does bite (commands operating on non-kit files via skip-if-exists, doc-site pipelines publishing session state). Add-on doc names should stay distinctive (PEOPLE.md, not NOTES.md) to keep collision risk low — a soft constraint on future add-on design. Add-ons v1 is now unblocked as the next implementation task.
**Date:** 2026-07-16
**Context:** Commands Claude runs during a session (`uv run pytest`, `uv run ruff check .`, …) had no manual counterpart — the user had to retype or rediscover them outside sessions, and in practice asked Claude to create a Makefile in every project. A recurring per-project request is a missing kit convention.
**Decision:** The kit-owned rules file (`files/docs/claudify.md`) gains a Behavior Rule: maintain a root `Makefile` mirroring the commands in CLAUDE.md `## Development Workflow` (`make test`, `make lint`, `make run`, …) — create it if missing, update it whenever those commands change.
**Alternatives considered:** Adding it to each CLAUDE-{type}.md template's `## Operating Rules` (ADR-9's home for per-stack conventions) — rejected because the rule is stack-independent (it derives its targets from the already-stack-specific Development Workflow section), it would be duplicated six times, and user-owned templates are skip-if-exists so existing projects would never receive it.
**Consequences:** Existing projects pick the rule up on their next `/claudify update` since the kit-owned file is always overwritten. Per-project opt-out requires editing a file that update clobbers — acceptable, consistent with every other rule in that file. Makefile itself is user-owned: the kit ships no template for it, Claude generates it from the project's own workflow commands.

### ADR-10: Atomic downloads with built-in retry in installer templates
**Date:** 2026-07-16
**Context:** The templates' `curl -o DEST` writes to the destination in place, so a mid-transfer failure (network drop, `--max-time` expiry) leaves a truncated `DEST`. Init's skip-if-exists then treats that partial file as installed on the very re-run the EXIT-trap message recommends, so the corruption persists silently. In practice Claude usually diagnosed the failure and improvised ad-hoc retries — it worked, but was non-deterministic and not a robust user experience.
**Decision:** Both script templates fetch to `DEST.tmp` and `mv` into place only on curl success; on failure the tmp file is removed (`|| { rm -f "DEST.tmp"; exit 1; }`), so `DEST` either exists complete or not at all. Also added `--retry 3` so transient network errors are retried deterministically inside the script instead of by Claude after the fact. The local `cp` path stays non-atomic — local copies don't truncate on network failure.
**Alternatives considered:** Post-download checksum/size validation (requires per-file metadata in blueprints — heavier, and still needs the tmp+mv dance to act on a mismatch); relying on Claude to notice and retry (the status quo being fixed); cleaning partial files in the EXIT trap (the trap can't distinguish a partial `DEST` from a pre-existing complete one).
**Consequences:** Re-runs after failure are now safe by construction — the trap's "re-run to finish" advice is actually correct. `--max-time 60` bounds the whole operation including retries, so a stalled transfer still can't hang the `wait` loop. `mv` atomicity holds because tmp and dest share a directory. Verified e2e: a 404 alongside a good file leaves the good file installed, no partial and no `.tmp` residue, exit 1, trap message printed.

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
