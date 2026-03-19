# Feature Plan: OAuth Login Authentication

## Overview
- **Feature Name**: Google OAuth Login Authentication
- **Goal**: Authenticate with just Google login, without copying/pasting tokens

## Requirements

### User Experience
1. On first use, a Google login window opens in the browser
2. Select your account and grant permissions
3. Token is saved automatically
4. Automatic login from next time onwards

### Technical Requirements
- OAuth 2.0 Authorization Code Flow
- Automatic refresh via Refresh Token
- Token stored locally (credentials.json)

## Required Google API Scopes
```
https://www.googleapis.com/auth/gmail.modify
https://www.googleapis.com/auth/calendar
https://www.googleapis.com/auth/drive
https://www.googleapis.com/auth/documents
https://www.googleapis.com/auth/spreadsheets
https://www.googleapis.com/auth/presentations
```

## Prerequisites (User)
1. Create a project in Google Cloud Console
2. Configure OAuth consent screen
3. Create OAuth 2.0 Client ID (Desktop App)
4. Download client_secret.json

## Implementation Plan
1. Write OAuth authentication module
2. Token save/load/refresh logic
3. Authentication check on MCP server startup
