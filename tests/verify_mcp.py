import asyncio
import os
import sys
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

# Ensure src is in path for the server process if needed, 
# but here we run the server as a subprocess command.

async def verify_mcp_server():
    # Define server parameters
    # We use the same command as the registration script: poetry run python src/server.py
    server_params = StdioServerParameters(
        command="poetry",
        args=["run", "python", "src/discord_mcp_alert/server.py"],
        env=os.environ.copy(), # Pass current env (including PATH)
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
