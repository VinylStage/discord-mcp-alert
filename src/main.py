import sys
from src.notifier import send_discord_notification

def main():
    print("Sending test notification to Discord...")
    try:
        send_discord_notification("🔔 Hello! This is a test notification from the MCP Alert System.")
        print("✅ Notification sent successfully!")
    except Exception as e:
        print(f"❌ Failed to send notification: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
