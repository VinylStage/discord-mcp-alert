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

if __name__ == "__main__":
    mcp.run()
