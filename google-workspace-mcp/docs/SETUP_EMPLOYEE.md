# Google Workspace MCP - Employee Setup Guide

> This is a simple guide for employees to get started, assuming an admin has already completed the initial setup.

---

## What You Need

Files to receive from your admin:
- [ ] `client_secret.json` file
- [ ] `.mcp.json` configuration file (or the configuration content)

Software to install:
- [ ] Docker Desktop

---

## Setup Instructions (5 minutes)

### Step 1: Install Docker Desktop

Skip this step if already installed.

**Windows:**
1. Go to https://www.docker.com/products/docker-desktop/
2. Click **Download for Windows**
3. After installation, **restart your computer**
4. Launch Docker Desktop

**Mac:**
1. Go to https://www.docker.com/products/docker-desktop/
2. Click **Download for Mac**
3. After installation, launch Docker Desktop

---

### Step 2: Create Folder and Place Files

#### Windows

1. Open File Explorer
2. Navigate to `C:\Users\{YourName}`
3. Create a `.google-workspace` folder
4. Place the `client_secret.json` file received from your admin into that folder

```
C:\Users\{YourName}\
└── .google-workspace\
    └── client_secret.json    ← Place it here
```

#### Mac

In Terminal:
```bash
mkdir -p ~/.google-workspace
```

Place the `client_secret.json` file received from your admin into the `~/.google-workspace/` folder

---

### Step 3: Get the Docker Image

Check with your admin on how to get the Docker image.

**Option A: Pull from company registry**
```bash
docker pull {company-registry}/google-workspace-mcp
```

**Option B: Load from a file**
```bash
docker load -i google-workspace-mcp.tar
```

**Option C: Build it yourself**
```bash
cd google-workspace-mcp
docker build -t google-workspace-mcp .
```

---

### Step 4: Configure Claude

#### If using VS Code

Create a `.mcp.json` file in your project folder (your admin will share the content):

**Windows:**
```json
{
  "mcpServers": {
    "google-workspace": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "C:/Users/{YourName}/.google-workspace:/app/.google-workspace",
        "google-workspace-mcp"
      ]
    }
  }
}
```

**Mac:**
```json
{
  "mcpServers": {
    "google-workspace": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "/Users/{YourName}/.google-workspace:/app/.google-workspace",
        "google-workspace-mcp"
      ]
    }
  }
}
```

> Replace **{YourName}** with your computer username.

#### If using Claude Desktop

Configuration file location:
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`
- Mac: `~/Library/Application Support/Claude/claude_desktop_config.json`

Create/edit the file with the same content as above.

---

### Step 5: Initial Login

1. Restart VS Code or Claude Desktop
2. Enter any Google-related command in Claude:
   ```
   Show my calendar events
   ```
3. When the browser opens, log in with **your company account**
4. Grant permissions
5. Done!

---

## Usage Examples

```
"Show my calendar events"
"Send an email to test@company.com"
"Find the proposal on Drive"
"Create a new document"
"Find free time slots this week"
```

---

## Troubleshooting

### "Docker not found" error

→ Make sure Docker Desktop is running
→ Launch Docker Desktop and try again

### "client_secret.json file not found" error

→ Check the file path
→ Verify the file exists in the `.google-workspace` folder
→ Make sure the path in `.mcp.json` is correct

### Login screen does not appear

→ Make sure Docker Desktop is running
→ Restart VS Code / Claude Desktop

### "Only internal users can access this app" error

→ You must log in with your company account (@yourdomain.com)
→ You cannot log in with a personal Gmail account

---

## Need Help?

If you encounter issues during setup, contact your admin.

**Information to provide:**
- Which step the issue occurred at
- Error message (screenshot if available)
- Whether you are on Windows or Mac
