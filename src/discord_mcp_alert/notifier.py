import requests
from datetime import datetime, timezone
from discord_mcp_alert.config import DISCORD_WEBHOOK_URL

EVENT_COLORS = {
    "success":  0x57F287,
    "error":    0xED4245,
    "warning":  0xFEE75C,
    "info":     0x5865F2,
    "start":    0x3498DB,
    "complete": 0x2ECC71,
    "default":  0x95A5A6,
}

EVENT_EMOJI = {
    "success":  "✅",
    "error":    "❌",
    "warning":  "⚠️",
    "info":     "ℹ️",
    "start":    "🚀",
    "complete": "🎉",
    "default":  "🔔",
}

SOURCE_LABELS = {
    "claude_code":    "Claude Code (CLI)",
    "claude_desktop": "Claude Desktop",
    "claude_app":     "Claude App",
    "claude_cowork":  "Claude Cowork",
    "claude_vscode":  "Claude (VS Code)",
}


def send_discord_notification(
    message: str,
    title: str = "",
    event_type: str = "default",
    source: str = "",
    fields: list | None = None,
) -> int:
    """
    Sends a rich Discord Embed notification via Webhook.

    Args:
        message:    Body text of the notification.
        title:      Optional embed title (auto-generated from event_type if omitted).
        event_type: One of success / error / warning / info / start / complete / default.
        source:     Optional source tag (e.g. "claude_code", "claude_desktop").
        fields:     Optional list of {"name": str, "value": str, "inline": bool} dicts.

    Returns:
        HTTP status code from Discord.

    Raises:
        requests.exceptions.RequestException: on network / HTTP error.
        ValueError: if DISCORD_WEBHOOK_URL is not set.
    """
    event_type = event_type.lower().strip() if event_type else "default"
    if event_type not in EVENT_COLORS:
        event_type = "default"

    color  = EVENT_COLORS[event_type]
    emoji  = EVENT_EMOJI[event_type]
    label  = SOURCE_LABELS.get(source, source) if source else "Claude"

    if not title:
        title = f"{emoji} {event_type.capitalize()} Notification"
    else:
        title = f"{emoji} {title}"

    embed = {
        "title":       title,
        "description": message,
        "color":       color,
        "author": {
            "name":     label,
            "icon_url": "https://storage.googleapis.com/public-assets-xg5/claude-logo.png",
        },
        "footer": {
            "text": "Discord MCP Alert  •  discord-mcp-alert",
        },
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }

    if fields:
        embed["fields"] = [
            {
                "name":   str(f.get("name", "")),
                "value":  str(f.get("value", "")),
                "inline": bool(f.get("inline", False)),
            }
            for f in fields
        ]

    payload = {
        "username":   "Claude Alert",
        "avatar_url": "https://storage.googleapis.com/public-assets-xg5/claude-logo.png",
        "embeds":     [embed],
    }

    response = requests.post(DISCORD_WEBHOOK_URL, json=payload, timeout=10)
    response.raise_for_status()
    return response.status_code
