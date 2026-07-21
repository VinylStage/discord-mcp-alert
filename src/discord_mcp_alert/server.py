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
    project: str = "",
    fields: list | None = None,
) -> str:
    """
    Discord 채널로 Rich Embed 알림을 전송합니다.

    작업 완료 보고, 오류 알림, Phase 진행 상황, 사용자 확인 요청 등 모든 중요 이벤트에 사용하세요.

    Args:
        message:    알림 본문 텍스트. 무슨 일이 일어났는지 설명하세요.
        title:      임베드 제목 (생략 시 event_type 기반 한국어 제목 자동 생성).
        event_type: 이벤트 유형. 다음 중 하나:
                      - "success"  → 초록  (작업 성공)
                      - "error"    → 빨강  (오류 발생)
                      - "warning"  → 노랑  (주의 필요)
                      - "info"     → 파랑  (일반 정보)
                      - "start"    → 하늘  (작업 시작)
                      - "complete" → 밝은 초록 (전체 완료)
                      - "ask"      → 핑크  (사용자 확인 요청)
                      - "phase"    → 보라  (Phase 진행 보고)
                      - "default"  → 회색  (기타)
        source:     발신 에이전트 레이블. 권장값:
                      - "eva"            → EVA (Claude Cowork 오케스트레이터)
                      - "axel"           → AXEL (Claude Code 실행)
                      - "claude_cowork"  → EVA (Claude Cowork)
                      - "claude_code"    → AXEL (Claude Code CLI)
                      - "nexus"          → NEXUS (설계/기획)
                      - "vance"          → VANCE (로컬 LLM)
                      - "forge"          → FORGE (코드 특화 LLM)
                      - "oracle"         → ORACLE (심층 추론 LLM)
        project:    프로젝트 이름 (footer에 표시, 예: "finance-tracker").
        fields:     추가 필드 목록. 각 항목: {"name": str, "value": str, "inline": bool}.
                    inline=True 이면 최대 3개까지 한 줄에 표시됩니다.

    Returns:
        성공 시 확인 문자열, 실패 시 오류 설명.

    사용 예시:
        # Phase 완료 보고
        notify_discord(
            "Phase 2 할부/리볼빙/부채 화면 구현 완료.",
            title="Phase 2 완료",
            event_type="phase",
            source="axel",
            project="finance-tracker",
            fields=[
                {"name": "커밋", "value": "feat(phase2): ...", "inline": True},
                {"name": "다음 단계", "value": "Phase 3 카테고리 자동제안", "inline": True},
            ]
        )
        # 사용자 확인 요청
        notify_discord(
            "아키텍처 변경이 필요합니다. 승인해주세요.",
            title="컨펌 요청",
            event_type="ask",
            source="eva",
            project="finance-tracker",
        )
        # 오류 보고
        notify_discord("마이그레이션 실패: timeout.", event_type="error", source="axel", project="finance-tracker")
    """
    try:
        send_discord_notification(
            message=message,
            title=title,
            event_type=event_type,
            source=source,
            project=project,
            fields=fields,
        )
        return f"[OK] Discord 알림 전송 완료 — event_type={event_type!r}, title={title!r}"
    except Exception as e:
        return f"[FAILED] Discord 알림 전송 실패: {type(e).__name__}: {e}"


def main():
    """Entry point for the MCP server."""
    mcp.run()


if __name__ == "__main__":
    main()
