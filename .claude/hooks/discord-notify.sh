#!/bin/bash
set -e

# Discord Webhook URL
WEBHOOK_URL="https://discord.com/api/webhooks/1446163806886826085/i7Lx7TCMoHFrZHJ4Y6sOcXMHh9H7yucgo_NgobBL_GyPJY2lE49NwP_IcCBaP6-lJwNz"

# Read hook input from stdin
input=$(cat)

# Extract event info
hook_event=$(echo "$input" | jq -r '.hook_event_name // "Unknown"')

# Build message based on event type
case "$hook_event" in
  "Stop")
    message="✅ **Claude Code 작업 완료**\n\n응답이 완료되었습니다. 확인해주세요."
    ;;
  "Notification")
    message="🔔 **Claude Code 알림**\n\n사용자 입력이 필요합니다."
    ;;
  *)
    message="📢 **Claude Code**: $hook_event"
    ;;
esac

# Send to Discord
curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"$message\"}" > /dev/null

exit 0
