#!/bin/bash

# Load webhook URL from config file
CONFIG_FILE="$HOME/.claude/discord-webhook.conf"
if [ ! -f "$CONFIG_FILE" ]; then
  exit 0
fi
WEBHOOK_URL=$(cat "$CONFIG_FILE" | tr -d '\n')

if [ -z "$WEBHOOK_URL" ]; then
  exit 0
fi

# Read hook input from stdin
input=$(cat)

# Extract event info
hook_event=$(echo "$input" | jq -r '.hook_event_name // "Unknown"')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"' | cut -c1-8)
cwd=$(echo "$input" | jq -r '.cwd // "unknown"')
project_name=$(basename "$cwd")

# macOS compatible atomic lock using mkdir (per event type)
LOCK_DIR="/tmp/claude-discord-${session_id}-${hook_event}.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi
trap "rmdir '$LOCK_DIR' 2>/dev/null" EXIT

# Check timestamp for debounce (5 seconds, per event type)
NOW=$(date +%s)
TIMESTAMP_FILE="/tmp/claude-discord-${session_id}-${hook_event}.ts"
if [ -f "$TIMESTAMP_FILE" ]; then
  LAST=$(cat "$TIMESTAMP_FILE" 2>/dev/null || echo 0)
  DIFF=$((NOW - LAST))
  if [ "$DIFF" -lt 5 ]; then
    exit 0
  fi
fi
echo "$NOW" > "$TIMESTAMP_FILE"

# Build message based on event type
case "$hook_event" in
  "Stop")
    message="✅ **Claude Code 작업 완료**\n\n📁 프로젝트: \`$project_name\`\n🔑 세션: \`$session_id\`\n\n응답이 완료되었습니다."
    ;;
  "Notification")
    message="🔔 **Claude Code 응답 대기**\n\n📁 프로젝트: \`$project_name\`\n🔑 세션: \`$session_id\`\n\n사용자 입력이 필요합니다."
    ;;
  *)
    message="📢 **Claude Code**: $hook_event\n📁 프로젝트: \`$project_name\`"
    ;;
esac

# Send to Discord
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"$message\"}" > /dev/null

exit 0
