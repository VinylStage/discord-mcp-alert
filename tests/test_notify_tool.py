import asyncio
import os
import sys
from pathlib import Path

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

PROJECT_ROOT = Path(__file__).resolve().parent.parent


async def test_notify_discord_tool():
    """Test the notify_discord tool through MCP server"""
    env = os.environ.copy()
    env["PYTHONPATH"] = str(PROJECT_ROOT / "src")

    server_params = StdioServerParameters(
        command=sys.executable,
        args=["-m", "discord_mcp_alert.server"],
        env=env,
    )

    print("🔌 Connecting to MCP server...")

    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()

            print("📋 Listing available tools...")
            tools = await session.list_tools()
            for tool in tools.tools:
                print(f"   - {tool.name}: {tool.description[:80]}...")

            print("\n📤 Sending test notification via MCP tool...")
            result = await session.call_tool(
                "notify_discord",
                arguments={
                    "message": "🧪 MCP Tool Test: Connection verified! Server is working correctly.",
                    "title":   "MCP Test",
                    "event_type": "info",
                    "source": "claude_code",
                }
            )

            print(f"✅ Result: {result.content[0].text}")

if __name__ == "__main__":
    try:
        asyncio.run(test_notify_discord_tool())
    except Exception as e:
        print(f"❌ Error during test: {e}")
        import traceback
        traceback.print_exc()
