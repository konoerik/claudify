# claudify

A Claude Code configuration kit that gives any project consistent document conventions, token-efficient context loading, automated session management, and useful slash commands.

## The problem

Every project worked on with Claude Code tends to grow its own ad-hoc structure — `BACKLOG.md` here, `TASKS.md` there, `ARCHITECTURE.md` in one project and nothing equivalent in another. Conventions drift. Context gets stale. You re-explain the same things every session.

claudify fixes this by giving every project the same starting point.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated

---

## Setup (once)

Install the `/claudify` command globally so it's available in every project:

```bash
mkdir -p ~/.claude/commands && \
  curl -fsSL https://raw.githubusercontent.com/konoerik/claudify/main/claudify.md \
  -o ~/.claude/commands/claudify.md
```

That's it — you never touch claudify again.

---

## Usage (per project)

Open Claude Code in any project and run:

```
/claudify
```

Claude will ask which blueprint to apply, then fetch and install everything. Nothing is overwritten if files already exist.

To skip the prompt, name the blueprint directly:

```
/claudify python-tui
```

To install from a local clone instead of GitHub (useful when developing blueprints):

```
/claudify generic /path/to/claudify
```

### Available blueprints

| Blueprint | Use for |
|---|---|
| `generic` | Any project |
| `python-flask` | Flask web applications |
| `python-lib` | Python libraries |
| `python-tui` | Python TUI projects using [Textual](https://textual.textualize.io) |

---

## What you get

### Document conventions

| File | Purpose | When Claude reads it |
|---|---|---|
| `CLAUDE.md` | Project overview, stack, conventions, behavior rules | Every session |
| `CONTEXT.md` | Current focus, last session summary, next action | Every session |
| `PLAN.md` | Active tasks / backlog / done | When work is discussed |
| `ARCHITECTURE.md` | Stack, constraints, ADRs | When touching structure |
| `ROADMAP.md` | Goals, phases, out of scope | On demand |

`CONTEXT.md` is intentionally tiny — it's the only file loaded every session. Everything else loads on demand, keeping token usage low as projects grow.

`PLAN.md` uses three sections (`## Active`, `## Backlog`, `## Done`) instead of separate files. Claude reads only `## Active` by default.

### Slash commands installed into your project

| Command | What it does |
|---|---|
| `/continue` | Surface current focus and active tasks, ask what to work on |
| `/save` | End-of-session: rewrite `CONTEXT.md`, move completed tasks to Done |
| `/log` | Record an architectural decision (ADR) in `ARCHITECTURE.md` |
| `/prep` | Pre-commit checklist: tests, docs, no stray TODOs |

### Hooks installed into your project

| Hook | Trigger | What it does |
|---|---|---|
| `stop/session-wrap.sh` | Session end | Archives `## Done` tasks; warns if `/save` wasn't run |
| `pre-tool-use/guard-naming.sh` | Before file writes | Blocks `BACKLOG.md`, `TASKS.md`, `TODO.md` etc. |

### Recommended workflow

```
Start of session  →  Claude reads CONTEXT.md automatically
                      Run /continue to orient

During session    →  Run /log when making architectural decisions
                      Keep PLAN.md ## Active updated as you go

End of session    →  Run /save
                      Claude rewrites CONTEXT.md and moves done tasks
                      Stop hook archives and checks everything is clean
```

---

## Limitations

claudify is designed for individual developers or small teams working with Claude Code. It is not suitable for:

- **Large task volumes** — `PLAN.md` is a flat file; it gets unwieldy past ~50 items. Use a proper issue tracker (GitHub Issues, Linear) for high-volume projects
- **Team workflows** — `CONTEXT.md` and `PLAN.md` have a single shared state; there is no concept of multiple contributors or assignments
- **Windows (native)** — hooks require bash and standard Unix tools; use WSL if on Windows
- **Long-lived architecture docs** — `ARCHITECTURE.md` grows with every ADR; loading it fully becomes expensive over time. Keep `## Quick Reference` concise

---

## Repo structure

```
claudify/
├── claudify.md           ← the global /claudify command (install this to ~/.claude/commands/)
├── docs/               ← this repo's own CONTEXT, PLAN, ARCHITECTURE, ROADMAP
├── blueprints/         ← YAML manifests declaring what each blueprint installs
├── files/              ← source files referenced by blueprints
│   ├── docs/           ← document templates (shared + per-blueprint variants)
│   ├── hooks/          ← hook scripts
│   └── commands/       ← slash command prompts
```
