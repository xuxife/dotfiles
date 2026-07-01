# Personal instructions: Agency MCP overview

I deliberately keep MCP servers **out of the chat context** (no live
`~/.copilot/mcp-config.json`). Instead, reach Microsoft/Azure MCP tools
**on demand** through the helper `~/.local/bin/amcp`, which spawns
`agency mcp <server>`, does the stdio handshake, runs a single call, and
exits — zero standing MCP context. Auth is silent via the azureauth cache.
