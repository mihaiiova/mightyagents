---
title: Connect your coding agent
nav: Connect your agent
group: Getting started
weight: 20
lead: "`toad setup` registers Toad with the coding agents it finds. This page is for doing it by hand, or for clients it doesn't know."
---

Toad is one MCP server, started with the command `toad mcp`. Register it once:
every project uses the same server, and each call says which project it is
for.

## Claude Code, Codex and Pi

| Client | Command |
|---|---|
| Claude Code | `claude mcp add --scope user toad -- toad mcp` |
| Codex | `codex mcp add toad -- toad mcp` |
| Pi | `pi mcp add toad -- toad mcp` |

For Pi, also set `"requestTimeoutMs": 900000` on Toad's entry in
`~/.pi/agent/mcp.json`, so long runs are not cut off.

## Any other MCP client

Cursor, Windsurf, Claude Desktop and the rest take a JSON entry in their MCP
settings:

```json
{
  "mcpServers": {
    "toad": { "command": "toad", "args": ["mcp"] }
  }
}
```

## Timeouts

Toad sends progress every 15 seconds while it tests, so clients that reset
their timeout on progress wait for long runs. If yours does not, raise its MCP
tool timeout to 15 minutes or more.

## Check the connection

Restart the coding agent, then ask it to *"list the Toad tools"*. You should
see:

- `get_toad_guide`
- `setup_project`
- `run_project_test`
- `run_web_test` and `run_cli_test` (legacy)

The server also gives the agent a guide on how to write good tests and handle
credentials, through the `get_toad_guide` tool and the `toad://guide`
resource. Most clients pick it up from the server's instructions. If yours
does not, tell the agent: *"Call get_toad_guide before using Toad."*
