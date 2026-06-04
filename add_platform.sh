#!/bin/bash

# Interactive script to add a new platform configuration
# This script guides users through creating a new platform TOML file
# and updates the index.toml with the new platform entry.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORMS_DIR="$SCRIPT_DIR/platforms"
INDEX_TOML="$SCRIPT_DIR/index.toml"

# Function to validate yes/no input
yes_no_prompt() {
    local prompt="$1"
    local default="$2"
    local response
    
    while true; do
        if [ -n "$default" ]; then
            read -p "$prompt [Y/n]: " response
            response="${response:-Y}"
        else
            read -p "$prompt [y/n]: " response
        fi
        
        case "$response" in
            [yY][eE][sS]|[yY]|"")
                return 0
                ;;
            [nN][oO]|[nN])
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

# Function to get required input
get_input() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " response
        response="${response:-$default}"
    else
        read -p "$prompt: " response
    fi
    
    printf -v "$var_name" "%s" "$response"
}

# Function to get array input
get_array_input() {
    local prompt="$1"
    local var_name="$2"
    local items=()
    
    echo "$prompt"
    echo "Enter items one by one (leave empty to finish):"
    
    while true; do
        read -p "  Item: " item
        if [ -z "$item" ]; then
            break
        fi
        items+=("$item")
    done
    
    printf -v "$var_name" "%s" "$(IFS="," ; echo "[\"${items[*]}\"]")"
}

# Function to get boolean input
get_boolean_input() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    
    if [ -n "$default" ]; then
        read -p "$prompt [${default}]: " response
        response="${response:-$default}"
    else
        read -p "$prompt: " response
    fi
    
    printf -v "$var_name" "%s" "$response"
}

# Function to get RGB color input
get_rgb_color() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    
    if [ -n "$default" ]; then
        read -p "$prompt (format: R,G,B) [$default]: " response
        response="${response:-$default}"
    else
        read -p "$prompt (format: R,G,B): " response
    fi
    
    printf -v "$var_name" "%s" "$response"
}

echo "=== Add New Platform Configuration ==="
echo ""

# Get platform name
get_input "Enter platform name (e.g., 'opencode', 'kiro'): " platform_name

# Validate platform name doesn't already exist
if [ -f "$PLATFORMS_DIR/$platform_name.toml" ]; then
    echo "ERROR: Platform '$platform_name' already exists!"
    exit 1
fi

# Get basic platform info
get_input "Enter config path (e.g., '.config/opencode/opencode.json'): " config_path
get_input "Enter MCP servers key (e.g., 'mcp' or 'mcpServers'): " mcp_servers_key
get_input "Enter skills directory (e.g., '.agents/skills'): " skills_dir

# Get CLI information
echo ""
echo "=== CLI Configuration ==="
get_input "Enter binary name: " binary
get_input "Enter headless mode command: " headless_mode
get_input "Enter interactive args: " interactive_args ""
get_input "Enter model flag: " model_flag
get_boolean_input "Supports working directory? (true/false): " supports_working_dir "false"

if [ "$supports_working_dir" = "true" ]; then
    get_input "Enter working directory flag: " working_dir_flag
fi

get_input "Enter resume args: " resume_args ""
get_input "Enter session list command: " session_list_cmd ""
get_input "Enter session resume command: " session_resume_cmd ""
get_rgb_color "Enter accent color (R,G,B format): " accent_color "92,156,245"

# Get optional fields
echo ""
echo "=== Optional Fields ==="
if yes_no_prompt "Add deprecated keys?" "n"; then
    get_array_input "Enter deprecated keys:" deprecated_keys
else
    deprecated_keys="[]"
fi

if yes_no_prompt "Add unsupported keys?" "n"; then
    get_array_input "Enter unsupported keys:" unsupported_keys
else
    unsupported_keys="[]"
fi

# Get command format
echo ""
echo "=== Advanced Configuration ==="
get_input "Enter command format (merged/separate): " command_format "merged"

# Get server extras
echo ""
echo "=== Server Extras ==="
if yes_no_prompt "Configure canopy server extras?" "y"; then
    get_boolean_input "Canopy enabled? (true/false): " canopy_enabled "true"
    if yes_no_prompt "Add autoApprove for canopy?" "n"; then
        get_array_input "Enter autoApprove items:" canopy_auto_approve
    else
        canopy_auto_approve="[]"
    fi
fi

if yes_no_prompt "Configure filesystem server extras?" "y"; then
    get_boolean_input "Filesystem enabled? (true/false): " filesystem_enabled "true"
fi

if yes_no_prompt "Configure fetch server extras?" "y"; then
    get_boolean_input "Fetch enabled? (true/false): " fetch_enabled "true"
fi

# Generate the TOML file
echo ""
echo "=== Generating TOML Configuration ==="

# Create the platform TOML file
platform_file="$PLATFORMS_DIR/$platform_name.toml"

cat > "$platform_file" <<EOF
name = "$platform_name"
config_path = "$config_path"
command_format = "$command_format"
mcp_servers_key = $mcp_servers_key
deprecated_keys = $deprecated_keys
unsupported_keys = $unsupported_keys
skills_dir = "$skills_dir"

[fields_mapping]
env = "environment"

[required_fields]
type = ["remote", "local"]

[server_extras.canopy]
enabled = $canopy_enabled
EOF

if [ "$canopy_auto_approve" != "[]" ]; then
    cat >> "$platform_file" <<EOF
autoApprove = $canopy_auto_approve
EOF
fi

cat >> "$platform_file" <<EOF

[server_extras.filesystem]
enabled = $filesystem_enabled

[server_extras.fetch]
enabled = $fetch_enabled

[cli]
binary = "$binary"
headless_mode = "$headless_mode"
interactive_args = "$interactive_args"
model_flag = "$model_flag"
supports_working_dir = $supports_working_dir
EOF

if [ "$supports_working_dir" = "true" ]; then
    cat >> "$platform_file" <<EOF
working_dir_flag = "$working_dir_flag"
EOF
fi

cat >> "$platform_file" <<EOF
accent_color = [$accent_color]
resume_args = "$resume_args"
EOF

if [ -n "$session_list_cmd" ]; then
    cat >> "$platform_file" <<EOF
session_list_cmd = "$session_list_cmd"
EOF
fi

if [ -n "$session_resume_cmd" ]; then
    cat >> "$platform_file" <<EOF
session_resume_cmd = "$session_resume_cmd"
EOF
fi

echo "✓ Created platform configuration: $platform_file"

# Update index.toml
echo ""
echo "=== Updating index.toml ==="

# Add the new platform to index.toml
cat >> "$INDEX_TOML" <<EOF

[[platforms]]
name = "$platform_name"
binary = "$binary"
EOF

echo "✓ Updated index.toml with new platform entry"

echo ""
echo "=== Platform Added Successfully! ==="
echo "New platform: $platform_name"
echo "Binary: $binary"
echo "Config file: $platform_file"
echo ""
echo "You can now run ./validate_platforms.sh to verify the configuration."
