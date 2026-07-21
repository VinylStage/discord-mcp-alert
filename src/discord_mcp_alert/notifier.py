import requests
from datetime import datetime, timezone
from discord_mcp_alert.config import DISCORD_WEBHOOK_URL

EVENT_COLORS = {
    "success":  0x57F287,  # 초록
    "error":    0xED4245,  # 빨강
    "warning":  0xFEE75C,  # 노랑
    "info":     0x5865F2,  # 파랑 (Discord Blurple)
    "start":    0x3498DB,  # 하늘
    "complete": 0x2ECC71,  # 밝은 초록
    "ask":      0xEB459E,  # 핑크 — 사용자 확인 요청
    "phase":    0x9B59B6,  # 보라 — Phase 보고
    "default":  0x95A5A6,  # 회색
}

EVENT_EMOJI = {
    "success":  "✅",
    "error":    "❌",
    "warning":  "⚠️",
    "info":     "ℹ️",
    "start":    "🚀",
    "complete": "🎉",
    "ask":      "❓",
    "phase":    "📋",
    "default":  "🔔",
}

# 한국어 기본 제목
EVENT_DEFAULT_TITLE = {
    "success":  "작업 성공",
    "error":    "오류 발생",
    "warning":  "주의 필요",
    "info":     "알림",
    "start":    "작업 시작",
    "complete": "완료",
    "ask":      "확인 요청",
    "phase":    "Phase 보고",
    "default":  "알림",
}

SOURCE_LABELS = {
    "claude_code":    "AXEL (Claude Code)",
    "claude_desktop": "Claude Desktop",
    "claude_app":     "Claude App",
    "claude_cowork":  "EVA (Claude Cowork)",
    "claude_vscode":  "Claude (VS Code)",
    "eva":            "EVA",
    "axel":           "AXEL",
    "nexus":          "NEXUS",
    "vance":          "VANCE",
    "forge":          "FORGE",
    "oracle":         "ORACLE",
}

CLAUDE_ICON = "https://storage.googleapis.com/public-assets-xg5/claude-logo.png"


def send_discord_notification(
    message: str,
    title: str = "",
    event_type: str = "default",
    source: str = "",
    project: str = "",
    fields: list | None = None,
) -> int:
    """
    Discord Embed 알림을 Webhook으로 전송합니다.

    Args:
        message:    알림 본문 텍스트.
        title:      임베드 제목 (생략 시 event_type 기반 한국어 자동 생성).
        event_type: success / error / warning / info / start / complete / ask / phase / default
        source:     발신 에이전트 (예: "eva", "axel", "claude_cowork").
        project:    프로젝트 이름 (footer에 표시, 예: "finance-tracker").
        fields:     추가 필드 목록 [{"name": str, "value": str, "inline": bool}].

    Returns:
        Discord HTTP 응답 상태 코드.
    """
    event_type = event_type.lower().strip() if event_type else "default"
    if event_type not in EVENT_COLORS:
        event_type = "default"

    color  = EVENT_COLORS[event_type]
    emoji  = EVENT_EMOJI[event_type]
    label  = SOURCE_LABELS.get(source, source) if source else "Claude"

    if not title:
        title = f"{emoji} {EVENT_DEFAULT_TITLE[event_type]}"
    else:
        title = f"{emoji} {title}"

    footer_parts = ["Discord MCP Alert"]
    if project:
        footer_parts.append(project)
    footer_text = "  •  ".join(footer_parts)

    embed = {
        "title":       title,
        "description": message,
        "color":       color,
        "author": {
            "name":     label,
            "icon_url": CLAUDE_ICON,
        },
        "footer": {
            "text":     footer_text,
            "icon_url": CLAUDE_ICON,
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
        "username":   f"Claude Alert{' | ' + project if project else ''}",
        "avatar_url": CLAUDE_ICON,
        "embeds":     [embed],
    }

    response = requests.post(DISCORD_WEBHOOK_URL, json=payload, timeout=10)
    response.raise_for_status()
    return response.status_code
