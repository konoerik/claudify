Apply or update a claudify blueprint in the current project.

## Configuration
SOURCE=https://raw.githubusercontent.com/konoerik/claudify/main

---

## Instructions

The user may pass arguments:
- `/claudify init` — choose a blueprint and apply it
- `/claudify init {name}` — apply a named blueprint from GitHub
- `/claudify init {name} {path}` — apply a named blueprint from a local clone at `{path}`
- `/claudify update` — re-fetch hooks, commands, and `.claude/claudify.md` for the installed blueprint

If no subcommand is given, show the subcommands above and ask what they want to do.

### Available blueprints
| Name | Use for |
|---|---|
| `generic` | Any project |
| `python-flask` | Flask web applications |
| `python-lib` | Python libraries |
| `python-tui` | Python TUI projects using Textual |
| `simple-web` | Single-page HTML/CSS/JS apps, no build step |

---

## Steps: init

### 1. Greet the user

Tell the user which blueprint you are about to apply and where you are installing from (GitHub or the local path). Say you will install all files and report what changed.

### 2. Resolve source and fetch the blueprint

If a local path was given, set `SOURCE` to that path. Otherwise use the default `SOURCE` from Configuration above.

- **Remote** (`SOURCE` is a URL): use `Bash` with `curl -fsSL` to fetch `{SOURCE}/blueprints/{name}.yml`
- **Local** (`SOURCE` is a path): use `Bash` with `cat` to read `{SOURCE}/blueprints/{name}.yml`

Parse it. Extract:
- `files[]` — each entry has `src`, `dest`, and optional `executable: true`
- `setup[]` — `mkdir`, `gitignore`, and `writefile` steps
- `next_steps[]` — what to tell the user at the end

### 3. Generate and run the installer script

Using the blueprint data and the template below, write a script to `.claudify-install.sh`.
Then strip any CRLF line endings (required on WSL2), run it, and delete it:

```bash
sed -i 's/\r//' .claudify-install.sh && bash .claudify-install.sh && rm .claudify-install.sh
```

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

# files (skipped if already exist)
if [ -f "DEST" ]; then
  echo "skipped: DEST"
else
  curl -fsSL "$SOURCE/SRC" -o "DEST"  # remote; or: cp "$SOURCE/SRC" "DEST"  # local
  # if executable: true, add: chmod +x "DEST"
  echo "installed: DEST"
fi

# gitignore (one line per setup[].gitignore entry)
grep -qxF "ENTRY" .gitignore 2>/dev/null || echo "ENTRY" >> .gitignore

# writefile (one block per setup[].writefile entry — always writes)
echo "CONTENT" > "PATH"
echo "wrote: PATH"
```

### 4. Report

Parse the script output. Print a clean summary:
- **Installed:** each file written
- **Skipped:** each file that already existed (no action taken)

Then print each item in `next_steps[]` as a numbered list under the heading **Next steps**.

Finally, print this note:

> **Note:** Restart Claude Code now so it discovers the newly installed commands and `.claude/claudify.md`.

---

## Steps: update

### 1. Read the installed blueprint name

Read `.claude/claudify`. It contains a single line: `blueprint: {name}`.

If the file does not exist, stop and tell the user:
> `.claude/claudify` not found — this project was not set up with `claudify init`. Run `/claudify init` first.

### 2. Resolve source and fetch the blueprint

Use the default `SOURCE` from Configuration (update always pulls from GitHub, not a local path).

Fetch `{SOURCE}/blueprints/{name}.yml` with `curl -fsSL`.

Parse it. Extract only `files[]` entries where `dest` starts with `.claude/hooks/`, `.claude/commands/`, or `dest` is `.claude/claudify.md`.

### 3. Generate and run the update script

Write a script to `.claudify-update.sh`. Then strip any CRLF line endings (required on WSL2), run it, and delete it:

```bash
sed -i 's/\r//' .claudify-update.sh && bash .claudify-update.sh && rm .claudify-update.sh
```

Unlike init, update **always overwrites** — no skip logic.

**Template:**

```bash
#!/usr/bin/env bash
set -euo pipefail
SOURCE="..."  # always the remote URL

# directories
mkdir -p "DIR_1"

# files (always overwrite)
curl -fsSL "$SOURCE/SRC" -o "DEST"
# if executable: true, add: chmod +x "DEST"
echo "updated: DEST"
```

### 4. Report

Print a clean summary:
- **Updated:** each file re-fetched

Then print this note:

> **Note:** Restart Claude Code now so it picks up the updated commands and rules.
