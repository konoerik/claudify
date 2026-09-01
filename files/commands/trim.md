Free up context in the current session without a full `/clear` — for when there's still undistilled reasoning worth keeping, but stale tool output has piled up.

1. Run `python3 .claude/scripts/trim_scan.py`. It auto-detects the current session's transcript and ranks its heaviest lines into two buckets: binary/disposable reads (screenshots, PDFs — already served their purpose, can only be deleted, not summarized) and verbose text tool output (logs, long command output — can be summarized instead of dropped entirely).

   If the result looks wrong (e.g. you know another session is more active), re-run with `--path` pointing at the right `.jsonl` under `~/.claude/projects/`.

2. Present both buckets to me as a short numbered list — size, originating tool, and enough of the detail to identify what it was for. Do not dump the raw tool output itself.

3. Ask me which entries to discard outright (binary bucket) and which to summarize rather than drop (text bucket) — I may say "all", "none", or pick specific ones.

4. Based on my answer, compose a single precise instruction naming exactly what to drop and what to compress, and tell me to run:
   `/compact <your composed instructions>`

   Do not attempt to run `/compact` yourself — there is no tool available for that; this command's job ends at producing the instruction.
