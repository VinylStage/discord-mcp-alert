#!/bin/bash

# Discord Webhook URL
WEBHOOK_URL="https://discord.com/api/webhooks/1446163806886826085/i7Lx7TCMoHFrZHJ4Y6sOcXMHh9H7yucgo_NgobBL_GyPJY2lE49NwP_IcCBaP6-lJwNz"

# Read hook input from stdin
input=$(cat)

# Extract event info
session_id=$(echo "$input" | jq -r '.session_id // "unknown"' | cut -c1-8)
cwd=$(echo "$input" | jq -r '.cwd // "unknown"')
project_name=$(basename "$cwd")

# Atomic lock with flock - only first caller proceeds
LOCK_FILE="/tmp/claude-discord-${session_id}.lock"
exec 200>"$LOCK_FILE"
flock -n 200 || exit 0

# Check timestamp for debounce (5 seconds)
NOW=$(date +%s)
TIMESTAMP_FILE="/tmp/claude-discord-${session_id}.ts"
if [ -f "$TIMESTAMP_FILE" ]; then
  LAST=$(cat "$TIMESTAMP_FILE" 2>/dev/null || echo 0)
  DIFF=$((NOW - LAST))
  if [ "$DIFF" -lt 5 ]; then
    exit 0
  fi
fi
echo "$NOW" > "$TIMESTAMP_FILE"

# Build message
message="✅ **Claude Code 작업 완료**\n\n📁 프로젝트: \`$project_name\`\n🔑 세션: \`$session_id\`\n\n응답이 완료되었습니다."

# Send to Discord
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"$message\"}" > /dev/null

exit 0
