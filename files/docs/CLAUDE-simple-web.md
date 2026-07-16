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
Work this sequence — do not improvise tooling:
1. **Reproduce** — exact steps in the browser that show the failure, starting from a hard reload
2. **Read the console first** — errors and failed requests (Network tab) before forming a hypothesis
3. **Isolate** — DevTools breakpoints and the Elements panel; `git diff`/`git log` if it used to work
4. **Instrument** — sparing `console.log`; remove instrumentation once fixed
5. **Never add a library to debug** — existing DevTools only

## Behavior Rules
- No build step — if a library isn't available via CDN, discuss before adding a bundler
- When making a structural decision (adding a library, splitting into multiple pages), record it with `/log`
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
