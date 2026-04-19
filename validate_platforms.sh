#!/bin/bash

# Script to validate consistency between platforms/ directory and index.toml/servers.toml
# Registry v6: TOML format, canonical servers separated from platform rules.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORMS_DIR="$SCRIPT_DIR/platforms"
INDEX_TOML="$SCRIPT_DIR/index.toml"
SERVERS_TOML="$SCRIPT_DIR/servers.toml"

errors=0

echo "Checking required files..."
for file in "$INDEX_TOML" "$SERVERS_TOML"; do
    if [ ! -f "$file" ]; then
        echo "ERROR: Missing required file: $file"
        errors=$((errors + 1))
    fi
done

if [ ! -d "$PLATFORMS_DIR" ]; then
    echo "ERROR: Missing platforms/ directory"
    exit 1
fi

# Extract platform names from index.toml
echo "Extracting platform names from index.toml..."
INDEX_PLATFORMS=$(grep '^name = ' "$INDEX_TOML" | sed 's/name = "\(.*\)"/\1/' | sort)

# List platform .toml files
echo "Listing platform files..."
PLATFORM_FILES=$(find "$PLATFORMS_DIR" -name "*.toml" -exec basename {} .toml \; | sort)

echo "Comparing index.toml vs platforms/ directory..."
if [ "$INDEX_PLATFORMS" != "$PLATFORM_FILES" ]; then
    echo "ERROR: Platform names mismatch"
    echo "index.toml: $INDEX_PLATFORMS"
    echo "platforms/: $PLATFORM_FILES"
    errors=$((errors + 1))
else
    echo "✓ index.toml and platforms/ directory match"
fi

# Validate each platform TOML
echo "Validating platform files..."
for pfile in "$PLATFORMS_DIR"/*.toml; do
    pname=$(basename "$pfile" .toml)
    echo "  Validating $pname..."

    # Check required fields
    has_name=$(grep -c '^name = ' "$pfile" || true)
    has_config=$(grep -c '^config_path = ' "$pfile" || true)
    has_key=$(grep -c '^mcp_servers_key = ' "$pfile" || true)

    if [ "$has_name" -ge 1 ] && [ "$has_config" -ge 1 ] && [ "$has_key" -ge 1 ]; then
        echo "  ✓ $pname has required fields"
    else
        echo "  ERROR: $pname missing required fields (name, config_path, mcp_servers_key)"
        errors=$((errors + 1))
    fi

    # Verify name matches filename
    file_name=$(grep '^name = ' "$pfile" | head -1 | sed 's/name = "\(.*\)"/\1/')
    if [ "$file_name" = "$pname" ]; then
        echo "  ✓ $pname name field matches filename"
    else
        echo "  ERROR: $pname name field '$file_name' does not match filename"
        errors=$((errors + 1))
    fi
done

# Validate servers.toml has at least canopy
if grep -q '^\[servers\.canopy\]' "$SERVERS_TOML"; then
    echo "✓ servers.toml has canopy server"
else
    echo "ERROR: servers.toml missing [servers.canopy]"
    errors=$((errors + 1))
fi

echo ""
if [ "$errors" -gt 0 ]; then
    echo "$errors error(s) found!"
    exit 1
else
    echo "All validations passed!"
fi
