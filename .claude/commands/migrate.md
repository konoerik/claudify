Migrate this project to claudify conventions. Work through findings one at a time, confirming before making any changes.

## Step 1: Audit

Check for:
- Missing files: CLAUDE.md, CONTEXT.md, PLAN.md, ARCHITECTURE.md
- Non-canonical files: BACKLOG.md, TASKS.md, TODO.md, TODOS.md, TASK.md
- PLAN.md missing ## Active / ## Backlog / ## Done sections
- ARCHITECTURE.md missing ## Quick Reference section
- CLAUDE.md missing a Context Loading section

## Step 2: Present a migration plan

List every issue found, grouped as:
- **Content migrations** (file contents need to move or be restructured)
- **Missing files** (need to be created)
- **Structural fixes** (sections need to be added to existing files)

Ask: "Shall I work through these one by one?"

## Step 3: Execute — one finding at a time

### Non-canonical files (BACKLOG.md, TASKS.md, TODO.md, etc.)
1. Read the file and show its contents
2. Ask: "Move these items to PLAN.md ## Backlog and delete [filename]?"
3. On confirmation: append items to PLAN.md ## Backlog, delete the source file

### Missing PLAN.md
Create with ## Active / ## Backlog / ## Done sections, migrating any task file contents found.

### Missing CONTEXT.md
Read CLAUDE.md and run `git log --oneline -10`, draft CONTEXT.md fields, show draft, confirm, write.

### Missing ARCHITECTURE.md
Read existing architecture notes, draft ## Quick Reference, confirm, write.

### CLAUDE.md missing Context Loading section
Show the section to be added, confirm, append — do not rewrite the rest of CLAUDE.md.

### ARCHITECTURE.md missing ## Quick Reference
Draft from existing content, confirm, prepend to file.

### Missing /wrap sentinel
Add `<!-- wrapped: never -->` as the last line of CONTEXT.md.

## Step 4: Summary

Report what was changed. Remind the user to run /wrap at the end of the session.
