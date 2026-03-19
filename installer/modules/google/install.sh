#!/bin/bash
# ============================================
# Google Workspace MCP Module (Mac/Linux)
# ============================================
# Prerequisites: Docker must be running

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

# ============================================
# 1. Docker Check
# ============================================
echo -e "${YELLOW}[Check] Docker is running...${NC}"
if ! docker_check; then
    exit 1
fi

# ============================================
# 2. Role Selection (Admin / Employee)
# ============================================
echo ""
echo "What is your role?"
echo "  1. Admin (first-time setup, create OAuth credentials)"
echo "  2. Employee (received client_secret.json from admin)"
echo ""
read -p "Select (1/2): " roleChoice < /dev/tty

if [ "$roleChoice" = "1" ]; then
    # ========================================
    # ADMIN PATH - Full Google Cloud Setup
    # ========================================
    echo ""
    echo -e "${CYAN}=== Google Cloud Admin Setup ===${NC}"
    echo ""

    # Check/Install gcloud CLI
    echo -e "${YELLOW}[1/6] Checking gcloud CLI...${NC}"
    if ! command -v gcloud > /dev/null 2>&1; then
        echo -e "  ${RED}gcloud CLI is not installed.${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew > /dev/null 2>&1; then
                echo -e "  ${YELLOW}Installing via Homebrew...${NC}"
                brew install --cask google-cloud-sdk
                # Source the path
                if [ -f "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc" ]; then
                    source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
                fi
            else
                curl https://sdk.cloud.google.com | bash
                echo "Please restart terminal and run again."
                exit 0
            fi
        else
            curl -sSL https://sdk.cloud.google.com | bash -s -- --disable-prompts
            source "$HOME/google-cloud-sdk/path.bash.inc"
        fi

        if ! command -v gcloud > /dev/null 2>&1; then
            echo -e "${YELLOW}gcloud installed but not in PATH. Restart terminal and run again.${NC}"
            exit 1
        fi
    fi
    echo -e "  ${GREEN}OK${NC}"

    # gcloud login (always)
    echo ""
    echo -e "${YELLOW}[2/6] Google Cloud login...${NC}"
    echo "  Opening browser for login..."
    gcloud auth login
    read -p "Press Enter after completing login" < /dev/tty

    ACCOUNT=$(gcloud config get-value account 2>/dev/null)
    if [ -z "$ACCOUNT" ] || [ "$ACCOUNT" = "(unset)" ]; then
        echo -e "${RED}Login failed or cancelled${NC}"
        exit 1
    fi
    echo -e "  ${GREEN}Logged in as: $ACCOUNT${NC}"

    # Internal vs External
    echo ""
    echo -e "${YELLOW}[3/6] Setup type selection...${NC}"
    echo ""
    echo "Do you use Google Workspace (company email)?"
    echo "  1. Yes - Internal app (unlimited, no expiry)"
    echo "  2. No - External app (100 test users, 7-day expiry)"
    echo ""
    read -p "Select (1 or 2): " appTypeChoice < /dev/tty
    if [ "$appTypeChoice" = "1" ]; then
        APP_TYPE="internal"
        echo -e "  ${GREEN}Selected: Internal${NC}"
    else
        APP_TYPE="external"
        echo -e "  ${GREEN}Selected: External${NC}"
    fi

    # Create or select project
    echo ""
    echo -e "${YELLOW}[4/6] Setting up Google Cloud project...${NC}"
    echo "  1. Create new project"
    echo "  2. Use existing project"
    echo ""
    read -p "Select (1 or 2): " projectChoice < /dev/tty

    if [ "$projectChoice" = "1" ]; then
        PROJECT_ID="workspace-mcp-$((RANDOM % 900000 + 100000))"
        echo -e "  ${YELLOW}Creating project: $PROJECT_ID${NC}"
        gcloud projects create "$PROJECT_ID" --name="Google Workspace MCP" 2>/dev/null || true
        gcloud config set project "$PROJECT_ID" 2>/dev/null
    else
        echo ""
        echo "Available projects:"
        gcloud projects list --format="table(projectId,name)" 2>/dev/null
        echo ""
        read -p "Enter project ID: " PROJECT_ID < /dev/tty
        gcloud config set project "$PROJECT_ID" 2>/dev/null
    fi
    echo -e "  ${GREEN}Project: $PROJECT_ID${NC}"

    # Enable APIs
    echo ""
    echo -e "${YELLOW}[5/6] Enabling APIs...${NC}"
    APIS=(
        "gmail.googleapis.com"
        "calendar-json.googleapis.com"
        "drive.googleapis.com"
        "docs.googleapis.com"
        "sheets.googleapis.com"
        "slides.googleapis.com"
    )
    for API in "${APIS[@]}"; do
        echo -e "  ${GRAY}Enabling $API...${NC}"
        gcloud services enable "$API" 2>/dev/null || true
    done
    echo -e "  ${GREEN}All APIs enabled!${NC}"

    # OAuth Consent Screen (Manual)
    echo ""
    echo -e "${YELLOW}[6/6] OAuth Consent Screen Setup${NC}"
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  MANUAL STEP REQUIRED${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""

    CONSOLE_URL="https://console.cloud.google.com/apis/credentials/consent?project=$PROJECT_ID"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$CONSOLE_URL"
    elif command -v xdg-open > /dev/null 2>&1; then
        xdg-open "$CONSOLE_URL"
    else
        echo -e "${YELLOW}Open this URL: $CONSOLE_URL${NC}"
    fi

    echo "Follow these steps in the browser:"
    echo ""
    echo -e "  [0] ${YELLOW}Click 'Get Started' button on the OAuth overview page${NC}"
    echo ""
    echo "  [1] App Info"
    echo "      - App name: Google Workspace MCP"
    echo "      - User support email: (select your email)"
    echo "      -> Click 'Next'"
    echo ""
    if [ "$APP_TYPE" = "internal" ]; then
        echo -e "  [2] Audience: ${YELLOW}Select 'Internal'${NC} -> Click 'Next'"
    else
        echo -e "  [2] Audience: ${YELLOW}Select 'External'${NC} -> Click 'Next'"
    fi
    echo ""
    echo "  [3] Contact Info"
    echo "      - Enter your email address"
    echo "      -> Click 'Next'"
    echo ""
    echo "  [4] Finish -> Check agreement, Click 'Continue'"
    if [ "$APP_TYPE" = "external" ]; then
        echo ""
        echo -e "  [5] ${YELLOW}Add TEST USERS in Audience section${NC}"
    fi
    echo ""
    read -p "Press Enter when consent screen is configured" < /dev/tty

    # Create OAuth Client
    echo ""
    echo "Now create OAuth Client:"
    echo "  [1] Left menu -> 'Clients'"
    echo "  [2] Click '+ Create Client'"
    echo "  [3] Type: 'Desktop app'"
    echo -e "  [4] ${YELLOW}Download JSON${NC}"
    echo ""
    echo "Save as:"
    echo -e "  ${CYAN}~/.google-workspace/client_secret.json${NC}"
    echo ""

    CONFIG_DIR="$HOME/.google-workspace"
    mkdir -p "$CONFIG_DIR"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$CONFIG_DIR"
    fi

    read -p "Press Enter when client_secret.json is saved" < /dev/tty

    echo ""
    echo -e "${GREEN}Admin setup complete!${NC}"
    echo "  - Project: $PROJECT_ID"
    echo "  - Type: $APP_TYPE"
    echo ""
fi

# ========================================
# EMPLOYEE PATH (runs for both)
# ========================================
echo ""
echo -e "${YELLOW}Setting up Google MCP...${NC}"

CONFIG_DIR="$HOME/.google-workspace"
mkdir -p "$CONFIG_DIR"

# Check client_secret.json
CLIENT_SECRET_PATH="$CONFIG_DIR/client_secret.json"
if [ ! -f "$CLIENT_SECRET_PATH" ]; then
    echo ""
    echo "client_secret.json required."
    echo -e "Copy from admin to: ${CYAN}$CLIENT_SECRET_PATH${NC}"
    echo ""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$CONFIG_DIR"
    fi
    read -p "Press Enter when file is ready" < /dev/tty

    if [ ! -f "$CLIENT_SECRET_PATH" ]; then
        echo -e "${RED}client_secret.json not found${NC}"
        exit 1
    fi
fi
echo -e "  ${GREEN}client_secret.json found${NC}"

# Pull Docker image
echo ""
echo -e "${YELLOW}[Pull] Google MCP Docker image...${NC}"
docker pull ghcr.io/popup-studio-ai/google-workspace-mcp:latest
echo -e "  ${GREEN}OK${NC}"

# OAuth authentication (always - installer runs once)
TOKEN_PATH="$CONFIG_DIR/token.json"
# Remove existing token to force re-login
if [ -f "$TOKEN_PATH" ]; then
    rm -f "$TOKEN_PATH"
fi

echo ""
echo -e "${YELLOW}Opening browser for Google login...${NC}"

# Stop any leftover Google MCP auth container
OLD_CONTAINER=$(docker ps -q --filter "ancestor=ghcr.io/popup-studio-ai/google-workspace-mcp:latest" 2>/dev/null)
if [ -n "$OLD_CONTAINER" ]; then
    docker stop "$OLD_CONTAINER" > /dev/null 2>&1
    docker rm "$OLD_CONTAINER" > /dev/null 2>&1
fi

# Find a free port for OAuth callback
AUTH_PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("",0)); print(s.getsockname()[1]); s.close()' 2>/dev/null || echo 52836)

# Run auth container in background with dynamic port
CONTAINER_ID=$(docker run -d -p "${AUTH_PORT}:${AUTH_PORT}" -e "OAUTH_PORT=$AUTH_PORT" -v "$CONFIG_DIR:/app/.google-workspace" \
    ghcr.io/popup-studio-ai/google-workspace-mcp:latest \
    node -e "require('./dist/auth/oauth.js').getAuthenticatedClient().then(() => { console.log('Authentication complete!'); process.exit(0); }).catch(e => { console.error(e); process.exit(1); })")

if [ -z "$CONTAINER_ID" ]; then
    echo -e "  ${RED}Failed to start auth container${NC}"
else
    # Poll for OAuth URL and auto-open browser
    OPENED=false
    for i in $(seq 1 60); do
        AUTH_URL=$(docker logs "$CONTAINER_ID" 2>&1 | grep -o "https://accounts.google.com/[^ ]*" | head -1)
        if [ -n "$AUTH_URL" ]; then
            if [ "$OPENED" = false ]; then
                # FR-S3-05a: Use shared browser_open utility
                browser_open "$AUTH_URL"
                echo -e "  ${GREEN}Browser opened for Google login!${NC}"
                echo ""
                echo -e "  ${GRAY}If the browser doesn't open, copy and paste this URL:${NC}"
                echo "  $AUTH_URL"
                OPENED=true
            fi
            break
        fi
        RUNNING=$(docker inspect --format='{{.State.Running}}' "$CONTAINER_ID" 2>/dev/null)
        if [ "$RUNNING" != "true" ]; then break; fi
        sleep 0.2
    done

    if [ "$OPENED" = false ]; then
        echo -e "  ${YELLOW}Could not detect login URL. Check Docker logs:${NC}"
        docker logs "$CONTAINER_ID" 2>&1
    fi

    # FR-S2-08: Wait for auth to complete with timeout (300s)
    echo -e "  ${GRAY}Waiting for login to complete (timeout: 5 min)...${NC}"
    WAIT_ELAPSED=0
    WAIT_TIMEOUT=300
    while [ $WAIT_ELAPSED -lt $WAIT_TIMEOUT ]; do
        RUNNING=$(docker inspect --format='{{.State.Running}}' "$CONTAINER_ID" 2>/dev/null)
        if [ "$RUNNING" != "true" ]; then
            break
        fi
        sleep 2
        WAIT_ELAPSED=$((WAIT_ELAPSED + 2))
    done
    if [ $WAIT_ELAPSED -ge $WAIT_TIMEOUT ]; then
        echo -e "  ${YELLOW}Auth timed out after ${WAIT_TIMEOUT}s. Stopping container...${NC}"
        docker stop "$CONTAINER_ID" > /dev/null 2>&1
    fi
    docker rm "$CONTAINER_ID" > /dev/null 2>&1
fi

if [ -f "$TOKEN_PATH" ]; then
    echo -e "  ${GREEN}Google login successful!${NC}"
else
    echo -e "  ${YELLOW}Login may have failed. Try again later.${NC}"
fi

# FR-S2-03: Update MCP config using unified path (~/.claude/mcp.json)
# FR-S3-05a: Use shared mcp_add_docker_server utility (includes legacy migration)
echo ""
echo -e "${YELLOW}[Config] Updating MCP config...${NC}"

mcp_add_docker_server "google-workspace" "ghcr.io/popup-studio-ai/google-workspace-mcp:latest" "-v" "$CONFIG_DIR:/app/.google-workspace"
mcp_add_permission "mcp__google-workspace"

# Remove google-workspace from disabledMcpjsonServers in all project settings
echo ""
echo -e "${YELLOW}[Fix] Removing project-level blocks...${NC}"
FIXED_COUNT=0
while IFS= read -r -d '' SETTINGS_FILE; do
    if grep -q 'disabledMcpjsonServers' "$SETTINGS_FILE" 2>/dev/null && grep -q '"google-workspace"' "$SETTINGS_FILE" 2>/dev/null; then
        if command -v python3 > /dev/null 2>&1; then
            python3 - "$SETTINGS_FILE" << 'PYEOF'
import json, sys
path = sys.argv[1]
with open(path, 'r') as f:
    data = json.load(f)
if 'disabledMcpjsonServers' in data:
    data['disabledMcpjsonServers'] = [s for s in data['disabledMcpjsonServers'] if s != 'google-workspace']
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
            [ $? -eq 0 ] && FIXED_COUNT=$((FIXED_COUNT + 1))
        elif command -v node > /dev/null 2>&1; then
            node -e "
const fs=require('fs'),p=process.argv[1];
const j=JSON.parse(fs.readFileSync(p,'utf8'));
if(j.disabledMcpjsonServers) j.disabledMcpjsonServers=j.disabledMcpjsonServers.filter(s=>s!=='google-workspace');
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
echo -e "${GREEN}Google MCP installation complete!${NC}"
