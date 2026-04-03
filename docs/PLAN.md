# Plan

## Active

## Backlog
- [ ] Add tone and interaction guidelines to CLAUDE.md template — grounding defaults for conciseness, affirmations, unsolicited work, clarification behavior
- [ ] Unfilled CLAUDE.md stubs — post-init nudge pointing out empty sections; stub detection in /continue (one-line warning); leaning toward reminder/checkpoint approach rather than an explicit command, but name TBD if command is added
- [ ] Non-coding blueprint: identify 2-3 concrete use cases (e.g. writing a book, research project, design project) to find the right abstraction — name, ARCHITECTURE.md reframing, trimmed command set
- [ ] Audit + migrate feature: structural drift detection (audit.sh) and content migration (/migrate command) for existing projects — removed for now due to convoluted UX, revisit once core flow is stable
- [ ] More blueprints: node-typescript, python, go
- [ ] post-tool-use hook: auto-lint on edit

## Done
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
