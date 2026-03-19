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

## Ideas
- **Scaling convention:** Large projects could opt into domain partitioning — `PLAN-{area}.md` files with the same three-section structure, `ARCHITECTURE.md` ADR archiving, and an `**Area:**` field in `CONTEXT.md` to tell Claude which slice to load. Small projects stay unchanged; partitioning is opt-in. Guard-naming hook would need updating to allow `PLAN-*.md` filenames.


<!-- Unvetted thoughts — not committed to, just worth remembering. -->

- **Bug tracking convention:** Projects with high bug volume (e.g. python-lib) might benefit from a `BUG-N:` prefix convention in PLAN.md, or a structured BUGS.md. Held off to avoid fragmenting task management — revisit if a clear use case emerges.
- **Non-coding blueprint:** A blueprint for writing, research, or design projects. Needs 2-3 concrete examples to find the right abstraction — ARCHITECTURE.md reframing, trimmed command set, better name than "noncoding".
- **`/as` persona command:** For projects with multiple authoring roles (e.g. developer + domain expert). Currently not needed since inline requests ("as the instructor, evaluate...") work fine — revisit if session-level persona switching becomes useful.

## Out of Scope
- Any runtime beyond bash and standard Unix tools
- A web UI or TUI
- Managing Claude API keys or settings.json
