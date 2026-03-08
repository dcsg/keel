---
name: keel:mcp
description: "Manage MCP server configuration for project management integrations"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# keel:mcp

Manage MCP (Model Context Protocol) server configuration. MCP servers give Claude native access to project management tools like Linear, GitHub, and Jira.

## Arguments

- No argument: show MCP status — which servers are configured, which env vars are set
- `add linear|github|jira`: add a server to `.mcp.json`
- `remove {server}`: remove a server from `.mcp.json`
- `status`: same as no argument

## MCP Server Configs

### Linear
```json
"linear": {
  "type": "http",
  "url": "https://mcp.linear.app/sse",
  "authorization_token": "${LINEAR_API_KEY}"
}
```
Required: `LINEAR_API_KEY` — get at https://linear.app/settings/api

### GitHub
```json
"github": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
  }
}
```
Required: `GITHUB_TOKEN` — get at https://github.com/settings/tokens (repo scope)

### Jira
```json
"jira": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "mcp-atlassian"],
  "env": {
    "JIRA_URL": "${JIRA_URL}",
    "JIRA_USERNAME": "${JIRA_USERNAME}",
    "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
  }
}
```
Required: `JIRA_URL`, `JIRA_USERNAME`, `JIRA_API_TOKEN` — get token at https://id.atlassian.com/manage-profile/security/api-tokens

## Instructions

### No argument or `status` — Show MCP status

1. Check if `.mcp.json` exists:
   - If not: output "No MCP servers configured. Run `/keel:mcp add linear` to get started."
2. If exists, read and parse it.
3. For each configured server, check if required env vars are set:
   ```bash
   # Linear
   [ -n "$LINEAR_API_KEY" ] && echo "set" || echo "missing"
   # GitHub
   [ -n "$GITHUB_TOKEN" ] && echo "set" || echo "missing"
   # Jira
   [ -n "$JIRA_URL" ] && [ -n "$JIRA_USERNAME" ] && [ -n "$JIRA_API_TOKEN" ] && echo "set" || echo "missing"
   ```
4. Output:
   ```
   MCP Servers:

     linear    ✅ configured, LINEAR_API_KEY set
     github    ⚠️  configured, GITHUB_TOKEN not set
                   Set: export GITHUB_TOKEN="ghp_..."
                   Get one: https://github.com/settings/tokens

   Not configured:
     jira      /keel:mcp add jira

   .mcp.json is committed to git — team inherits server configs.
   Each member needs their own API keys in their local environment.
   ```

### `add {server}` — Add an MCP server

1. Determine which server to add (linear, github, jira).
2. If `.mcp.json` doesn't exist, create it with the server config:
   ```json
   {
     "mcpServers": {
       "{server}": { ... config ... }
     }
   }
   ```
3. If `.mcp.json` exists, read it and add the new server under `mcpServers`. Preserve existing entries.
4. Write the updated `.mcp.json`.
5. Output:
   ```
   ✅ Added {server} to .mcp.json

   Required environment variable(s):
     {env var list with description and link}

   Add to your shell profile (~/.zshrc or ~/.bashrc):
     export {VAR}="your-key-here"

   Then restart your terminal or run: source ~/.zshrc

   Commit .mcp.json to git — your team will inherit the server config.
   Each team member adds their own key to their local environment.
   ```
6. If the server is already in `.mcp.json`: output "linear is already configured." and show status.

### `remove {server}` — Remove an MCP server

1. Read `.mcp.json`. If server not found: output "{server} is not configured."
2. Remove the server entry from `mcpServers`.
3. Write updated file. If `mcpServers` is now empty, delete `.mcp.json`.
4. Output: `Removed {server} from .mcp.json`
