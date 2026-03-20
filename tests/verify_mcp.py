import asyncio
import os
import sys
from pathlib import Path

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

PROJECT_ROOT = Path(__file__).resolve().parent.parent


async def verify_mcp_server():
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
            
            # List tools
            print("📋 Requesting tool list...")
            tools = await session.list_tools()
            
            found = False
            for tool in tools.tools:
                print(f"   - Found tool: {tool.name}")
                if tool.name == "notify_discord":
                    found = True
            
            if found:
                print("✅ Verification Success: 'notify_discord' tool is available.")
            else:
                print("❌ Verification Failed: 'notify_discord' tool was NOT found.")
                sys.exit(1)

if __name__ == "__main__":
    try:
        asyncio.run(verify_mcp_server())
    except Exception as e:
        print(f"❌ Error during verification: {e}")
        sys.exit(1)
