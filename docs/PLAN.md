# Plan

## Active

## Backlog
- [ ] Add-ons — composable units smaller than blueprints, orthogonal to project type ("plugins" rejected: collides with Claude Code's native plugin ecosystem). `/claudify add {name}` installs a doc template + optional command + context-loading rule (e.g. PEOPLE.md for stakeholder context, TRANSCRIPTS.md + /ingest for meeting transcripts with gitignored raw-data dir). Manifests in `addons/{name}.yml`, same schema as blueprints plus a `context:` rule field; existing installer template runs them unchanged. Wiring: rule injected into marker-delimited `## Add-ons` section of kit-owned `.claude/claudify.md` (blank at init); installed set recorded as `addons:` line in `.claude/claudify` so `update` can reassemble (re-fetch base, re-inject each rule). Global command gets an add-ons table + `## Steps: add`. Overload contract: one conditional trigger line per add-on (schema cannot express always-load), every add-on doc leads with a Quick Reference, docs are indexes — raw data stays cold until explicitly asked. guard-naming.sh is a blocklist, needs no change. v1: `add` subcommand + people + transcripts. Land docs-relocation first (add-ons multiply managed docs)
- [ ] Relocate kit-managed docs out of bare `docs/` — common filenames (ARCHITECTURE.md, ROADMAP.md) collide with real project docs, and skip-if-exists then leaves commands operating on non-kit files; doc-site pipelines (mkdocs/Sphinx) would also publish CONTEXT.md session state. Leaning `docs/{subdir}/` (name TBD) over `.claude/docs/` to preserve ADR-5's ownership split. Touches all five commands, `files/docs/claudify.md`, `session-wrap.sh`, and every blueprint's `dest`; `/claudify update` needs an old-layout detection + move step for existing projects
- [ ] Add tone and interaction guidelines to CLAUDE.md template — grounding defaults for conciseness, affirmations, unsolicited work, clarification behavior
- [ ] /report command + pre-compact hook — /report captures actual session findings (what was analyzed, what was found, open questions) to timestamped files in reports/analysis/ or reports/transient/; pre-compact.sh hook fires before context compaction and reminds user to run /report if this was an investigation session; reports/transient/ gitignored, reports/analysis/ committed; both in default kit
- [ ] Blueprint-specific navigation conventions — Python: __init__.py docstrings as package-level table of contents (reduces repeated file reads across sessions); Java: filesystem IS the map, minimal convention needed; JS/TS: index.js comment block or per-directory README; fold into existing blueprints + ARCHITECTURE.md ## Detail; also informs /continue (read index, not files)
- [ ] Sub-agent for blueprint generation — analyze existing project (structure, stack, entry points) and pre-fill CLAUDE.md and ARCHITECTURE.md stubs; more reliable than a wizard since it reads before asking; also addresses the unfilled-stubs problem
- [ ] Native Windows/PowerShell support — platform detection in claudify.md, PowerShell script templates for init and update, silent no-op for executable:true; blocked on having a Windows environment to test against
- [ ] Unfilled CLAUDE.md stubs — post-init nudge pointing out empty sections; stub detection in /continue (one-line warning); leaning toward reminder/checkpoint approach rather than an explicit command, but name TBD if command is added
- [ ] Non-coding blueprint: identify 2-3 concrete use cases (e.g. writing a book, research project, design project) to find the right abstraction — name, ARCHITECTURE.md reframing, trimmed command set
- [ ] Audit + migrate feature: structural drift detection (audit.sh) and content migration (/migrate command) for existing projects — removed for now due to convoluted UX, revisit once core flow is stable
- [ ] More blueprints: node-typescript, python, go
- [ ] post-tool-use hook: auto-lint on edit

## Done
- [x] Atomic downloads in installer templates — curl to `DEST.tmp` + `mv` on success, tmp removed on failure, `--retry 3` for transient errors; both init and update templates (ADR-10); e2e verified
- [x] Tool permissions in settings.json — `permissions.allow[]` (universal read-only set) + `ask[]` opt-in tier in all six blueprints; Claude merges into user-owned `.claude/settings.json` (ADR-8); e2e verified incl. merge with pre-existing settings
- [x] Operating conventions per blueprint — `## Operating Rules` in every CLAUDE template: uv + local `.venv` mandate, 5-step debugging methodology, per-stack instrumentation notes (ADR-9)
- [x] WSL2 CRLF fix — CRLF strip step in both script templates; `.gitattributes` LF enforcement; README updated; create→run→delete pattern preserved for future Windows symmetry
- [x] `/claudify init` / `/claudify update` — split CLAUDE.md into user-owned + kit-owned (`.claude/claudify.md`); update re-fetches hooks, commands, and kit rules; blueprint name stored in `.claude/claudify`
- [x] Revisit command names → continue, save, log, prep; dropped arch and standup
- [x] stop hook: CONTEXT.md staleness check + /wrap command for Claude-assisted session wrap
- [x] README.md
- [x] audit.sh — structural project evaluation with per-finding fix suggestions
- [x] /migrate command — Claude-assisted content migration for existing projects
- [x] Blueprint architecture: blueprints/*.yml + files/ directory
- [x] blueprints/python-tui.yml with Textual-specific docs
- [x] claudify.md — global /claudify slash command, fetches blueprints from GitHub
