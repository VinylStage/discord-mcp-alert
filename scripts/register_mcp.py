import json
import os
import shutil
import sys
from pathlib import Path

SERVER_NAME = "discord-alert"
PROJECT_ROOT = Path(__file__).resolve().parent.parent
VENV_DIR = PROJECT_ROOT / ".venv"


def get_claude_desktop_config_path() -> Path:
    """Returns the Claude Desktop config file path for the current OS."""
    if sys.platform == "darwin":
        return (
            Path.home() / "Library" / "Application Support" / "Claude"
            / "claude_desktop_config.json"
        )
    if sys.platform == "win32":
        appdata = os.environ.get("APPDATA") or str(Path.home() / "AppData" / "Roaming")
        return Path(appdata) / "Claude" / "claude_desktop_config.json"
    return Path.home() / ".config" / "Claude" / "claude_desktop_config.json"


def detect_package_manager() -> str:
    """Returns 'pip' if .venv exists (pip install -e . was used), 'poetry' otherwise."""
    if VENV_DIR.exists():
        return "pip"
    if shutil.which("poetry"):
        return "poetry"
    return "poetry"  # default; will fail later if not installed


def update_claude_desktop_config() -> None:
    config_path = get_claude_desktop_config_path()
    print(f"Checking Claude Desktop config at: {config_path}")

    if not config_path.parent.exists():
        print(f"Config directory does not exist. Creating: {config_path.parent}")
        config_path.parent.mkdir(parents=True, exist_ok=True)

    config: dict = {}
    if config_path.exists():
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
        except json.JSONDecodeError:
            print("Existing config file is invalid JSON. Creating a backup and starting fresh.")
            shutil.copy(config_path, str(config_path) + ".bak")
            config = {}

    pkg_mgr = detect_package_manager()

    if pkg_mgr == "poetry":
        server_config = {
            "command": "poetry",
            "args": [
                "--directory", str(PROJECT_ROOT),
                "run", "python", "-m", "discord_mcp_alert.server",
            ],
        }
    else:
        # pip + virtual environment
        if sys.platform == "win32":
            python_exe = str(VENV_DIR / "Scripts" / "python.exe")
        else:
            python_exe = str(VENV_DIR / "bin" / "python")
        server_config = {
            "command": python_exe,
            "args": ["-m", "discord_mcp_alert.server"],
        }

    mcp_servers = config.setdefault("mcpServers", {})
    mcp_servers[SERVER_NAME] = server_config

    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)

    print(f"Successfully registered '{SERVER_NAME}' to Claude Desktop config!")
    print(f"Mode: {pkg_mgr}")


def print_claude_code_instruction() -> None:
    pkg_mgr = detect_package_manager()

    print("\n--- Claude Code (CLI) Setup ---")
    print("Run the following command to register this MCP server globally:\n")

    if pkg_mgr == "poetry":
        cmd = (
            f'claude mcp add --scope user {SERVER_NAME} -- '
            f'poetry --directory "{PROJECT_ROOT}" run python -m discord_mcp_alert.server'
        )
        print(f"  [Poetry]  {cmd}")
    else:
        if sys.platform == "win32":
            python_exe = str(VENV_DIR / "Scripts" / "python.exe")
        else:
            python_exe = str(VENV_DIR / "bin" / "python")
        cmd = (
            f'claude mcp add --scope user {SERVER_NAME} -- '
            f'"{python_exe}" -m discord_mcp_alert.server'
        )
        print(f"  [pip/venv] {cmd}")

    print()
    print("Note: --scope user makes the server available in ALL projects globally.")

    if sys.platform == "win32":
        print("\n  Windows (Poetry): Run .\\register_claude_cli.ps1 for automated setup.")
    else:
        print("\n  Mac/Linux (Poetry): Run ./register_claude_cli.sh for automated setup.")


if __name__ == "__main__":
    print("Starting Discord MCP Alert Registration...")

    try:
        update_claude_desktop_config()
    except Exception as e:
        print(f"Failed to update Claude Desktop config: {e}")

    print_claude_code_instruction()
    print("\nDone!")
