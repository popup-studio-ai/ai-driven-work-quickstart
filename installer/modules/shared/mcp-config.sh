#!/bin/bash
# ============================================
# Shared MCP Configuration Utilities
# FR-S3-05a: Eliminate 4x duplicate MCP config logic
# Uses `claude mcp add` CLI for correct config path (~/.claude.json)
# Uses `gemini mcp add` CLI for Gemini CLI (~/.gemini/settings.json)
# ============================================

# Source colors if not already loaded
if [ -z "$NC" ]; then
    SCRIPT_DIR_MCP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "${SHARED_DIR:-$SCRIPT_DIR_MCP}/colors.sh"
fi

# Determine CLI command based on CLI_TYPE
_mcp_cli() {
    if [ "$CLI_TYPE" = "gemini" ]; then
        echo "gemini"
    else
        echo "${CLI_TYPE:-claude}"
    fi
}

# Add a Docker-based MCP server to config
# Usage: mcp_add_docker_server "server_name" "image_name" [extra_args...] [-- post_image_args...]
mcp_add_docker_server() {
    local server_name="$1"
    local image_name="$2"
    shift 2

    local extra_args=()
    local post_args=()
    local found_separator=false

    for arg in "$@"; do
        if [ "$arg" = "--" ]; then
            found_separator=true
            continue
        fi
        if [ "$found_separator" = true ]; then
            post_args+=("$arg")
        else
            extra_args+=("$arg")
        fi
    done

    local cli
    cli=$(_mcp_cli)

    # Build docker command args
    local docker_args="docker run -i --rm"
    for arg in "${extra_args[@]}"; do
        docker_args="$docker_args $arg"
    done
    docker_args="$docker_args $image_name"
    for arg in "${post_args[@]}"; do
        docker_args="$docker_args $arg"
    done

    $cli mcp add "$server_name" -s user -- $docker_args 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}[OK] MCP server '$server_name' configured${NC}"
    else
        echo -e "  ${RED}[FAIL] Failed to add MCP server '$server_name'${NC}"
        return 1
    fi
}

# Add a stdio-based MCP server to config
# Usage: mcp_add_stdio_server "server_name" "command" [args...]
mcp_add_stdio_server() {
    local server_name="$1"
    local cmd="$2"
    shift 2
    local cmd_args=("$@")

    local cli
    cli=$(_mcp_cli)

    $cli mcp add "$server_name" -s user -- "$cmd" "${cmd_args[@]}" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}[OK] MCP server '$server_name' configured${NC}"
    else
        echo -e "  ${RED}[FAIL] Failed to add MCP server '$server_name'${NC}"
        return 1
    fi
}

# Remove an MCP server from config
mcp_remove_server() {
    local server_name="$1"
    local cli
    cli=$(_mcp_cli)

    $cli mcp remove "$server_name" 2>/dev/null
}

# Add MCP server permission to ~/.claude/settings.json
# Usage: mcp_add_permission "mcp__server-name"
mcp_add_permission() {
    local permission="$1"

    # Claude only (not gemini)
    if [ "$CLI_TYPE" = "gemini" ]; then
        return 0
    fi

    local settings_path="$HOME/.claude/settings.json"

    if ! command -v node > /dev/null 2>&1; then
        echo -e "  ${RED}Node.js is required for permission configuration${NC}"
        return 1
    fi

    SETTINGS_PATH="$settings_path" \
    PERMISSION="$permission" \
    node -e "
const fs = require('fs');
const settingsPath = process.env.SETTINGS_PATH;
const permission = process.env.PERMISSION;

let settings = {};
if (fs.existsSync(settingsPath)) {
    try { settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8').replace(/^\uFEFF/, '')); } catch(e) {}
}

if (!settings.permissions) settings.permissions = {};
if (!settings.permissions.allow) settings.permissions.allow = [];

if (!settings.permissions.allow.includes(permission)) {
    settings.permissions.allow.push(permission);
    fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
    console.log('  Added permission: ' + permission);
} else {
    console.log('  Permission already set: ' + permission);
}
"
    echo -e "  ${GREEN}[OK] Claude settings updated${NC}"
}

# Check if an MCP server exists in config
mcp_server_exists() {
    local server_name="$1"
    local cli
    cli=$(_mcp_cli)

    $cli mcp list 2>/dev/null | grep -q "$server_name"
}
