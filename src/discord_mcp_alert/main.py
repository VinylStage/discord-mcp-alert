import sys
from discord_mcp_alert.notifier import send_discord_notification

def main():
    print("Sending test notification to Discord...")
    try:
        send_discord_notification(
            message="Hello! This is a test notification from the Discord MCP Alert server.\nIf you see this embed, the integration is working correctly.",
            title="MCP Alert — Setup Test",
            event_type="success",
            source="claude_code",
        )
        print("✅ Notification sent successfully!")
    except Exception as e:
        print(f"❌ Failed to send notification: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
