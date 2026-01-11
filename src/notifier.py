import requests
from src.config import DISCORD_WEBHOOK_URL

def send_discord_notification(content: str):
    """
    Sends a message to the configured Discord Webhook URL.
    
    Args:
        content (str): The message text to send.
    
    Raises:
        requests.exceptions.RequestException: If the request fails.
    """
    payload = {
        "content": content
    }
    
    response = requests.post(DISCORD_WEBHOOK_URL, json=payload)
    response.raise_for_status()
    
    return response.status_code
