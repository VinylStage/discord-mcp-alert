#!/usr/bin/env python3
"""
Discord MCP Alert - Claude Code Hook (Cross-Platform)
Sends Discord notifications on Claude Code events (Stop, Notification, etc.)

Works on Windows, macOS, and Linux.
Requires: requests (pip install requests)

Configuration:
  Create ~/.claude/discord-webhook.conf with your Discord webhook URL:
  https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_TOKEN
"""

import json
import os
import sys
import tempfile
import time
from pathlib import Path

# --- Config ---
DEBOUNCE_SECONDS = 5

def get_webhook_url() -> str:
    config_file = Path.home() / ".claude" / "discord-webhook.conf"
    if not config_file.exists():
        sys.exit(0)
    url = config_file.read_text(encoding="utf-8").strip()
    if not url:
        sys.exit(0)
    return url

def parse_hook_input() -> dict:
    try:
        raw = sys.stdin.read()
        return json.loads(raw) if raw.strip() else {}
    except (json.JSONDecodeError, OSError):
        return {}

def try_acquire_lock(lock_dir: str) -> bool:
    """Atomic lock using mkdir. Returns True if lock acquired."""
    try:
        os.mkdir(lock_dir)
        return True
    except FileExistsError:
        return False

def is_debounced(timestamp_file: str) -> bool:
    """Returns True if within debounce window."""
    try:
        last = float(Path(timestamp_file).read_text(encoding="utf-8").strip())
        return (time.time() - last) < DEBOUNCE_SECONDS
    except (OSError, ValueError):
        return False

def update_timestamp(timestamp_file: str):
    Path(timestamp_file).write_text(str(time.time()), encoding="utf-8")

def build_message(hook_event: str, project_name: str, session_id: str) -> str:
    if hook_event == "Stop":
        return (
            f"✅ **Claude Code 작업 완료**\n\n"
            f"📁 프로젝트: `{project_name}`\n"
            f"🔑 세션: `{session_id}`\n\n"
            f"응답이 완료되었습니다."
        )
    elif hook_event == "Notification":
        return (
            f"🔔 **Claude Code 응답 대기**\n\n"
            f"📁 프로젝트: `{project_name}`\n"
            f"🔑 세션: `{session_id}`\n\n"
            f"사용자 입력이 필요합니다."
        )
    else:
        return f"📢 **Claude Code**: {hook_event}\n📁 프로젝트: `{project_name}`"

def send_discord(webhook_url: str, message: str):
    try:
        import requests
        requests.post(
            webhook_url,
            json={"content": message},
            timeout=10
        )
    except Exception:
        pass  # Hooks should not crash Claude Code

def main():
    webhook_url = get_webhook_url()

    data = parse_hook_input()
    hook_event = data.get("hook_event_name", "Unknown")
    session_id = str(data.get("session_id", "unknown"))[:8]
    cwd = data.get("cwd", "unknown")
    project_name = Path(cwd).name if cwd != "unknown" else "unknown"

    # Atomic lock per (session, event)
    tmp = tempfile.gettempdir()
    lock_dir = os.path.join(tmp, f"claude-discord-{session_id}-{hook_event}.lock")
    ts_file = os.path.join(tmp, f"claude-discord-{session_id}-{hook_event}.ts")

    if not try_acquire_lock(lock_dir):
        sys.exit(0)

    try:
        if is_debounced(ts_file):
            sys.exit(0)

        update_timestamp(ts_file)
        message = build_message(hook_event, project_name, session_id)
        send_discord(webhook_url, message)
    finally:
        try:
            os.rmdir(lock_dir)
        except OSError:
            pass

if __name__ == "__main__":
    main()
