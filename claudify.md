Apply or update a claudify blueprint in the current project.

## Configuration
SOURCE=https://raw.githubusercontent.com/konoerik/claudify/main

---

## Instructions

The user may pass arguments:
- `/claudify init` — choose a blueprint and apply it
- `/claudify init {name}` — apply a named blueprint from GitHub
- `/claudify init {name} {path}` — apply a named blueprint from a local clone at `{path}`
- `/claudify update` — re-fetch hooks, commands, `.claude/claudify.md`, and installed add-ons for the installed blueprint, from the latest commit on `main`
- `/claudify update {sha}` — same, but pin to a specific commit instead of latest `main` (rollback, or reproduce an exact prior install)
- `/claudify add {name}` — install an add-on: a doc template plus optional command, layered on top of any blueprint

If no subcommand is given, show the subcommands above and ask what they want to do.

### Available blueprints
| Name | Use for |
|---|---|
| `generic` | Any project |
| `python-flask` | Flask web applications |
| `python-lib` | Python libraries |
| `python-tui` | Python TUI projects using Textual |
| `python-only` | Pure Python — stdlib only, no external dependencies |
| `simple-web` | Single-page HTML/CSS/JS apps, no build step |

### Available add-ons
| Name | Adds |
|---|---|
| `people` | `docs/PEOPLE.md` — stakeholder/contact directory, no command |
| `transcripts` | `docs/TRANSCRIPTS.md` index + `/ingest` — meeting-transcript summaries, raw text gitignored |

Add-ons are orthogonal to blueprints — install any number, on top of any blueprint.

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
- `permissions` — `allow[]` (auto-granted rules) and optional `ask[]` (entries with `rule` and `purpose`)
- `next_steps[]` — what to tell the user at the end

### 3. Generate and run the installer script

Using the blueprint data and the template below, write a script to `.claudify-install.sh`.
Then strip any CRLF line endings (required on WSL2), run it, and delete it:

```bash
tr -d '\r' < .claudify-install.sh > .claudify-install.tmp && mv .claudify-install.tmp .claudify-install.sh; bash .claudify-install.sh; rm -f .claudify-install.sh
```

Fill in one block per `files[]` entry and one line per `setup[]` entry.
Collect all unique parent directories (from `dest` paths and `setup[].mkdir` entries)
and emit them as `mkdir -p` calls at the top.

Remote downloads must be atomic: fetch to `DEST.tmp`, then `mv` into place only on success, so a mid-transfer failure never leaves a partial file that skip-if-exists would treat as installed. Use `cp "$SOURCE/SRC" "DEST"` for local sources.

**Template:**

```bash
#!/usr/bin/env bash
set -euo pipefail
SOURCE="..."  # resolved SOURCE — URL or absolute path

_ok=0
trap '[[ $_ok -eq 0 ]] && echo "claudify: install incomplete — re-run /claudify init to finish"' EXIT

# directories
mkdir -p "DIR_1"
mkdir -p "DIR_2"

# files — parallel downloads (skipped if already exist)
_pids=()

(
  if [ -f "DEST" ]; then
    echo "skipped: DEST"
  else
    # remote (atomic: no partial DEST on failure); or for local sources: cp "$SOURCE/SRC" "DEST"
    curl -fsSL --retry 3 --max-time 60 "$SOURCE/SRC" -o "DEST.tmp" \
      && mv "DEST.tmp" "DEST" || { rm -f "DEST.tmp"; exit 1; }
    # if executable: true, add: chmod +x "DEST"
    echo "installed: DEST"
  fi
) & _pids+=($!)

# wait for all downloads; exit if any failed
_failed=0
for _pid in "${_pids[@]}"; do wait "$_pid" || _failed=1; done
[ "$_failed" -eq 0 ] || exit 1

# gitignore (one line per setup[].gitignore entry)
grep -qxF "ENTRY" .gitignore 2>/dev/null || echo "ENTRY" >> .gitignore

# writefile (one block per setup[].writefile entry — always writes)
echo "CONTENT" > "PATH"
echo "wrote: PATH"

_ok=1
```

### 4. Record the installed commit

If `SOURCE` is remote, resolve the commit actually installed:
```bash
SHA=$(curl -fsSL https://api.github.com/repos/konoerik/claudify/commits/main | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")
```
Append it to `.claude/claudify` (the installer script already wrote it with `blueprint: {name}`):
```bash
echo "commit: $SHA" >> .claude/claudify
```
If `SOURCE` is a local path, skip this step — there's no commit to pin.

### 5. Apply permissions

`.claude/settings.json` is user-owned — **merge into it, never overwrite it**. Do this yourself with Read/Edit/Write (not in the installer script):

- If `.claude/settings.json` does not exist, create it:
  ```json
  {
    "permissions": {
      "allow": ["...each permissions.allow entry..."]
    }
  }
  ```
- If it exists, read it and append only the `permissions.allow[]` entries that are missing from its `permissions.allow` array (create the key if absent). Preserve all existing entries, all other settings, and never modify `deny`.

Then, if the blueprint has `permissions.ask[]` entries, list each `rule` with its `purpose` and ask the user which to enable (all, some, or none). Merge the accepted ones the same way.

### 6. Report

Parse the script output. Print a clean summary:
- **Installed:** each file written
- **Skipped:** each file that already existed (no action taken)
- **Permissions:** rules added to `.claude/settings.json` (and how many were already present)
- **Commit:** the pinned commit SHA (if resolved)

Then print each item in `next_steps[]` as a numbered list under the heading **Next steps**.

Finally, print this note:

> **Note:** Restart Claude Code now so it discovers the newly installed commands and `.claude/claudify.md`.

---

## Steps: add

### 1. Check prerequisites

Read `.claude/claudify`. If it does not exist, stop and tell the user:
> `.claude/claudify` not found — this project was not set up with `claudify init`. Run `/claudify init` first.

If no `{name}` argument was given, show the **Available add-ons** table above and ask which to install.

If `{name}` is already listed on the `addons:` line of `.claude/claudify`, tell the user it's already installed and stop — suggest `/claudify update` if they want it refreshed.

### 2. Fetch the add-on manifest

Use the default `SOURCE` from Configuration. Fetch `{SOURCE}/addons/{name}.yml` with `curl -fsSL`.

Parse it. Extract `files[]`, `setup[]`, and `next_steps[]` exactly as in blueprint `init` step 2, plus the new `context` field (a single string).

### 3. Generate and run the installer script

Same template and CRLF-strip wrapper as blueprint `init` step 3 — skip-if-exists, atomic remote downloads. `files[]` and `setup[]` from an add-on manifest run through the identical template; nothing add-on-specific belongs in the script.

### 4. Inject the context rule

Read `.claude/claudify.md`. Find the marker pair:
```
<!-- claudify:addons:start -->
<!-- claudify:addons:end -->
```
Insert a new bullet line `- {context}` between the markers, after any bullets already there (preserve existing ones — never remove or reorder).

### 5. Record the add-on

Read `.claude/claudify`. If it has an `addons:` line, append `, {name}` to it. If not, add a new line `addons: {name}`. Rewrite the whole file with Write — this is a targeted append, not the blueprint `setup[].writefile` step (which always overwrites and would destroy the `blueprint:` line or any other installed add-ons).

### 6. Report

Same shape as blueprint `init` step 6: **Installed**/**Skipped** files, then `next_steps[]` as a numbered list, then the restart note.

---

## Steps: update

### 1. Read the installed blueprint name

Read `.claude/claudify`. It has a `blueprint: {name}` line, and may also have `addons:` and `commit:` lines.

If the file does not exist, stop and tell the user:
> `.claude/claudify` not found — this project was not set up with `claudify init`. Run `/claudify init` first.

### 2. Resolve source and fetch the blueprint

If a `{sha}` argument was given to `/claudify update`, set `SOURCE` to `https://raw.githubusercontent.com/konoerik/claudify/{sha}` — this pins the update to that commit (rollback, or reproducing a prior install). Otherwise use the default `SOURCE` from Configuration, which tracks latest `main` (update always pulls from GitHub, not a local path).

Fetch `{SOURCE}/blueprints/{name}.yml` with `curl -fsSL`.

Parse it. Extract only `files[]` entries where `dest` starts with `.claude/hooks/`, `.claude/commands/`, or `dest` is `.claude/claudify.md`. Also extract `permissions.allow[]`.

### 3. Generate and run the update script

Write a script to `.claudify-update.sh`. Then strip any CRLF line endings (required on WSL2), run it, and delete it:

```bash
tr -d '\r' < .claudify-update.sh > .claudify-update.tmp && mv .claudify-update.tmp .claudify-update.sh; bash .claudify-update.sh; rm -f .claudify-update.sh
```

Unlike init, update **always overwrites** — no skip logic.

**Template:**

```bash
#!/usr/bin/env bash
set -euo pipefail
SOURCE="..."  # always the remote URL

_ok=0
trap '[[ $_ok -eq 0 ]] && echo "claudify: update incomplete — re-run /claudify update to finish"' EXIT

# directories
mkdir -p "DIR_1"

# files — parallel downloads (always overwrite)
_pids=()

(
  # atomic: no partial DEST on failure
  curl -fsSL --retry 3 --max-time 60 "$SOURCE/SRC" -o "DEST.tmp" \
    && mv "DEST.tmp" "DEST" || { rm -f "DEST.tmp"; exit 1; }
  # if executable: true, add: chmod +x "DEST"
  echo "updated: DEST"
) & _pids+=($!)

# wait for all downloads; exit if any failed
_failed=0
for _pid in "${_pids[@]}"; do wait "$_pid" || _failed=1; done
[ "$_failed" -eq 0 ] || exit 1

_ok=1
```

### 4. Reassemble add-ons

Step 3 just overwrote `.claude/claudify.md` from the blueprint's base copy, which blanks the `## Add-ons` marker section — installed add-ons need re-injecting.

Read `.claude/claudify`. If it has an `addons:` line, for each `{name}` listed:
- Fetch `{SOURCE}/addons/{name}.yml` with `curl -fsSL` and parse it
- From its `files[]`, take only entries where `dest` starts with `.claude/commands/` or `.claude/hooks/` (doc files like `docs/TRANSCRIPTS.md` are user-owned — never re-fetched by update, same rule as blueprint docs)
- Re-fetch those command/hook files the same way as step 3 (always overwrite)
- Insert `- {context}` between the `<!-- claudify:addons:start -->` / `<!-- claudify:addons:end -->` markers in `.claude/claudify.md`, one bullet per add-on, in the order listed on the `addons:` line

If `.claude/claudify` has no `addons:` line, skip this step — nothing to reassemble.

### 5. Record the installed commit

If a `{sha}` argument was given, that is the resolved commit. Otherwise resolve the commit actually pulled from `main`:
```bash
SHA=$(curl -fsSL https://api.github.com/repos/konoerik/claudify/commits/main | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")
```
Read `.claude/claudify`, replace its `commit:` line with `commit: {sha}` (add the line if it doesn't have one yet), preserving the `blueprint:` and any `addons:` lines. Rewrite the whole file with Write.

### 6. Merge permissions

Merge `permissions.allow[]` into `.claude/settings.json` exactly as in init step 5: add missing entries only, create the file or the `allow` key if absent, preserve everything else, never touch `deny`. Do not run the `ask` wizard on update — new optional rules are only offered at init.

### 7. Report

Print a clean summary:
- **Updated:** each file re-fetched
- **Add-ons reassembled:** each add-on's command/hook files re-fetched and its rule re-injected (if any)
- **Permissions:** rules added (if any)
- **Commit:** the pinned commit SHA

Then print this note:

> **Note:** Restart Claude Code now so it picks up the updated commands and rules.
