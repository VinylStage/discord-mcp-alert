import os
from pathlib import Path
from dotenv import load_dotenv

# Get the project root directory (two levels up from this file)
# This file is in src/discord_mcp_alert/config.py
# Project root is two levels up
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

# Load .env from project root
dotenv_path = PROJECT_ROOT / ".env"
load_dotenv(dotenv_path=dotenv_path)

DISCORD_WEBHOOK_URL = os.getenv("DISCORD_WEBHOOK_URL")

if not DISCORD_WEBHOOK_URL:
    raise ValueError(
        f"DISCORD_WEBHOOK_URL is not set in the .env file.\n"
        f"Looking for .env at: {dotenv_path}\n"
        f"Current working directory: {os.getcwd()}"
    )
