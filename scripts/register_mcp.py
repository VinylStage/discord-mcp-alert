"""
Discord MCP Alert — Claude Desktop Registration Script

Python resolution priority (highest → lowest):
  1. Poetry  — poetry env info --executable
  2. uv      — uv run python / uv venv
  3. system  — python3 / python (must already have mcp installed)
"""
import json
import subprocess
import sys
import shutil
from pathlib import Path

SERVER_NAME  = "discord-alert"
PROJECT_ROOT = Path(__file__).resolve().parent.parent
SRC_DIR      = PROJECT_ROOT / "src"


def get_claude_desktop_config_path() -> Path:
    if sys.platform == "darwin":
        return Path.home() / "Library" / "Application Support" / "Claude" / "claude_desktop_config.json"
    elif sys.platform == "win32":
        return Path.home() / "AppData" / "Roaming" / "Claude" / "claude_desktop_config.json"
    else:
        return Path.home() / ".config" / "Claude" / "claude_desktop_config.json"


def _run(cmd: list[str], **kwargs) -> str:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True, **kwargs)
    return result.stdout.strip()


# ---------------------------------------------------------------------------
# Python resolver — tries each tool in order, returns first working path
# ---------------------------------------------------------------------------

def _try_poetry() -> str | None:
    """Returns venv Python path via Poetry, or None."""
    try:
        path = _run(["poetry", "env", "info", "--executable"], cwd=str(PROJECT_ROOT))
        if path and Path(path).exists():
            return path
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    # Try --path fallback
    try:
        venv = _run(["poetry", "env", "info", "--path"], cwd=str(PROJECT_ROOT))
        candidate = Path(venv) / "bin" / "python"
        if candidate.exists():
            return str(candidate)
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    return None


def _try_uv() -> str | None:
    """Returns venv Python path via uv, or None."""
    try:
        _run(["uv", "--version"])  # check uv exists
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None

    venv_dir = PROJECT_ROOT / ".venv"

    # Create venv + install if not present
    if not venv_dir.exists():
        print("   [uv] Creating .venv and installing dependencies...")
        try:
            subprocess.run(["uv", "sync"], cwd=str(PROJECT_ROOT), check=True)
        except subprocess.CalledProcessError:
            try:
                subprocess.run(["uv", "venv"], cwd=str(PROJECT_ROOT), check=True)
                subprocess.run(["uv", "pip", "install", "-e", "."], cwd=str(PROJECT_ROOT), check=True)
            except subprocess.CalledProcessError:
                return None

    python = venv_dir / "bin" / "python"
    if python.exists():
        return str(python)
    return None


def _try_system() -> str | None:
    """
    Returns the current interpreter if mcp is already importable from it.
    Last resort — no venv, user installed packages globally.
    """
    try:
        subprocess.run(
            [sys.executable, "-c", "import mcp"],
            check=True, capture_output=True,
        )
        return sys.executable
    except subprocess.CalledProcessError:
        pass
    return None


def get_python_executable() -> str:
    resolvers = [
        ("Poetry",  _try_poetry),
        ("uv",      _try_uv),
        ("system",  _try_system),
    ]
    for label, fn in resolvers:
        print(f"   Trying {label}...", end=" ", flush=True)
        result = fn()
        if result:
            print(f"✅  {result}")
            return result
        print("not found")

    raise RuntimeError(
        "Could not locate a Python with 'mcp' installed.\n"
        "\n"
        "Options:\n"
        "  A) Poetry  →  cd project && poetry install\n"
        "  B) uv      →  cd project && uv sync\n"
        "  C) pip     →  pip install mcp requests python-dotenv\n"
        "               then re-run this script"
    )


# ---------------------------------------------------------------------------
# Config writer
# ---------------------------------------------------------------------------

def update_claude_desktop_config():
    config_path = get_claude_desktop_config_path()
    print(f"📂 Claude Desktop config: {config_path}")

    if not config_path.parent.exists():
        print(f"⚠️  Directory missing, creating: {config_path.parent}")
        config_path.parent.mkdir(parents=True, exist_ok=True)

    config: dict = {}
    if config_path.exists():
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                config = json.load(f)
        except json.JSONDecodeError:
            backup = str(config_path) + ".bak"
            print(f"⚠️  Invalid JSON — backing up to: {backup}")
            shutil.copy(config_path, backup)
            config = {}

    print("\n🔍 Resolving Python executable...")
    python_executable = get_python_executable()

    server_config = {
        "command": python_executable,
        "args": ["-m", "discord_mcp_alert.server"],
        "cwd": str(PROJECT_ROOT),
        "env": {
            "PYTHONPATH": str(SRC_DIR),
        },
    }

    mcp_servers = config.get("mcpServers", {})
    mcp_servers[SERVER_NAME] = server_config
    config["mcpServers"] = mcp_servers

    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Registered '{SERVER_NAME}' in Claude Desktop config!")
    print(f"   command    : {python_executable}")
    print(f"   args       : [\"-m\", \"discord_mcp_alert.server\"]")
    print(f"   cwd        : {PROJECT_ROOT}")
    print(f"   PYTHONPATH : {SRC_DIR}")
    print("\n⚠️  Please QUIT and RELAUNCH Claude Desktop for the change to take effect.")


if __name__ == "__main__":
    print("🚀 Discord MCP Alert — Claude Desktop Registration")
    print("=" * 52)
    try:
        update_claude_desktop_config()
    except Exception as e:
        print(f"\n❌ Registration failed:\n   {e}")
        sys.exit(1)
    print("\n✨ Done!")
