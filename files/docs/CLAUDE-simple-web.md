# CLAUDE.md

## Project Overview
<!-- One paragraph: what this app does and who it's for. -->

## Tech Stack
- **Languages:** HTML, CSS, vanilla JavaScript
- **Libraries:** <!-- e.g. Chart.js 4.x (CDN), Alpine.js 3.x (CDN) — list what you use -->
- **Build step:** None — CDN imports only

## Key Conventions
- Single page: `index.html`, `style.css`, `app.js`
- All dependencies loaded via CDN `<script>` tags — no npm, no bundler
- Keep `app.js` focused on behaviour; avoid inline scripts in HTML
- <!-- e.g. data loaded from data.json; DOM structure follows ... -->

## Development Workflow
```bash
# Open directly in browser (no local data files)
open index.html

# Serve locally (required if loading local JSON or using ES modules)
python3 -m http.server
```

## Operating Rules

### Environment
- There is no toolchain — never run `npm install`, create `package.json`, or add a bundler
- New libraries arrive only as version-pinned CDN `<script>` tags, and only after discussion
- Serve locally with `python3 -m http.server` when the page needs local files or ES modules

### Debugging
Reproduce the failure with exact steps in the browser, starting from a hard reload, and read the console and any failed requests in the Network tab before forming a hypothesis. Debug with DevTools — breakpoints, the Elements panel, sparing `console.log` — and `git diff`/`git log` if it used to work; never add a library to debug. Remove instrumentation once fixed. A fix is done when you have reloaded the page and watched the original repro steps succeed, not when the diff looks right.

## Behavior Rules
- No build step — if a library isn't available via CDN, discuss before adding a bundler
- When making a structural decision (adding a library, splitting into multiple pages), record it with `/log`
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
