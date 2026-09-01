#!/usr/bin/env python3
"""Build and query a local index of past Claude Code sessions for this
project, so /recall can surface prior investigations instead of redoing
them. Pure local analysis, no LLM calls to build the index.

Index unit is either a forked-subagent branch (description -> its final
output) when one exists, or — for sessions that never forked — a cruder
fallback pairing each user message with the assistant's last reply before
the next one. See .claude/commands/recall.md for the workflow.

Usage:
  python3 session_index.py build
  python3 session_index.py query "some topic"
"""
import json
import sys
from pathlib import Path

INDEX_PATH = Path(".claude/session-index.json")
MAX_SNIPPET = 200


def project_sessions_dir():
    project_key = str(Path.cwd()).replace("/", "-")
    return Path.home() / ".claude" / "projects" / project_key


def read_jsonl(path):
    events = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return events


def content_blocks(message):
    if not isinstance(message, dict):
        return []
    content = message.get("content")
    if isinstance(content, str):
        return [{"type": "text", "text": content}]
    if isinstance(content, list):
        return [b for b in content if isinstance(b, dict)]
    return []


def extract_text(message):
    return "\n".join(
        b.get("text", "") for b in content_blocks(message) if b.get("type") == "text"
    ).strip()


def truncate(s, n=MAX_SNIPPET):
    s = " ".join(s.split())
    return s if len(s) <= n else s[: n - 1] + "…"


def is_local_command_noise(text):
    return "<command-name>" in text or "<local-command-caveat>" in text


def last_assistant_text(events):
    for ev in reversed(events):
        if ev.get("type") == "assistant":
            text = extract_text(ev.get("message"))
            if text:
                return text
    return ""


def session_title(events):
    titles = [ev.get("aiTitle") for ev in events if ev.get("type") == "ai-title"]
    return titles[-1] if titles else None


def session_started(events):
    for ev in events:
        if ev.get("timestamp"):
            return ev["timestamp"]
    return None


def fork_nodes(jsonl_path):
    sidecar_dir = jsonl_path.parent / jsonl_path.stem / "subagents"
    nodes = []
    if not sidecar_dir.is_dir():
        return nodes
    for meta_path in sorted(sidecar_dir.glob("*.meta.json")):
        agent_id = meta_path.stem.replace(".meta", "")
        try:
            meta = json.loads(meta_path.read_text())
        except json.JSONDecodeError:
            meta = {}
        child_jsonl = sidecar_dir / f"{agent_id}.jsonl"
        outcome = ""
        if child_jsonl.exists():
            outcome = last_assistant_text(read_jsonl(child_jsonl))
        nodes.append(
            {
                "type": "fork",
                "asked": meta.get("description", "(no description)"),
                "found": truncate(outcome) if outcome else "(no outcome captured)",
            }
        )
    return nodes


def turn_fallback_nodes(events):
    """Crude fallback for sessions with no fork branches: pair each user
    message with the assistant's last reply before the next user turn."""
    nodes = []
    pending_user = None
    last_assistant = None
    for ev in events:
        t = ev.get("type")
        if t == "user" and not ev.get("isMeta"):
            text = extract_text(ev.get("message"))
            if not text or is_local_command_noise(text):
                continue
            if pending_user is not None:
                nodes.append(
                    {
                        "type": "turn",
                        "asked": truncate(pending_user),
                        "found": truncate(last_assistant) if last_assistant else "(no reply captured)",
                    }
                )
            pending_user = text
            last_assistant = None
        elif t == "assistant":
            text = extract_text(ev.get("message"))
            if text:
                last_assistant = text
    if pending_user is not None:
        nodes.append(
            {
                "type": "turn",
                "asked": truncate(pending_user),
                "found": truncate(last_assistant) if last_assistant else "(no reply captured)",
            }
        )
    return nodes


def index_session(jsonl_path):
    events = read_jsonl(jsonl_path)
    nodes = fork_nodes(jsonl_path)
    if not nodes:
        nodes = turn_fallback_nodes(events)
    return {
        "title": session_title(events),
        "started": session_started(events),
        "nodes": nodes,
    }


def build(sessions_dir):
    INDEX_PATH.parent.mkdir(parents=True, exist_ok=True)
    existing = {}
    if INDEX_PATH.exists():
        try:
            existing = json.loads(INDEX_PATH.read_text()).get("sessions", {})
        except json.JSONDecodeError:
            existing = {}

    updated = {}
    scanned = 0
    skipped = 0
    for jsonl_path in sorted(sessions_dir.glob("*.jsonl")):
        session_id = jsonl_path.stem
        stat = jsonl_path.stat()
        fingerprint = f"{stat.st_mtime_ns}:{stat.st_size}"
        prior = existing.get(session_id)
        if prior and prior.get("fingerprint") == fingerprint:
            updated[session_id] = prior
            skipped += 1
            continue
        entry = index_session(jsonl_path)
        entry["fingerprint"] = fingerprint
        updated[session_id] = entry
        scanned += 1

    INDEX_PATH.write_text(json.dumps({"sessions": updated}, indent=2))
    print(f"Indexed {scanned} session(s), {skipped} unchanged, {len(updated)} total -> {INDEX_PATH}")


def query(term):
    if not INDEX_PATH.exists():
        print("No index yet — run `build` first.", file=sys.stderr)
        sys.exit(1)
    data = json.loads(INDEX_PATH.read_text())
    term_lower = term.lower()
    matches = []
    for session_id, entry in data.get("sessions", {}).items():
        for node in entry.get("nodes", []):
            haystack = f"{node.get('asked','')} {node.get('found','')} {entry.get('title') or ''}".lower()
            if term_lower in haystack:
                matches.append((entry.get("started") or "", session_id, entry.get("title"), node))

    matches.sort(key=lambda m: m[0], reverse=True)
    if not matches:
        print(f"No matches for '{term}'.")
        return
    for started, session_id, title, node in matches:
        print(f"\n[{started}] session {session_id[:8]} — {title or '(untitled)'}")
        print(f"  asked: {node['asked']}")
        print(f"  found: {node['found']}")


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in ("build", "query"):
        print(__doc__)
        sys.exit(1)

    if sys.argv[1] == "build":
        build(project_sessions_dir())
    else:
        if len(sys.argv) < 3:
            print("query requires a search term", file=sys.stderr)
            sys.exit(1)
        query(" ".join(sys.argv[2:]))


if __name__ == "__main__":
    main()
