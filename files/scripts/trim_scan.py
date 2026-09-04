#!/usr/bin/env python3
"""Rank the current Claude Code session's transcript by byte size, resolving
tool_result blocks back to the tool call that produced them. No LLM calls —
pure local analysis, meant to be read by Claude and turned into a precise
/compact instruction. See .claude/commands/trim.md for the workflow this
supports.

Usage:
  python3 trim_scan.py [--top N] [--path SESSION.jsonl]

With no --path, auto-detects the most recently modified session transcript
for the current project under ~/.claude/projects/<project-dir>/. That
heuristic can be wrong (e.g. multiple sessions active at once) — pass
--path explicitly if the result looks off.
"""
import argparse
import json
import sys
from pathlib import Path

IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg", ".pdf", ".bmp"}


def project_sessions_dir():
    project_key = str(Path.cwd()).replace("/", "-")
    return Path.home() / ".claude" / "projects" / project_key


def find_current_session(sessions_dir):
    candidates = sorted(
        sessions_dir.glob("*.jsonl"), key=lambda p: p.stat().st_mtime, reverse=True
    )
    return candidates[0] if candidates else None


def content_blocks(message):
    if not isinstance(message, dict):
        return []
    content = message.get("content")
    if isinstance(content, str):
        return [{"type": "text", "text": content}]
    if isinstance(content, list):
        return [b for b in content if isinstance(b, dict)]
    return []


def is_image_read(tool_name, tool_input):
    if tool_name != "Read":
        return False
    file_path = (tool_input or {}).get("file_path", "")
    return Path(file_path).suffix.lower() in IMAGE_EXTENSIONS


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--top", type=int, default=10, help="entries per bucket")
    parser.add_argument("--path", type=str, default=None, help="explicit session .jsonl path")
    args = parser.parse_args()

    if args.path:
        session_path = Path(args.path)
    else:
        sessions_dir = project_sessions_dir()
        session_path = find_current_session(sessions_dir)
        if session_path is None:
            print(f"No session transcripts found under {sessions_dir}", file=sys.stderr)
            sys.exit(1)

    if not session_path.exists():
        print(f"Session file not found: {session_path}", file=sys.stderr)
        sys.exit(1)

    with open(session_path) as f:
        raw_lines = f.readlines()

    events = []
    for line in raw_lines:
        line = line.strip()
        if not line:
            events.append(None)
            continue
        try:
            events.append(json.loads(line))
        except json.JSONDecodeError:
            events.append(None)

    tool_use_index = {}
    for ev in events:
        if ev is None:
            continue
        for block in content_blocks(ev.get("message")):
            if block.get("type") == "tool_use":
                tool_use_index[block.get("id")] = (block.get("name"), block.get("input", {}))

    sizes = []
    for i, (line, ev) in enumerate(zip(raw_lines, events)):
        if ev is None or not line.strip():
            continue
        sizes.append((len(line.encode("utf-8")), i))

    total = sum(s for s, _ in sizes)

    binary_bucket = []
    text_bucket = []
    for size, idx in sizes:
        ev = events[idx]
        for block in content_blocks(ev.get("message")):
            if block.get("type") != "tool_result":
                continue
            name, tool_input = tool_use_index.get(block.get("tool_use_id"), (None, {}))
            entry = {
                "size": size,
                "line": idx,
                "tool": name or "?",
                "detail": json.dumps(tool_input)[:100] if tool_input else "",
            }
            if is_image_read(name, tool_input):
                binary_bucket.append(entry)
            else:
                text_bucket.append(entry)
            break

    binary_bucket.sort(key=lambda e: e["size"], reverse=True)
    text_bucket.sort(key=lambda e: e["size"], reverse=True)

    print(f"Session: {session_path}")
    print(f"Total size: {total:,} bytes across {len(sizes)} lines\n")

    print(f"-- Binary/disposable reads (pure delete candidates, top {args.top}) --")
    if not binary_bucket:
        print("  (none)")
    for e in binary_bucket[: args.top]:
        print(f"  {e['size']:>9,} bytes  line {e['line']:>4}  {e['tool']}  {e['detail']}")

    print(f"\n-- Verbose text tool output (summarize candidates, top {args.top}) --")
    if not text_bucket:
        print("  (none)")
    for e in text_bucket[: args.top]:
        print(f"  {e['size']:>9,} bytes  line {e['line']:>4}  {e['tool']}  {e['detail']}")


if __name__ == "__main__":
    main()
