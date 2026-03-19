# Google Workspace MCP Setup Guide (Manual Setup for Developers)

> Regular users should use the [ADW Installer](../README.md).
> This guide is for those who want to build/develop the Google MCP manually.

## Step 1: Google Cloud Console Setup

### 1.1 Create a Project
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Click the project selector at the top → "New Project"
3. Project name: `google-workspace-mcp` (or any name you prefer)
4. Click "Create"

### 1.2 Enable APIs
1. Left menu → "APIs & Services" → "Library"
2. Search for and enable each of the following APIs by clicking "Enable":
   - Gmail API
   - Google Calendar API
   - Google Drive API
   - Google Docs API
   - Google Sheets API
   - Google Slides API

### 1.3 Configure OAuth Consent Screen
1. Left menu → "OAuth consent screen"
2. User Type: Select "Internal" (for company accounts) or "External"
3. Enter app information:
   - App name: `Google Workspace MCP`
   - User support email: Your email
   - Developer contact: Your email
4. "Save and Continue"
5. Add Scopes → Click "Add or Remove Scopes":
   ```
   https://www.googleapis.com/auth/gmail.modify
   https://www.googleapis.com/auth/calendar
   https://www.googleapis.com/auth/drive
   https://www.googleapis.com/auth/documents
   https://www.googleapis.com/auth/spreadsheets
   https://www.googleapis.com/auth/presentations
   ```
6. "Save and Continue" → "Back to Dashboard"

### 1.4 Create OAuth Client ID
1. Left menu → "Credentials"
2. Click "+ Create Credentials" at the top → "OAuth client ID"
3. Application type: "Desktop app"
4. Name: `Google Workspace MCP Client`
5. Click "Create"
6. Click **"Download JSON"** → Save the `client_secret_xxx.json` file

---

## Step 2: Project Setup

### 2.1 Create Configuration Folder
```bash
# In the project folder
mkdir .google-workspace
```

### 2.2 Copy client_secret.json
Copy the downloaded JSON file to `.google-workspace/client_secret.json`:
```bash
cp ~/Downloads/client_secret_xxx.json .google-workspace/client_secret.json
```

### 2.3 Install Dependencies
```bash
npm install
```

### 2.4 Build
```bash
npm run build
```

---

## Step 3: First Run (Login)

```bash
npm run dev
```

1. A browser will open automatically
2. Select your Google account
3. Click "Allow"
4. Verify the "Authentication complete" page appears
5. Close the browser

The token will be automatically saved to `.google-workspace/token.json`.

---

## Step 4: Build Docker Image

```bash
docker build -t google-workspace-mcp .
```

---

## Step 5: Claude Desktop Integration

### 5.1 Create .mcp.json File (in the project folder)
```json
{
  "mcpServers": {
    "google-workspace": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "C:/path/.google-workspace:/app/.google-workspace",
        "google-workspace-mcp"
      ]
    }
  }
}
```

### 5.2 Update the Path
- Replace `C:/path/` with the actual path where your `.google-workspace` folder is located

### 5.3 Restart Claude Desktop

---

## Usage Examples

```
"Find meeting-related emails in my inbox"
"Schedule a team meeting on January 27th at 2 PM. Invite Alice and Bob"
"Create a document with today's meeting notes"
"Organize this data in a spreadsheet"
```

---

## Troubleshooting

### Token Expired
Tokens are automatically refreshed. If you encounter issues:
```bash
rm .google-workspace/token.json
npm run dev  # Log in again
```

### Permission Error
Make sure all required Scopes have been added in the OAuth consent screen.
