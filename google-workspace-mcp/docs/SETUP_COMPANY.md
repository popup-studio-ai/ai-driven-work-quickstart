# Google Workspace MCP - Company Setup Guide

> This guide explains how to set up Google Workspace MCP so that employees in a company using Google Workspace can use it.

## Advantages

| Item | Details |
|------|---------|
| User limit | Unlimited (all company employees) |
| Token expiration | None (can be used indefinitely) |
| Warning screen | None |
| Eligible accounts | @yourdomain.com only |

---

## Prerequisites

- [ ] A company using Google Workspace (e.g., @company.com email)
- [ ] Access to Google Cloud Console (company admin or your own account)
- [ ] Docker Desktop installed
- [ ] Node.js 20 or later installed

---

## Step 1: Download the Code

```bash
git clone <repository-url>
cd google-workspace-mcp
```

---

## Step 2: Google Cloud Console Setup

### 2-1. Create a Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click the project selector at the top → **New Project**
3. Enter a project name (e.g., `Google Workspace MCP`)
4. Click **Create**

### 2-2. Enable APIs

1. Left menu **APIs & Services** → **Enable APIs and Services**
2. Search for and click **Enable** for each of the following 6 APIs:

| API Name | Search Term |
|----------|-------------|
| Gmail API | gmail |
| Google Calendar API | calendar |
| Google Drive API | drive |
| Google Docs API | docs |
| Google Sheets API | sheets |
| Google Slides API | slides |

### 2-3. Configure OAuth Consent Screen

1. Left menu **Google Auth Platform** (or OAuth consent screen)
2. Click **Get Started**

#### Enter App Information

| Item | Value |
|------|-------|
| App name | `Google Workspace MCP` (or any name you prefer) |
| User support email | Select your email |
| Audience | **Internal** — Important! |
| Contact information | Enter your email |

Click **Save**

### 2-4. Data Access (Scopes) Configuration

1. Click **Data Access** in the left menu
2. Click the **Add Scope** button
3. Search for and select the following 7 scopes:

| API | Scope |
|-----|-------|
| Gmail API | `.../auth/gmail.modify` |
| Gmail API | `.../auth/gmail.send` |
| Google Calendar API | `.../auth/calendar` |
| Google Drive API | `.../auth/drive` |
| Google Docs API | `.../auth/documents` |
| Google Sheets API | `.../auth/spreadsheets` |
| Google Slides API | `.../auth/presentations` |

4. Click **Save**

### 2-5. Create OAuth Client ID

1. Click **Clients** in the left menu
2. Click **+ Create OAuth Client**
3. Configuration:

| Item | Value |
|------|-------|
| Application type | **Desktop app** |
| Name | `MCP Client` (or any name you prefer) |

4. Click **Create**

### 2-6. Download JSON

1. Click the **download icon** next to the created client
2. Rename the downloaded file to `client_secret.json`

---

## Step 3: Place the File

Create a `.google-workspace` folder in the project directory and move the JSON file into it:

```bash
mkdir .google-workspace
mv ~/Downloads/client_secret.json .google-workspace/
```

Folder structure:
```
google-workspace-mcp/
├── .google-workspace/
│   └── client_secret.json    ← Place it here
├── src/
├── package.json
└── ...
```

---

## Step 4: Build and Test

### Local Test

```bash
npm install
npm run build
npm start
```

### Google Login Test

```bash
node -e "import('./dist/auth/oauth.js').then(m => m.getGoogleServices())"
```

When the browser opens, log in with your **company account** (@yourdomain.com).

---

## Step 5: Build Docker Image

```bash
docker build -t google-workspace-mcp .
```

---

## Step 6: Claude Integration Setup

### VS Code (Claude Code)

Create a `.mcp.json` file in the project folder:

```json
{
  "mcpServers": {
    "google-workspace": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "path/.google-workspace:/app/.google-workspace",
        "google-workspace-mcp"
      ]
    }
  }
}
```

Replace **path** with your actual path.

### Claude Desktop

`%APPDATA%\Claude\claude_desktop_config.json` (Windows) or
`~/Library/Application Support/Claude/claude_desktop_config.json` (Mac):

```json
{
  "mcpServers": {
    "google-workspace": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "path/.google-workspace:/app/.google-workspace",
        "google-workspace-mcp"
      ]
    }
  }
}
```

---

## Step 7: Deploy to Employees

### What each employee needs to do

1. Install Docker Desktop
2. Get the Docker image (from company registry or build it directly)
3. Copy the `.mcp.json` file
4. **Log in with their company account** (one-time setup)

### What the admin needs to do

- Deploy the Docker image (push to company registry)
- Share configuration files
- Share the usage guide

---

## Usage Examples

In Claude:

```
"Show my calendar events"
"Send an email to koyu@company.com"
"Find the proposal on Drive"
"Create a new document"
```

---

## Troubleshooting

### "Only internal users can access this app" error

→ You attempted to log in with a non-Google Workspace account (e.g., gmail.com)
→ Log in with your company account (@yourdomain.com)

### Docker image not found

→ Make sure Docker Desktop is running
→ Run `docker build -t google-workspace-mcp .` again

### Token error

→ Delete `.google-workspace/token.json` and log in again

---

## Security Notes

**Never share these files:**
- `.google-workspace/client_secret.json` (company Client ID)
- `.google-workspace/token.json` (personal login token)

These files are included in `.gitignore`.
