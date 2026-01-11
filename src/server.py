import sys
import os

# Add the project root to sys.path to allow importing from src
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from mcp.server.fastmcp import FastMCP
from src.notifier import send_discord_notification

# Initialize the MCP server
mcp = FastMCP("Discord Alert MCP")

@mcp.tool()
def notify_discord(message: str) -> str:
    """
    Sends a notification message to the configured Discord channel via Webhook.
    
    Args:
        message: The text content of the notification to send.
        
    Returns:
        A success message indicating the notification was sent.
    """
    try:
        send_discord_notification(message)
        return f"Notification sent successfully: {message}"
    except Exception as e:
        return f"Failed to send notification: {str(e)}"

def main():
    """Entry point for the MCP server."""
    mcp.run()

if __name__ == "__main__":
    main()
