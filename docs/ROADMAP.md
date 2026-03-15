# Roadmap
<!-- Load only when explicitly discussing goals or priorities.
     This is a high-level document — avoid granular tasks here, those belong in PLAN.md. -->

## Goal
A single `/claudify` slash command — installed once globally — sets up any project with a complete, opinionated Claude Code workflow. No cloning, no shell scripts, no mental model of the repo required.

## Phases

### Phase 1: Core (current)
`claudify.md` global command, `generic` and `python-tui` blueprints. Works for any project.
Out of scope: language-specific variants beyond python-tui, GUI, package distribution.

### Phase 2: More blueprints
`node-typescript`, `python`, `go`. Each shares the same hooks and commands; only the project docs differ.

### Phase 3: Versioning
Pin blueprints to a tag/commit so projects don't drift when claudify updates. `/claudify python-tui@v1.2`.

## Out of Scope
- Any runtime beyond bash and standard Unix tools
- A web UI or TUI
- Managing Claude API keys or settings.json
