import asyncio
import os
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def test_notify_discord_tool():
    """Test the notify_discord tool through MCP server"""
    server_params = StdioServerParameters(
        command="poetry",
        args=["run", "python", "src/discord_mcp_alert/server.py"],
        env=os.environ.copy(),
    )

    print("🔌 Connecting to MCP server...")

    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()

            # List tools
            print("📋 Listing available tools...")
            tools = await session.list_tools()
            for tool in tools.tools:
                print(f"   - {tool.name}: {tool.description}")

            # Call notify_discord tool
            print("\n📤 Sending test notification via MCP tool...")
            result = await session.call_tool(
                "notify_discord",
                arguments={
                    "message": "🧪 MCP Tool Test: Connection verified! Server is working correctly.",
                    "event_type": "Test"
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
