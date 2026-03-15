Apply a claudify blueprint to the current project.

## Configuration
SOURCE=https://raw.githubusercontent.com/konoerik/claudify/main

---

## Instructions

The user may pass a blueprint name as an argument (e.g. `/claudify python-tui`).
If no argument is given, list the available blueprints below and ask which to apply.

### Available blueprints
| Name | Use for |
|---|---|
| `generic` | Any project |
| `python-tui` | Python TUI projects using Textual |

---

## Steps

### 1. Fetch the blueprint

Fetch the YAML file from:
`{SOURCE}/blueprints/{name}.yml`

Parse it. Extract:
- `files[]` — each entry has `src`, `dest`, and optional `executable: true`
- `setup[]` — `mkdir` and `gitignore` steps
- `next_steps[]` — what to tell the user at the end

### 2. Install files

For each entry in `files[]`:
1. Check if `dest` already exists in the current project
2. If it exists: **skip it** — note the skip, never overwrite
3. If it does not exist:
   - Create any missing parent directories
   - Fetch the file content from `{SOURCE}/{src}`
   - Write it to `dest`
4. If `executable: true`: run `chmod +x {dest}`

### 3. Run setup steps

For each entry in `setup[]`:
- `mkdir` → create the directory if it does not exist
- `gitignore` → append the entry to `.gitignore` if not already present

### 4. Report

Print a clean summary:
- **Installed:** each file written
- **Skipped:** each file that already existed (no action taken)

Then print each item in `next_steps[]` as a numbered list under the heading **Next steps**.
