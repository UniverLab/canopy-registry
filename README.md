# canopy-registry

Platform registry for [agent-canopy](https://github.com/UniverLab/agent-canopy) setup wizard.

Defines supported MCP client platforms, canonical MCP server definitions, and per-platform translation rules so `canopy setup` can automatically configure them all.

## Structure (v6)

```
index.toml              # Platform list + version
servers.toml            # Canonical MCP server definitions
platforms/<name>.toml   # Per-platform translation rules + CLI config
```

## How it works

When you run `canopy` or `canopy setup`, the wizard:

1. Fetches `index.toml` to get the platform list
2. Fetches `servers.toml` for canonical MCP server definitions
3. Fetches `platforms/<name>.toml` for each detected platform
4. Translates canonical servers → platform-specific format using translation rules
5. Writes the adapted config to each platform's config file

## servers.toml

Defines MCP servers in a platform-agnostic canonical form:

```toml
[servers.canopy]
url = "http://localhost:7755/mcp"

[servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "{filesystem_dir}"]
```

Placeholders: `{filesystem_dir}`, `{home}`, `{memory_path}`

## Adding a new platform

Create `platforms/<name>.toml`:

```toml
name = "my-platform"
config_path = ".my-platform/mcp.json"
mcp_servers_key = ["mcpServers"]
deprecated_keys = ["task-trigger"]
unsupported_keys = ["autoApprove"]

[required_fields]
type = ["http"]

[server_extras.canopy]
tools = ["*"]

[cli]
binary = "my-platform"
headless_mode = "--headless"
interactive_args = "--tui"
model_flag = "--model"
supports_working_dir = true
working_dir_flag = "--dir"
accent_color = [139, 92, 246]
```

Then add the entry to `index.toml`:

```toml
[[platforms]]
name = "my-platform"
binary = "my-platform"
```

## Platform fields

| Field | Description |
|-------|-------------|
| `name` | Display name in the wizard |
| `config_path` | Path to MCP config file relative to `$HOME` |
| `config_format` | Config file format: `"json"` (default) or `"toml"` |
| `toml_array_format` | When `true`, TOML uses `[[section]]` array-of-tables |
| `command_format` | `"separate"` (default): `command` + `args` apart. `"merged"`: single array |
| `mcp_servers_key` | Key path to MCP servers object (e.g. `["mcpServers"]`) |
| `deprecated_keys` | Old MCP server keys to remove during setup |
| `unsupported_keys` | Config keys this platform does not support (stripped on sync) |
| `fields_mapping` | Renames canonical fields (e.g. `{ env = "environment" }`) |
| `required_fields` | Fields that must be present; first value is default (e.g. `{ type = ["http"] }`) |
| `server_extras` | Per-server extra fields merged into the adapted config (e.g. `[server_extras.canopy] tools = ["*"]`) |
| `skills_dir` | Platform's skills directory relative to `$HOME` |
| `cli` | CLI strategy definition for headless/interactive execution |

### CLI fields

| Field | Description |
|-------|-------------|
| `binary` | Binary name in PATH |
| `headless_mode` | Flags for headless mode |
| `interactive_args` | Arguments for TUI mode |
| `fallback_interactive_args` | Fallback if primary interactive mode fails |
| `resume_args` | Arguments to resume the most recent session |
| `session_list_cmd` | Subcommand to list sessions |
| `session_resume_cmd` | Flag to resume a specific session by ID |
| `model_flag` | Flag to specify model |
| `supports_working_dir` | Whether CLI supports working directory flag |
| `working_dir_flag` | Flag to set working directory |
| `env_vars` | Environment variables to set when running |
| `accent_color` | RGB accent color for TUI |

## License

MIT
