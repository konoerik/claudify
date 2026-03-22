# CLAUDE.md

## Project Overview
claudify is a Claude Code configuration kit distributed as a single slash command (`claudify.md`). Users install it once to `~/.claude/commands/`, then run `/claudify` in any project to apply a blueprint — fetching and installing docs, hooks, and commands from GitHub.

## Tech Stack
Bash, Markdown, YAML. No build step, no dependencies.

## Key Conventions
- `claudify.md` is the primary artifact — it's the global `/claudify` command users install; supports `init` and `update` subcommands
- `blueprints/` contains YAML manifests declaring what each blueprint installs
- `files/` contains the source files blueprints reference — docs, hooks, commands
- Blueprint-specific doc variants are named `CLAUDE-{type}.md`, `ARCHITECTURE-{type}.md`
- `files/docs/claudify.md` is the kit-owned rules file; installed to `.claude/claudify.md` in target projects — always overwritten by `update`
- `.claude/claudify` (in target projects) stores the blueprint name for use by `update`
- All hook scripts must handle missing files gracefully (no hard exits)

## Development Workflow
```bash
# Run tests (blueprint integrity + shellcheck)
bash tests/run.sh

# Lint shell scripts directly
shellcheck files/hooks/*.sh
```

## Context Loading

Read on every session:
- `docs/CONTEXT.md` — current focus, last decisions, next action

Read when the user mentions tasks, features, or current work:
- `docs/PLAN.md` — `## Active` section only

Read when touching blueprints, hooks, commands, or kit conventions:
- `docs/ARCHITECTURE.md` — `## Quick Reference` first; full file only if needed

Load only when explicitly asked about goals or priorities:
- `docs/ROADMAP.md`

Never auto-load:
- `.claude/archive/`

## Behavior Rules
- Do not create `BACKLOG.md`, `TASKS.md`, `TODO.md` — use `PLAN.md`
- When adding a new hook or command, add it to `files/` and reference it in all relevant blueprints
- When making a design decision about kit conventions, record it with `/log`
- Keep files in `files/docs/` generic — project-specific content goes in named variants
- Never commit or push without explicit instruction
