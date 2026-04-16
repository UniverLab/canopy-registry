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
  "mcp_servers_key": ["mcpServers"],
  "canopy_entry_key": "canopy",
  "canopy_entry": {
    "url": "http://localhost:7755/mcp"
  },
  "deprecated_keys": ["task-trigger"],
  "unsupported_keys": ["autoApprove"],
  "cli": {
    "binary": "my-platform",
    "headless_mode": "--headless",
    "interactive_args": "--tui",
    "model_flag": "--model",
    "supports_working_dir": true,
    "working_dir_flag": "--dir",
    "env_vars": {},
    "accent_color": [139, 92, 246]
  }
}
```

| Field | Description |
|-------|-------------|
| `name` | Display name in the wizard |
| `config_path` | Path to MCP config file relative to `$HOME` |
| `mcp_servers_key` | JSON key path to the MCP servers object (e.g., ['mcpServers']) |
| `canopy_entry_key` | Key name for the canopy entry within the MCP servers object (e.g., 'canopy') |
| `canopy_entry` | The MCP server entry in the platform's expected format |
| `deprecated_keys` | Old MCP server keys to remove during setup (e.g. task-trigger) |
| `unsupported_keys` | MCP server config keys that this platform does not support |
| `cli` | CLI strategy definition for headless execution |
| `cli.binary` | Binary name in PATH |
| `cli.headless_mode` | Command flags to run in headless mode |
| `cli.interactive_args` | Arguments to pass when launching in interactive (TUI) mode |
| `cli.fallback_interactive_args` | Fallback arguments if the primary interactive mode fails |
| `cli.resume_args` | Arguments to resume the most recent session (e.g., `--continue`) |
| `cli.session_list_cmd` | Subcommand to list sessions (enables canopy-side session picker) |
| `cli.session_resume_cmd` | Flag to resume a specific session by ID (e.g., `--session`) |
| `cli.model_flag` | Flag to specify model |
| `cli.supports_working_dir` | Whether this CLI supports working directory flag |
| `cli.working_dir_flag` | Flag to set working directory |
| `cli.env_vars` | Environment variables to set when running this CLI |
| `cli.accent_color` | RGB accent color for this CLI's agents in the TUI |

## Schema

See [schema.json](schema.json) for the full JSON Schema.

## License

MIT
