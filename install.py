#!/usr/bin/env python3
"""
Discord MCP Alert - Cross-Platform Setup
Supports Windows, macOS, and Linux. Requires Python 3.10+

Usage:
    python install.py
"""
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
VENV_DIR = SCRIPT_DIR / ".venv"
TOTAL_STEPS = 6


def step(n: int, msg: str) -> None:
    print(f"\n[{n}/{TOTAL_STEPS}] {msg}")


def ok(msg: str) -> None:
    print(f"  OK {msg}")


def warn(msg: str) -> None:
    print(f"  Warning: {msg}")


def fail(msg: str) -> None:
    print(f"\nError: {msg}", file=sys.stderr)
    sys.exit(1)


# ── 1. Environment check ──────────────────────────────────────────────────────

def check_python() -> None:
    if sys.version_info < (3, 10):
        fail(
            f"Python 3.10+ is required.\n"
            f"  Current version: {sys.version.split()[0]}\n"
            f"  Download: https://www.python.org/downloads/"
        )
    ok(f"Python {sys.version.split()[0]}")


def detect_package_manager() -> str:
    """Returns 'poetry' if poetry is in PATH, otherwise 'pip'."""
    if shutil.which("poetry"):
        return "poetry"
    return "pip"


def get_python_cmd(pkg_mgr: str) -> list:
    """Returns the prefix command list to run a Python module."""
    if pkg_mgr == "poetry":
        return ["poetry", "run", "python"]
    if sys.platform == "win32":
        py = VENV_DIR / "Scripts" / "python.exe"
    else:
        py = VENV_DIR / "bin" / "python"
    return [str(py)]


# ── 2. Install dependencies ───────────────────────────────────────────────────

def install_deps(pkg_mgr: str) -> None:
    if pkg_mgr == "poetry":
        result = subprocess.run(["poetry", "install"], cwd=SCRIPT_DIR)
        if result.returncode != 0:
            fail(
                "'poetry install' failed.\n"
                "  Make sure Poetry is properly installed and available in your PATH.\n"
                "  Install Poetry: https://python-poetry.org/docs/#installation"
            )
    else:
        # pip + virtual environment (editable install)
        print(f"  Creating virtual environment at .venv ...")
        result = subprocess.run([sys.executable, "-m", "venv", str(VENV_DIR)])
        if result.returncode != 0:
            fail(
                "Failed to create virtual environment.\n"
                "  Check that the 'venv' module is available: python -m venv --help"
            )
        pip = (
            VENV_DIR / "Scripts" / "pip.exe"
            if sys.platform == "win32"
            else VENV_DIR / "bin" / "pip"
        )
        result = subprocess.run([str(pip), "install", "-e", "."], cwd=SCRIPT_DIR)
        if result.returncode != 0:
            fail(
                "'pip install -e .' failed.\n"
                "  Try upgrading pip: python -m pip install --upgrade pip"
            )
    ok("Dependencies installed")


# ── 3. Configure .env ─────────────────────────────────────────────────────────

def setup_env() -> None:
    env_path = SCRIPT_DIR / ".env"
    if env_path.exists():
        answer = input("  .env file already exists. Reconfigure it? (y/N): ").strip().lower()
        if answer != "y":
            ok("Skipping .env configuration")
            return
    print("  Please enter your Discord Webhook URL.")
    print("  (Discord: Server Settings > Integrations > Webhooks)")
    webhook_url = input("  Webhook URL: ").strip()
    if not webhook_url:
        fail("Webhook URL cannot be empty.")
    env_path.write_text(f"DISCORD_WEBHOOK_URL={webhook_url}\n", encoding="utf-8")
    ok(".env file created")


# ── 4. Test notification ──────────────────────────────────────────────────────

def test_notification(python_cmd: list) -> None:
    result = subprocess.run(
        python_cmd + ["-m", "discord_mcp_alert.main"], cwd=SCRIPT_DIR
    )
    if result.returncode != 0:
        fail(
            "Test notification failed.\n"
            "  Check your DISCORD_WEBHOOK_URL in the .env file."
        )
    ok("Test notification sent! Check your Discord channel.")


# ── 5. Register Claude Desktop ────────────────────────────────────────────────

def get_claude_desktop_config_path() -> Path:
    if sys.platform == "darwin":
        return (
            Path.home() / "Library" / "Application Support" / "Claude"
            / "claude_desktop_config.json"
        )
    if sys.platform == "win32":
        appdata = os.environ.get("APPDATA") or str(Path.home() / "AppData" / "Roaming")
        return Path(appdata) / "Claude" / "claude_desktop_config.json"
    return Path.home() / ".config" / "Claude" / "claude_desktop_config.json"


def register_claude_desktop(pkg_mgr: str) -> None:
    config_path = get_claude_desktop_config_path()
    print(f"  Config path: {config_path}")
    config_path.parent.mkdir(parents=True, exist_ok=True)

    config: dict = {}
    if config_path.exists():
        try:
            config = json.loads(config_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            warn("Existing config is invalid JSON. Backing up and starting fresh.")
            shutil.copy(config_path, str(config_path) + ".bak")

    if pkg_mgr == "poetry":
        server_config = {
            "command": "poetry",
            "args": [
                "--directory", str(SCRIPT_DIR),
                "run", "python", "-m", "discord_mcp_alert.server",
            ],
        }
    else:
        python_exe = (
            str(VENV_DIR / "Scripts" / "python.exe")
            if sys.platform == "win32"
            else str(VENV_DIR / "bin" / "python")
        )
        server_config = {
            "command": python_exe,
            "args": ["-m", "discord_mcp_alert.server"],
        }

    mcp_servers = config.setdefault("mcpServers", {})
    mcp_servers["discord-alert"] = server_config
    config_path.write_text(json.dumps(config, indent=2, ensure_ascii=False), encoding="utf-8")
    ok("Claude Desktop config updated!")
    print("  Restart Claude Desktop to apply changes.")


# ── 6. Register Claude Code CLI ───────────────────────────────────────────────

def register_claude_cli(pkg_mgr: str) -> None:
    if not shutil.which("claude"):
        warn("'claude' command not found. Skipping Claude Code CLI registration.")
        if sys.platform == "win32":
            print("  Install Claude Code, then run: .\\register_claude_cli.ps1")
        else:
            print("  Install Claude Code, then run: ./register_claude_cli.sh")
        return

    # Remove existing registration (ignore error if not yet registered)
    subprocess.run(["claude", "mcp", "remove", "discord-alert"], capture_output=True)

    if pkg_mgr == "poetry":
        cmd = [
            "claude", "mcp", "add", "--scope", "user", "discord-alert", "--",
            "poetry", "--directory", str(SCRIPT_DIR), "run", "python",
            "-m", "discord_mcp_alert.server",
        ]
    else:
        python_exe = (
            str(VENV_DIR / "Scripts" / "python.exe")
            if sys.platform == "win32"
            else str(VENV_DIR / "bin" / "python")
        )
        cmd = [
            "claude", "mcp", "add", "--scope", "user", "discord-alert", "--",
            python_exe, "-m", "discord_mcp_alert.server",
        ]

    result = subprocess.run(cmd)
    if result.returncode != 0:
        warn("Claude Code CLI registration failed.")
    else:
        ok("Claude Code CLI registration complete!")
        print("  'notify_discord' tool is now available in ALL projects!")


# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    platform_name = {"win32": "Windows", "darwin": "macOS"}.get(sys.platform, "Linux")

    print("=" * 46)
    print("  Discord MCP Alert - Setup")
    print(f"  Platform: {platform_name}")
    print("=" * 46)

    step(1, "Checking environment...")
    check_python()
    pkg_mgr = detect_package_manager()
    ok(f"Package manager: {pkg_mgr}")
    if pkg_mgr == "pip":
        print("  Note: Poetry not found. Using pip + virtual environment (.venv).")
        print("        Poetry is recommended for more stable dependency management.")
        print("        Install Poetry: https://python-poetry.org/docs/#installation")

    step(2, f"Installing dependencies ({pkg_mgr})...")
    install_deps(pkg_mgr)

    step(3, "Configuring environment...")
    setup_env()

    step(4, "Sending test notification...")
    test_notification(get_python_cmd(pkg_mgr))

    step(5, "Registering to Claude Desktop...")
    try:
        register_claude_desktop(pkg_mgr)
    except Exception as e:
        warn(f"Claude Desktop registration failed: {e}")
        print("  Register manually: python scripts/register_mcp.py")

    step(6, "Registering to Claude Code CLI...")
    register_claude_cli(pkg_mgr)

    print()
    print("=" * 46)
    print("Setup Complete!")
    print("=" * 46)
    print()
    print("Next steps:")
    print("  1. Restart Claude Desktop if it is running")
    print("  2. Use 'notify_discord' in any Claude project!")
    print()


if __name__ == "__main__":
    main()
