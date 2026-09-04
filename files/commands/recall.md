Check whether a topic was already investigated in a past session on this project, before redoing the work.

The argument is the topic to search for (a keyword or short phrase). If none is given, ask for one.

1. Run `python3 .claude/scripts/session_index.py build` to refresh the index — this is incremental and skips unchanged sessions, so it's cheap even on a long project history.
2. Run `python3 .claude/scripts/session_index.py query "{topic}"`.
3. If there are matches, present them as a short list (date, session, one-line asked/found) and ask which one to pull in, or whether to proceed with a fresh investigation anyway. Do not paste the full raw finding unprompted — the one-line summary is enough to decide.
4. On selection, use that entry's "found" text as the answer, or as the starting point if it only partially covers the current question. Note explicitly that it came from a prior session (with its date) rather than presenting it as newly derived.
5. If there are no matches, say so and proceed with a fresh investigation as normal.
