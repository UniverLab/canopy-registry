# canopy-registry

Platform registry for [agent-canopy](https://github.com/UniverLab/agent-canopy) setup wizard.

Defines supported MCP client platforms and their configuration format so `canopy setup` can automatically configure them.

## How it works

When you run `canopy` or `canopy setup`, the wizard fetches `platforms.json` from this repo to get the latest list of supported platforms. It then:

1. Detects which platforms are installed (by checking if their config file exists)
2. Lets you select which to configure
3. Adds the canopy MCP server entry in each platform's expected format
4. Removes deprecated entries (e.g. old `task-trigger`)

## Adding a new platform

Add an entry to `platforms.json`:

```json
{
  "name": "my-platform",
  "config_path": ".my-platform/mcp.json",
  "servers_key": ["mcpServers", "canopy"],
  "canopy_entry": {
    "url": "http://localhost:7755/mcp"
  },
  "deprecated_keys": ["task-trigger"]
}
```

| Field | Description |
|-------|-------------|
| `name` | Display name in the wizard |
| `config_path` | Path to MCP config file relative to `$HOME` |
| `servers_key` | JSON key path where the canopy entry is inserted |
| `canopy_entry` | The MCP server entry in the platform's expected format |
| `deprecated_keys` | Old keys to remove from the servers object |

## Schema

See [schema.json](schema.json) for the full JSON Schema.

## License

MIT
