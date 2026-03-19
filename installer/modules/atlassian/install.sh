#!/bin/bash
# ============================================
# Atlassian (Jira + Confluence) MCP Module (Mac/Linux)
# ============================================
# Auto-detects Docker and recommends best option

# FR-S3-05a: Source shared utilities
SHARED_DIR="${SHARED_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../shared" 2>/dev/null && pwd)}"
if [ -n "$SHARED_DIR" ] && [ -f "$SHARED_DIR/colors.sh" ]; then
    source "$SHARED_DIR/colors.sh"
    source "$SHARED_DIR/docker-utils.sh"
    source "$SHARED_DIR/browser-utils.sh"
    source "$SHARED_DIR/mcp-config.sh"
else
    # Fallback for remote execution
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    CYAN='\033[0;36m'; GRAY='\033[0;90m'; NC='\033[0m'
fi

echo "Atlassian MCP lets Claude access:"
echo -e "  ${GRAY}- Jira (view issues, create tasks)${NC}"
echo -e "  ${GRAY}- Confluence (search, read pages)${NC}"
echo ""

# ============================================
# Auto-detect Docker
# ============================================
HAS_DOCKER=false
DOCKER_RUNNING=false
if docker_is_installed; then
    HAS_DOCKER=true
    if docker_is_running; then
        DOCKER_RUNNING=true
    fi
fi

# ============================================
# Show options based on Docker status
# ============================================
echo "========================================"
if [ "$HAS_DOCKER" = true ]; then
    echo -e "${GREEN}  Docker is installed!${NC}"
    echo "========================================"
    echo ""
    echo "Select installation method:"
    echo -e "  ${GREEN}1. Local install (Recommended) - Uses Docker, runs on your machine${NC}"
    echo "  2. Simple install - Browser login only"
else
    echo -e "${YELLOW}  Docker is not installed.${NC}"
    echo "========================================"
    echo ""
    echo "Select installation method:"
    echo -e "  ${GREEN}1. Simple install (Recommended) - Browser login only, no extra install${NC}"
    echo "  2. Local install - Requires Docker"
fi
echo ""
read -p "Select (1/2): " choice < /dev/tty

# Determine which mode based on Docker status and choice
USE_DOCKER=false
if [ "$HAS_DOCKER" = true ]; then
    # Docker available: 1=Docker, 2=Rovo
    if [ "$choice" != "2" ]; then
        USE_DOCKER=true
    fi
else
    # No Docker: 1=Rovo, 2=Docker
    if [ "$choice" = "2" ]; then
        USE_DOCKER=true
    fi
fi

# ============================================
# Execute selected mode
# ============================================
if [ "$USE_DOCKER" = true ]; then
    # ========================================
    # MCP-ATLASSIAN (Docker)
    # ========================================

    # Check Docker is available
    if [ "$HAS_DOCKER" = false ]; then
        echo ""
        echo -e "${RED}Docker is not installed!${NC}"
        echo "Please install Docker Desktop first:"
        echo -e "  ${CYAN}https://www.docker.com/products/docker-desktop/${NC}"
        echo ""
        exit 1
    fi

    # Check Docker is running
    if [ "$DOCKER_RUNNING" = false ]; then
        echo ""
        if ! docker_check; then
            exit 1
        fi
    else
        echo ""
        echo -e "${GREEN}[OK] Docker check complete${NC}"
    fi

    echo ""
    echo -e "${YELLOW}Setting up mcp-atlassian (Docker)...${NC}"
    echo ""
    echo "API token required. Create one here:"
    echo -e "  ${CYAN}https://id.atlassian.com/manage-profile/security/api-tokens${NC}"
    echo ""

    # FR-S3-05a: Use shared browser_open utility
    read -p "Open API token page in browser? (y/n): " openToken < /dev/tty
    if [ "$openToken" = "y" ] || [ "$openToken" = "Y" ]; then
        browser_open "https://id.atlassian.com/manage-profile/security/api-tokens"
        echo -e "${YELLOW}Create and copy the token.${NC}"
        read -p "Press Enter when ready: " < /dev/tty
    fi

    echo ""
    read -p "Atlassian URL (e.g., https://company.atlassian.net): " atlassianUrl < /dev/tty
    atlassianUrl="${atlassianUrl%/}"
    jiraUrl="$atlassianUrl"
    confluenceUrl="$atlassianUrl/wiki"

    echo -e "  ${GRAY}Jira: $jiraUrl${NC}"
    echo -e "  ${GRAY}Confluence: $confluenceUrl${NC}"
    echo ""
    read -p "Email: " email < /dev/tty
    read -p "API Token: " apiToken < /dev/tty

    # Pull Docker image
    echo ""
    echo -e "${YELLOW}[Pull] Downloading mcp-atlassian Docker image...${NC}"
    docker pull ghcr.io/sooperset/mcp-atlassian:latest 2>/dev/null
    echo -e "  ${GREEN}OK${NC}"

    # FR-S1-04: Secure credential storage in .env file
    ENV_DIR="$HOME/.atlassian-mcp"
    ENV_FILE="$ENV_DIR/credentials.env"

    mkdir -p "$ENV_DIR"
    chmod 700 "$ENV_DIR"

    # Write credentials to env file (owner-only read/write)
    cat > "$ENV_FILE" << ENVEOF
CONFLUENCE_URL=$confluenceUrl
CONFLUENCE_USERNAME=$email
CONFLUENCE_API_TOKEN=$apiToken
JIRA_URL=$jiraUrl
JIRA_USERNAME=$email
JIRA_API_TOKEN=$apiToken
ENVEOF
    chmod 600 "$ENV_FILE"
    echo -e "  ${GREEN}Credentials saved to $ENV_FILE (permissions: 600)${NC}"

    # FR-S1-09: Use env vars for Node.js (no shell interpolation of user input)
    # FR-S2-03: Unified MCP config path
    # FR-S3-05a: Use shared mcp_add_docker_server utility
    echo ""
    echo -e "${YELLOW}[Config] Updating MCP config...${NC}"

    mcp_add_docker_server "atlassian" "ghcr.io/sooperset/mcp-atlassian:latest" "--env-file" "$ENV_FILE"
    mcp_add_permission "mcp__atlassian"

else
    # ========================================
    # ROVO MCP (Official Atlassian SSE)
    # ========================================
    echo ""
    echo -e "${YELLOW}Setting up Atlassian Rovo MCP...${NC}"
    echo ""
    echo "A browser will open for Atlassian login."
    echo "Please login and authorize the access."
    echo ""

    CLI_CMD="${CLI_TYPE:-claude}"
    $CLI_CMD mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse

    echo ""
    echo -e "  ${GREEN}Rovo MCP setup complete!${NC}"
    echo ""
    echo -e "${GRAY}Guide: https://support.atlassian.com/atlassian-rovo-mcp-server/${NC}"
fi

# Remove atlassian from disabledMcpjsonServers in all project settings
echo ""
echo -e "${YELLOW}[Fix] Removing project-level blocks...${NC}"
FIXED_COUNT=0
while IFS= read -r -d '' SETTINGS_FILE; do
    if grep -q 'disabledMcpjsonServers' "$SETTINGS_FILE" 2>/dev/null && grep -q '"atlassian"' "$SETTINGS_FILE" 2>/dev/null; then
        if command -v python3 > /dev/null 2>&1; then
            python3 - "$SETTINGS_FILE" << 'PYEOF'
import json, sys
path = sys.argv[1]
with open(path, 'r') as f:
    data = json.load(f)
if 'disabledMcpjsonServers' in data:
    data['disabledMcpjsonServers'] = [s for s in data['disabledMcpjsonServers'] if s != 'atlassian']
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
            [ $? -eq 0 ] && FIXED_COUNT=$((FIXED_COUNT + 1))
        elif command -v node > /dev/null 2>&1; then
            node -e "
const fs=require('fs'),p=process.argv[1];
const j=JSON.parse(fs.readFileSync(p,'utf8'));
if(j.disabledMcpjsonServers) j.disabledMcpjsonServers=j.disabledMcpjsonServers.filter(s=>s!=='atlassian');
fs.writeFileSync(p,JSON.stringify(j,null,2));" "$SETTINGS_FILE" 2>/dev/null && FIXED_COUNT=$((FIXED_COUNT + 1))
        fi
    fi
done < <(find "$HOME" -name "settings.local.json" -path "*/.claude/*" -print0 2>/dev/null)
if [ "$FIXED_COUNT" -gt 0 ]; then
    echo -e "  ${GREEN}Fixed $FIXED_COUNT project(s)${NC}"
else
    echo -e "  ${GREEN}OK (no blocks found)${NC}"
fi

echo ""
echo "----------------------------------------"
echo -e "${GREEN}Atlassian MCP installation complete!${NC}"
