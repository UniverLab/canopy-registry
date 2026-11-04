<p align="center">
  <img src="https://raw.githubusercontent.com/UniverLab/.github/main/assets/banner-canopy-registry.svg" alt="Canopy Registry"/>
</p>

<p align="center">
  <a href="https://github.com/UniverLab/harness-canopy"><img src="https://img.shields.io/badge/Canopy-harness--canopy-3CC7BD?style=for-the-badge" alt="Canopy"/></a>
  <img src="https://img.shields.io/badge/format-TOML-9C4221?style=for-the-badge" alt="TOML"/>
  <img src="https://img.shields.io/badge/Status-Active-27AE60?style=for-the-badge" alt="Status"/>
</p>

<p align="center">
  <a href="https://univerlab.org/canopy/">Canopy</a> ·
  <a href="https://univerlab.org/canopy/docs/installation/">Installation</a> ·
  <a href="https://graphs.univerlab.org">Graphs catalogue</a>
</p>

The platform registry behind [Canopy](https://github.com/UniverLab/harness-canopy)'s
setup wizard: the MCP clients it supports, one canonical definition of each MCP
server, and the rules that translate those definitions into every client's own
config format. `canopy setup` reads it, so a new platform lands here without a
Canopy release.

---

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
provider = "My Company"
tool_name = "My Platform CLI"
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

`name` is the identifier canopy stores in configs and graph nodes — it never changes. `provider` is who makes the CLI and `tool_name` is what the product is called; together they are what a user interface shows (`OpenAI · Codex CLI`).

| Field | Description |
|-------|-------------|
| `name` | Platform identifier (slug) |
| `provider` | Who makes the CLI (`Anthropic`, `OpenAI`, `Google`…) |
| `tool_name` | The product's own name (`Claude Code`, `Codex CLI`…) |
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
| `instruction_file` | The instruction file the harness reads at the project root (e.g. `AGENTS.md`) |
| `project_paths` | Directories (trailing `/`) and root files the harness creates **inside a project**, e.g. `[".kilo/", "kilo.jsonc"]`. Required. Never `.github` or `.config` (shared directories). gitkit's `agentic` .gitignore is built from these |
| `instruction_precedence` | Optional. Files the harness reads **instead of** `instruction_file` when they exist, in order (e.g. claude: `["CLAUDE.md", ".claude/CLAUDE.md", "CLAUDE.local.md"]`). Canopy amends the first existing one when it writes its protocol into a sandbox |
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
