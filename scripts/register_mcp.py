import json
import os
import sys
import shutil
from pathlib import Path

# Configuration
SERVER_NAME = "discord-alert"
PROJECT_ROOT = Path(__file__).resolve().parent.parent
POETRY_CMD = "poetry"  # Assuming poetry is in PATH
SRC_SERVER_PATH = PROJECT_ROOT / "src" / "server.py"

def get_claude_desktop_config_path():
    """Returns the path to the Claude Desktop config file."""
    if sys.platform == "darwin":  # macOS
        return Path.home() / "Library" / "Application Support" / "Claude" / "claude_desktop_config.json"
    elif sys.platform == "win32":  # Windows
        return Path.home() / "AppData" / "Roaming" / "Claude" / "claude_desktop_config.json"
    else: # Linux and others
        return Path.home() / ".config" / "Claude" / "claude_desktop_config.json"

def update_claude_desktop_config():
    config_path = get_claude_desktop_config_path()
    
    print(f"📂 Checking Claude Desktop config at: {config_path}")
    
    if not config_path.parent.exists():
        print(f"⚠️  Config directory does not exist. Creating: {config_path.parent}")
        config_path.parent.mkdir(parents=True, exist_ok=True)

    config = {}
    if config_path.exists():
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
        except json.JSONDecodeError:
            print("❌ Existing config file is invalid JSON. Creating a backup and starting fresh.")
            shutil.copy(config_path, str(config_path) + ".bak")
            config = {}

    mcp_servers = config.get("mcpServers", {})
    
    # Define the server config
    server_config = {
        "command": POETRY_CMD,
        "args": [
            "--directory",
            str(PROJECT_ROOT),
            "run",
            "python",
            str(SRC_SERVER_PATH)
        ],
        "cwd": str(PROJECT_ROOT),
        "env": {} # Environment variables are loaded from .env by python-dotenv inside the script, 
                  # but explicit env vars can be added here if needed.
    }

    mcp_servers[SERVER_NAME] = server_config
    config["mcpServers"] = mcp_servers

    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Successfully registered '{SERVER_NAME}' to Claude Desktop config!")

def print_claude_code_instruction():
    print("\n--- 🤖 Claude Code (CLI) Setup ---")
    print("To register this MCP server for Claude Code, run the following command in your terminal:")
    
    # Construct the command
    cmd = f"claude mcp add {SERVER_NAME} \"{POETRY_CMD} --directory {PROJECT_ROOT} run python {SRC_SERVER_PATH}\""
    
    print(f"\n   {cmd}\n")
    print("Note: This registers the server using the absolute path, so it will work from any directory.")

if __name__ == "__main__":
    print("🚀 Starting Discord MCP Alert Registration...")
    
    try:
        update_claude_desktop_config()
    except Exception as e:
        print(f"❌ Failed to update Claude Desktop config: {e}")
    
    print_claude_code_instruction()
    print("\n✨ Done!")
