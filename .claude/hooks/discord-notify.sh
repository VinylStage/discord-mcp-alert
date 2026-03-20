#!/bin/bash
# Claude Code Hook — Discord Embed Notification
# Fires on: Stop (task complete), Notification (awaiting input)
# Webhook URL source: ~/.claude/discord-webhook.conf

CONFIG_FILE="$HOME/.claude/discord-webhook.conf"
[ -f "$CONFIG_FILE" ] || exit 0
WEBHOOK_URL=$(tr -d '\n' < "$CONFIG_FILE")
[ -n "$WEBHOOK_URL" ] || exit 0

input=$(cat)
hook_event=$(echo "$input" | jq -r '.hook_event_name // "Unknown"')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"' | cut -c1-8)
cwd=$(echo "$input" | jq -r '.cwd // "unknown"')
project_name=$(basename "$cwd")

# Per-event debounce (5 seconds) using atomic mkdir lock
LOCK_DIR="/tmp/claude-discord-${session_id}-${hook_event}.lock"
mkdir "$LOCK_DIR" 2>/dev/null || exit 0
trap "rmdir '$LOCK_DIR' 2>/dev/null" EXIT

NOW=$(date +%s)
TS_FILE="/tmp/claude-discord-${session_id}-${hook_event}.ts"
if [ -f "$TS_FILE" ]; then
  LAST=$(cat "$TS_FILE" 2>/dev/null || echo 0)
  [ $((NOW - LAST)) -lt 5 ] && exit 0
fi
echo "$NOW" > "$TS_FILE"

# Event → Embed metadata
case "$hook_event" in
  "Stop")
    color=5763719      # 0x57F287 green
    emoji="✅"
    title="Claude Code 작업 완료"
    desc="응답이 완료되었습니다."
    ;;
  "Notification")
    color=16705372     # 0xFEE75C yellow
    emoji="🔔"
    title="Claude Code 응답 대기"
    desc="사용자 입력이 필요합니다."
    ;;
  "PreToolUse")
    color=3447003      # 0x3498DB light blue
    emoji="🚀"
    title="Claude Code 도구 사용 시작"
    tool=$(echo "$input" | jq -r '.tool_name // "Unknown"')
    desc="도구: \`$tool\`"
    ;;
  *)
    color=9807270      # 0x95A5A6 grey
    emoji="📢"
    title="Claude Code: $hook_event"
    desc=""
    ;;
esac

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

payload=$(jq -n \
  --arg username  "Claude Alert" \
  --arg title     "${emoji} ${title}" \
  --arg desc      "$desc" \
  --argjson color "$color" \
  --arg project   "$project_name" \
  --arg session   "$session_id" \
  --arg footer    "Discord MCP Alert  •  discord-mcp-alert" \
  --arg ts        "$timestamp" \
  '{
    username: $username,
    embeds: [{
      title:       $title,
      description: $desc,
      color:       $color,
      author: { name: "Claude Code (CLI)" },
      fields: [
        { name: "프로젝트", value: ("`" + $project + "`"), inline: true },
        { name: "세션 ID",  value: ("`" + $session + "`"), inline: true }
      ],
      footer:    { text: $footer },
      timestamp: $ts
    }]
  }')

curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$payload" > /dev/null

exit 0
