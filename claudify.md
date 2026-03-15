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

Use `Bash` with `curl -fsSL` to fetch the YAML file from:
`{SOURCE}/blueprints/{name}.yml`

Parse it. Extract:
- `files[]` — each entry has `src`, `dest`, and optional `executable: true`
- `setup[]` — `mkdir` and `gitignore` steps
- `next_steps[]` — what to tell the user at the end

### 2. Generate and run the installer script

Using the blueprint data and the template below, write a script to `.claudify-install.sh`,
run it with `Bash`, then delete it.

Fill in one block per `files[]` entry and one line per `setup[]` entry.
Collect all unique parent directories (from `dest` paths and `setup[].mkdir` entries)
and emit them as `mkdir -p` calls at the top.

**Template:**

```bash
#!/usr/bin/env bash
set -euo pipefail
SOURCE="https://raw.githubusercontent.com/konoerik/claudify/main"

# directories
mkdir -p "DIR_1"
mkdir -p "DIR_2"

# files
if [ -f "DEST" ]; then
  echo "skipped: DEST"
else
  curl -fsSL "$SOURCE/SRC" -o "DEST"
  # if executable: true, add: chmod +x "DEST"
  echo "installed: DEST"
fi

# gitignore (one line per setup[].gitignore entry)
grep -qxF "ENTRY" .gitignore 2>/dev/null || echo "ENTRY" >> .gitignore
```

### 3. Report

Parse the script output. Print a clean summary:
- **Installed:** each file written
- **Skipped:** each file that already existed (no action taken)

Then print each item in `next_steps[]` as a numbered list under the heading **Next steps**.

Finally, print this note:

> **Note:** Restart Claude Code now so it discovers the newly installed commands.
