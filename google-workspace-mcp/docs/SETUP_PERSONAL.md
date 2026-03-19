# Google Workspace MCP - Personal Setup Guide

> This guide explains how to set up Google Workspace MCP using a personal Google account (gmail.com, etc.) or in environments without Google Workspace.

## Characteristics

| Item | Details |
|------|---------|
| User limit | 100 test users |
| Token expiration | Re-login required every 7 days |
| Warning screen | "Unverified app" warning displayed |
| Eligible accounts | Only registered test users |

---

## Prerequisites

- [ ] A Google account (gmail.com or another Google account)
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
| Audience | **External** |
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

### 2-5. Register Test Users (Important!)

1. Click **Audience** in the left menu
2. In the **Test Users** section, click **+ ADD USERS**
3. Enter your Google account email (e.g., `myemail@gmail.com`)
4. Click **Add**
5. Click **Save**

> **Note:** You will not be able to log in unless you are registered as a test user!

### 2-6. Create OAuth Client ID

1. Click **Clients** in the left menu
2. Click **+ Create OAuth Client**
3. Configuration:

| Item | Value |
|------|-------|
| Application type | **Desktop app** |
| Name | `MCP Client` (or any name you prefer) |

4. Click **Create**

### 2-7. Download JSON

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

When the browser opens:

1. Log in with the account registered as a test user
2. The **"This app isn't verified by Google"** warning will appear
3. Click **Advanced**
4. Click **Go to [App Name] (unsafe)**
5. Click **Continue** to grant permissions

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

## Usage Examples

In Claude:

```
"Show my calendar events"
"Send an email to a friend"
"Find a file on Drive"
"Create a new document"
```

---

## Re-login Every 7 Days

In test mode, the token expires after 7 days.

**How to re-login:**

1. Delete `.google-workspace/token.json`
2. Run the login test command again:
   ```bash
   node -e "import('./dist/auth/oauth.js').then(m => m.getGoogleServices())"
   ```
3. Log in again in the browser

---

## Adding Other Users

To allow other people to use the app:

1. Google Cloud Console → **Audience** → **Test Users**
2. Click **+ ADD USERS**
3. Enter the Google email of the person to add
4. Click **Save**

> **Limit:** You can register up to 100 test users

---

## Troubleshooting

### "Access blocked: This app's request is invalid" error

→ You attempted to log in with an account not registered as a test user
→ Add your email as a test user in Google Cloud Console

### "This app isn't verified by Google" screen

→ This is normal! It always appears in test mode
→ Click **Advanced** → **Go to [App Name]**

### Docker image not found

→ Make sure Docker Desktop is running
→ Run `docker build -t google-workspace-mcp .` again

### Token expiration error

→ Delete `.google-workspace/token.json`
→ Log in again

---

## Security Notes

**Never share these files:**
- `.google-workspace/client_secret.json` (your Client ID)
- `.google-workspace/token.json` (your login token)

These files are included in `.gitignore`.

---

## Switching to Production Mode

To remove test mode limitations (100 users, 7-day expiration), you need to pass Google's review.

Requirements:
- A privacy policy page (public URL)
- App description and purpose of permission usage
- Demo video (YouTube)

Review period: 2-6 weeks (varies depending on permissions)

For more details, see the [Google OAuth Review Guide](https://support.google.com/cloud/answer/9110914).
