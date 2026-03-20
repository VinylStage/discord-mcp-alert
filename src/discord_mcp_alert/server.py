import sys
import os
from typing import Optional

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))

from mcp.server.fastmcp import FastMCP
from discord_mcp_alert.notifier import send_discord_notification

mcp = FastMCP("Discord Alert MCP")


@mcp.tool()
def notify_discord(
    message: str,
    title: str = "",
    event_type: str = "default",
    source: str = "",
) -> str:
    """
    Sends a rich Discord Embed notification to the configured channel via Webhook.

    Use this tool to report task completion, errors, warnings, or any important
    events from Claude Code, Claude Desktop, or Claude App to Discord.

    Args:
        message:    The main body text of the notification. Describe what happened.
        title:      Optional short headline for the embed (e.g. "Build Complete").
                    If omitted, a default title is generated from event_type.
        event_type: Severity / category of the event. Must be one of:
                      - "success"  → green  (task completed successfully)
                      - "error"    → red    (something went wrong)
                      - "warning"  → yellow (potential issue)
                      - "info"     → blue   (general information)
                      - "start"    → light blue (task starting)
                      - "complete" → bright green (workflow done)
                      - "default"  → grey   (uncategorized)
                    Defaults to "default".
        source:     Optional label for the notification origin.
                    Suggested values:
                      - "claude_code"    → Claude Code (CLI)
                      - "claude_desktop" → Claude Desktop
                      - "claude_app"     → Claude App
                      - "claude_cowork"  → Claude Cowork
                      - "claude_vscode"  → Claude (VS Code)

    Returns:
        A confirmation string on success, or an error description on failure.

    Examples:
        notify_discord("All 42 tests passed.", title="Tests Passed", event_type="success", source="claude_code")
        notify_discord("Database migration failed: timeout.", event_type="error", source="claude_code")
        notify_discord("Starting deployment to production.", event_type="start", source="claude_desktop")
        notify_discord("파일 정리 완료.", title="작업 완료", event_type="complete", source="claude_cowork")
    """
    try:
        send_discord_notification(
            message=message,
            title=title,
            event_type=event_type,
            source=source,
        )
        return f"[OK] Discord notification sent — event_type={event_type!r}, title={title!r}"
    except Exception as e:
        return f"[FAILED] Could not send Discord notification: {type(e).__name__}: {e}"


def main():
    """Entry point for the MCP server."""
    mcp.run()


if __name__ == "__main__":
    main()
