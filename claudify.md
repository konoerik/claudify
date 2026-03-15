Apply a claudify blueprint to the current project.

## Configuration
SOURCE=https://raw.githubusercontent.com/konoerik/claudify/main

---

## Instructions

The user may pass arguments:
- `/claudify {name}` — apply a named blueprint from GitHub
- `/claudify {name} {path}` — apply a named blueprint from a local clone at `{path}`

If no blueprint name is given, list the available blueprints below and ask which to apply.

### Available blueprints
| Name | Use for |
|---|---|
| `generic` | Any project |
| `python-tui` | Python TUI projects using Textual |

---

## Steps

### 1. Greet the user

Tell the user which blueprint you are about to apply and where you are installing from (GitHub or the local path). Say you will install all files and report what changed.

### 2. Resolve source and fetch the blueprint

If a local path was given, set `SOURCE` to that path. Otherwise use the default `SOURCE` from Configuration above.

- **Remote** (`SOURCE` is a URL): use `Bash` with `curl -fsSL` to fetch `{SOURCE}/blueprints/{name}.yml`
- **Local** (`SOURCE` is a path): use `Bash` with `cat` to read `{SOURCE}/blueprints/{name}.yml`

Parse it. Extract:
- `files[]` — each entry has `src`, `dest`, and optional `executable: true`
- `setup[]` — `mkdir` and `gitignore` steps
- `next_steps[]` — what to tell the user at the end

### 3. Generate and run the installer script

Using the blueprint data and the template below, write a script to `.claudify-install.sh`,
run it with `Bash`, then delete it.

Fill in one block per `files[]` entry and one line per `setup[]` entry.
Collect all unique parent directories (from `dest` paths and `setup[].mkdir` entries)
and emit them as `mkdir -p` calls at the top.

Use `curl -fsSL "$SOURCE/SRC" -o "DEST"` for remote sources and `cp "$SOURCE/SRC" "DEST"` for local sources.

**Template:**

```bash
#!/usr/bin/env bash
set -euo pipefail
SOURCE="..."  # resolved SOURCE — URL or absolute path

# directories
mkdir -p "DIR_1"
mkdir -p "DIR_2"

# files
if [ -f "DEST" ]; then
  echo "skipped: DEST"
else
  curl -fsSL "$SOURCE/SRC" -o "DEST"  # remote; or: cp "$SOURCE/SRC" "DEST"  # local
  # if executable: true, add: chmod +x "DEST"
  echo "installed: DEST"
fi

# gitignore (one line per setup[].gitignore entry)
grep -qxF "ENTRY" .gitignore 2>/dev/null || echo "ENTRY" >> .gitignore
```

### 4. Report

Parse the script output. Print a clean summary:
- **Installed:** each file written
- **Skipped:** each file that already existed (no action taken)

Then print each item in `next_steps[]` as a numbered list under the heading **Next steps**.

Finally, print this note:

> **Note:** Restart Claude Code now so it discovers the newly installed commands.
