# Context
<!-- Auto-maintained by the stop hook. Edit manually if needed, but keep it short. -->

**Current focus:** Organic validation; blueprint family growing steadily
**Last session:** Shipped blueprint `permissions` section (ADR-8) and per-template `## Operating Rules` — uv/venv mandate + 5-step debugging methodology (ADR-9); e2e-verified init incl. settings merge, skip, and failure paths; 92 tests passing. This session: atomic installer downloads + `--retry 3` in both templates, recorded as ADR-10
**Blocking:** Both features uncommitted; runner fix (ADR-7) still unverified on Linux/WSL — `bug-report-claudify-exit.md` stays local until then
**Next action:** Commit and push permissions + operating rules; then verify the runner on Linux/WSL and delete the bug report
<!-- wrapped: 2026-07-16 -->
