Ingest a meeting transcript: archive the raw text, index a summary in docs/TRANSCRIPTS.md.

The argument is a path to a transcript file; transcript text may also be pasted directly. If neither is present, ask for one.

1. Read the transcript.
2. Save the raw text to `transcripts/raw/YYYY-MM-DD-{slug}.md` — the meeting date if stated in the transcript, otherwise today; slug from the meeting topic. Never edit a raw file after saving. If the source was a user file outside `transcripts/raw/`, leave the original untouched.
3. Extract: participants, decisions made, action items (with owners), open questions.
4. If `docs/PEOPLE.md` exists, cross-check participants against it and add anyone new (name plus role, if stated).
5. Update `docs/TRANSCRIPTS.md`:
   - Add a row to `## Index` (newest first): date, meeting title, participants, relative link to the raw file
   - Add a section under `## Summaries` (newest first): `### YYYY-MM-DD — Title` with **Decisions**, **Action items**, **Open questions**
   - Refresh `## Quick Reference` only if a standing fact changed — a recurring decision, an active thread, an ownership change
6. Report: the raw file path, and the decisions and action items found. Do not quote the full transcript back.
