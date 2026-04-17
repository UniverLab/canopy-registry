#!/bin/bash

# Script to validate consistency between platforms/ directory and platforms.json/schema.json

set -euo pipefail

# Define paths relative to script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORMS_DIR="$SCRIPT_DIR/platforms"
PLATFORMS_JSON="$SCRIPT_DIR/platforms.json"
INDEX_JSON="$SCRIPT_DIR/index.json"
SCHEMA_JSON="$SCRIPT_DIR/schema.json"

# Check if required files exist
echo "Checking required files..."
for file in "$PLATFORMS_JSON" "$INDEX_JSON" "$SCHEMA_JSON"; do
    if [ ! -f "$file" ]; then
        echo "ERROR: Missing required file: $file"
        exit 1
    fi
done

# Extract platform names from index.json
echo "Extracting platform names from index.json..."
INDEX_PLATFORMS=$(grep -o '"name": "[^"]*"' "$INDEX_JSON" | cut -d'"' -f4 | sort)

# Extract platform names from platforms.json
echo "Extracting platform names from platforms.json..."
PLATFORMS_JSON_NAMES=$(grep -o '"name": "[^"]*"' "$PLATFORMS_JSON" | cut -d'"' -f4 | sort)

# List platform files in platforms/ directory
echo "Listing platform files in platforms/ directory..."
PLATFORM_FILES=$(find "$PLATFORMS_DIR" -name "*.json" -exec basename {} .json \; | sort)

# Compare index.json vs platforms.json
echo "Comparing index.json vs platforms.json..."
if [ "$INDEX_PLATFORMS" != "$PLATFORMS_JSON_NAMES" ]; then
    echo "ERROR: Platform names mismatch between index.json and platforms.json"
    echo "index.json platforms: $INDEX_PLATFORMS"
    echo "platforms.json platforms: $PLATFORMS_JSON_NAMES"
    exit 1
else
    echo "✓ index.json and platforms.json platforms match"
fi

# Compare platforms.json vs platforms/ directory
echo "Comparing platforms.json vs platforms/ directory..."
if [ "$PLATFORMS_JSON_NAMES" != "$PLATFORM_FILES" ]; then
    echo "ERROR: Platform names mismatch between platforms.json and platforms/ directory"
    echo "platforms.json platforms: $PLATFORMS_JSON_NAMES"
    echo "platforms/ directory: $PLATFORM_FILES"
    exit 1
else
    echo "✓ platforms.json and platforms/ directory match"
fi

# Validate each platform file against schema (basic checks)
echo "Validating platform files against schema..."
for platform_file in $PLATFORM_FILES; do
    platform_path="$PLATFORMS_DIR/${platform_file}.json"
    echo "Validating $platform_file..."
    
    # Check required fields exist
    if grep -q '"name"' "$platform_path" && \
       grep -q '"config_path"' "$platform_path" && \
       grep -q '"mcp_servers_key"' "$platform_path" && \
       grep -q '"canopy_entry_key"' "$platform_path" && \
       grep -q '"canopy_entry"' "$platform_path"; then
        echo "✓ $platform_file has required fields"
    else
        echo "ERROR: $platform_file missing required fields"
        exit 1
    fi
done

echo "All validations passed successfully!"
