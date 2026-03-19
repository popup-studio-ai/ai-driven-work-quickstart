# ADW Improvement Project - Comprehensive Test Strategy

**Document Version:** 1.0
**Date:** 2026-02-12
**Author:** QA Strategist
**Current Test Coverage:** 0%
**Target Coverage:** 60%+ (Google MCP), 100% (Installer Smoke Tests)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Google MCP Unit Test Strategy (FR-S3-01)](#google-mcp-unit-test-strategy-fr-s3-01)
3. [Installer Smoke Test Strategy (FR-S3-02)](#installer-smoke-test-strategy-fr-s3-02)
4. [CI Test Matrix (FR-S3-03, FR-S3-04)](#ci-test-matrix-fr-s3-03-fr-s3-04)
5. [Test Case Priority Map](#test-case-priority-map)
6. [Implementation Roadmap](#implementation-roadmap)
7. [Quality Metrics and Gates](#quality-metrics-and-gates)

---

## Executive Summary

### Current State
- **Google Workspace MCP**: 0% test coverage, 450+ LOC across 6 tool files
- **Installer Scripts**: No smoke tests, 7 modules, 3 OS targets (macOS, Linux, Windows)
- **CI/CD**: Minimal workflow exists, needs test integration

### Target State
- **Unit Tests**: 60%+ coverage for Google MCP with Vitest + TypeScript ESM
- **Smoke Tests**: 100% coverage for all installer modules
- **CI Matrix**: Full OS × Module matrix testing
- **Security Tests**: P0 priority for injection vulnerabilities

### Risk Assessment
| Risk Category | Level | Mitigation |
|---------------|-------|------------|
| OAuth Security | **Critical** | P0 security tests (CSRF, token refresh) |
| API Injection | **Critical** | P0 input sanitization tests |
| Cross-platform | High | Full OS matrix in CI |
| Module Deps | High | Module ordering + dependency smoke tests |

---

## Google MCP Unit Test Strategy (FR-S3-01)

### 1.1 Test Infrastructure Setup

#### Framework Configuration
```json
// google-workspace-mcp/package.json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest watch",
    "test:coverage": "vitest run --coverage",
    "test:ui": "vitest --ui"
  },
  "devDependencies": {
    "vitest": "^1.2.0",
    "@vitest/ui": "^1.2.0",
    "@vitest/coverage-v8": "^1.2.0",
    "google-auth-library": "^9.0.0"
  }
}
```

#### Vitest Configuration
```typescript
// google-workspace-mcp/vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['src/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['src/tools/**/*.ts', 'src/auth/**/*.ts'],
      exclude: ['src/**/*.test.ts', 'src/index.ts'],
      thresholds: {
        lines: 60,
        functions: 60,
        branches: 50,
        statements: 60,
      },
    },
  },
});
```

---

### 1.2 Test File Structure

```
google-workspace-mcp/
├── src/
│   ├── tools/
│   │   ├── __tests__/
│   │   │   ├── gmail.test.ts         # 15 test cases
│   │   │   ├── drive.test.ts         # 12 test cases
│   │   │   ├── calendar.test.ts      # 10 test cases
│   │   │   ├── docs.test.ts          # 8 test cases
│   │   │   ├── sheets.test.ts        # 10 test cases
│   │   │   └── slides.test.ts        # 5 test cases
│   │   ├── gmail.ts
│   │   ├── drive.ts
│   │   └── ...
│   ├── auth/
│   │   ├── __tests__/
│   │   │   └── oauth.test.ts         # 12 test cases
│   │   └── oauth.ts
│   └── __tests__/
│       └── index.test.ts              # 6 test cases (tool registration)
├── __mocks__/
│   ├── googleapis.ts                  # Mock Google APIs
│   └── oauth2client.ts                # Mock OAuth2Client
└── vitest.config.ts
```

---

### 1.3 Gmail Tool Test Cases (gmail.ts)

**File:** `src/tools/__tests__/gmail.test.ts`

#### P0: Critical Security Tests

**TC-G01: Header Injection Prevention in gmail_send**
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { gmailTools } from '../gmail';

describe('gmail_send - Security', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should prevent CRLF injection in subject', async () => {
    const maliciousSubject = 'Test\r\nBcc: attacker@evil.com';

    const mockSend = vi.fn().mockResolvedValue({ data: { id: 'msg123' } });
    vi.mocked(getGoogleServices).mockResolvedValue({
      gmail: { users: { messages: { send: mockSend } } },
    });

    await gmailTools.gmail_send.handler({
      to: 'user@example.com',
      subject: maliciousSubject,
      body: 'Test',
    });

    const rawMessage = mockSend.mock.calls[0][0].requestBody.raw;
    const decoded = Buffer.from(rawMessage, 'base64url').toString();

    // Should NOT contain attacker email in Bcc
    expect(decoded).not.toContain('Bcc: attacker@evil.com');
    // Should sanitize CRLF
    expect(decoded.match(/\r\n\r\n/g)?.length).toBe(1); // Only one body separator
  });

  it('should prevent header injection via To field', async () => {
    const maliciousTo = 'user@example.com\r\nCc: attacker@evil.com';

    await expect(
      gmailTools.gmail_send.handler({
        to: maliciousTo,
        subject: 'Test',
        body: 'Test',
      })
    ).rejects.toThrow(/Invalid email/);
  });
});
```

**TC-G02: Email Address Validation**
```typescript
describe('gmail_send - Input Validation', () => {
  it('should reject invalid email formats', async () => {
    const invalidEmails = [
      'not-an-email',
      'missing@domain',
      '@nodomain.com',
      'spaces in@email.com',
      'semicolon;inject@test.com',
    ];

    for (const email of invalidEmails) {
      await expect(
        gmailTools.gmail_send.handler({
          to: email,
          subject: 'Test',
          body: 'Test',
        })
      ).rejects.toThrow(/Invalid email/);
    }
  });

  it('should accept valid email formats', async () => {
    const validEmails = [
      'user@example.com',
      'user.name@example.co.uk',
      'user+tag@example.com',
    ];

    const mockSend = vi.fn().mockResolvedValue({ data: { id: 'msg123' } });
    vi.mocked(getGoogleServices).mockResolvedValue({
      gmail: { users: { messages: { send: mockSend } } },
    });

    for (const email of validEmails) {
      await expect(
        gmailTools.gmail_send.handler({
          to: email,
          subject: 'Test',
          body: 'Test',
        })
      ).resolves.toBeDefined();
    }
  });
});
```

#### P1: Core Functionality Tests

**TC-G03: gmail_read MIME Parsing**
```typescript
describe('gmail_read - MIME Parsing', () => {
  it('should parse multipart/alternative with text/plain', async () => {
    const mockMessage = {
      data: {
        id: 'msg123',
        payload: {
          headers: [
            { name: 'From', value: 'sender@test.com' },
            { name: 'Subject', value: 'Test' },
          ],
          parts: [
            {
              mimeType: 'text/plain',
              body: { data: Buffer.from('Plain text body').toString('base64') },
            },
            {
              mimeType: 'text/html',
              body: { data: Buffer.from('<p>HTML body</p>').toString('base64') },
            },
          ],
        },
      },
    };

    vi.mocked(getGoogleServices).mockResolvedValue({
      gmail: { users: { messages: { get: vi.fn().mockResolvedValue(mockMessage) } } },
    });

    const result = await gmailTools.gmail_read.handler({ messageId: 'msg123' });

    expect(result.body).toBe('Plain text body');
  });

  it('should handle single-part message', async () => {
    const mockMessage = {
      data: {
        id: 'msg123',
        payload: {
          headers: [],
          body: { data: Buffer.from('Direct body').toString('base64') },
        },
      },
    };

    vi.mocked(getGoogleServices).mockResolvedValue({
      gmail: { users: { messages: { get: vi.fn().mockResolvedValue(mockMessage) } } },
    });

    const result = await gmailTools.gmail_read.handler({ messageId: 'msg123' });

    expect(result.body).toBe('Direct body');
  });
});
```

**TC-G04: Attachment Truncation**
```typescript
describe('gmail_read - Attachment Handling', () => {
  it('should truncate body to 5000 characters', async () => {
    const longBody = 'A'.repeat(10000);
    const mockMessage = {
      data: {
        id: 'msg123',
        payload: {
          headers: [],
          body: { data: Buffer.from(longBody).toString('base64') },
        },
      },
    };

    vi.mocked(getGoogleServices).mockResolvedValue({
      gmail: { users: { messages: { get: vi.fn().mockResolvedValue(mockMessage) } } },
    });

    const result = await gmailTools.gmail_read.handler({ messageId: 'msg123' });

    expect(result.body.length).toBe(5000);
  });

  it('should extract attachment metadata', async () => {
    const mockMessage = {
      data: {
        id: 'msg123',
        payload: {
          headers: [],
          parts: [
            {
              filename: 'document.pdf',
              mimeType: 'application/pdf',
              body: { attachmentId: 'att123', size: 50000 },
            },
          ],
        },
      },
    };

    vi.mocked(getGoogleServices).mockResolvedValue({
      gmail: { users: { messages: { get: vi.fn().mockResolvedValue(mockMessage) } } },
    });

    const result = await gmailTools.gmail_read.handler({ messageId: 'msg123' });

    expect(result.attachments).toHaveLength(1);
    expect(result.attachments[0]).toEqual({
      filename: 'document.pdf',
      mimeType: 'application/pdf',
      attachmentId: 'att123',
      size: 50000,
    });
  });
});
```

#### P2: Edge Case Tests

**TC-G05: Gmail Search Query Edge Cases**
```typescript
describe('gmail_search - Edge Cases', () => {
  it('should handle empty search results', async () => {
    vi.mocked(getGoogleServices).mockResolvedValue({
      gmail: { users: { messages: { list: vi.fn().mockResolvedValue({ data: {} }) } } },
    });

    const result = await gmailTools.gmail_search.handler({
      query: 'nonexistent',
      maxResults: 10,
    });

    expect(result.total).toBe(0);
    expect(result.messages).toEqual([]);
  });

  it('should respect maxResults limit', async () => {
    const mockList = vi.fn().mockResolvedValue({
      data: {
        messages: Array(20).fill({ id: 'msg' }),
      },
    });

    vi.mocked(getGoogleServices).mockResolvedValue({
      gmail: { users: { messages: { list: mockList, get: vi.fn() } } },
    });

    await gmailTools.gmail_search.handler({ query: 'test', maxResults: 5 });

    expect(mockList).toHaveBeenCalledWith(
      expect.objectContaining({ maxResults: 5 })
    );
  });
});
```

**Total Gmail Tests:** 15 test cases

---

### 1.4 Drive Tool Test Cases (drive.ts)

**File:** `src/tools/__tests__/drive.test.ts`

#### P0: Critical Security Tests

**TC-D01: Query Escaping in drive_search**
```typescript
describe('drive_search - Security', () => {
  it('should escape single quotes in query', async () => {
    const maliciousQuery = "test' or trashed = true or name contains '";

    const mockList = vi.fn().mockResolvedValue({ data: { files: [] } });
    vi.mocked(getGoogleServices).mockResolvedValue({
      drive: { files: { list: mockList } },
    });

    await gmailTools.drive_search.handler({ query: maliciousQuery, maxResults: 10 });

    const actualQuery = mockList.mock.calls[0][0].q;

    // Should escape quotes
    expect(actualQuery).toContain("\\'");
    // Should NOT allow SQL-like injection
    expect(actualQuery).not.toContain("or trashed = true");
  });

  it('should prevent directory traversal in query', async () => {
    const traversalQuery = "../../../etc/passwd";

    const mockList = vi.fn().mockResolvedValue({ data: { files: [] } });
    vi.mocked(getGoogleServices).mockResolvedValue({
      drive: { files: { list: mockList } },
    });

    await gmailTools.drive_search.handler({ query: traversalQuery, maxResults: 10 });

    const actualQuery = mockList.mock.calls[0][0].q;
    expect(actualQuery).toContain(traversalQuery); // Treated as literal search
    expect(actualQuery).toContain("trashed = false"); // Security constraint
  });
});
```

**TC-D02: FolderId Validation in drive_list**
```typescript
describe('drive_list - Security', () => {
  it('should sanitize folderId parameter', async () => {
    const maliciousFolderId = "root' or '1'='1";

    const mockList = vi.fn().mockResolvedValue({ data: { files: [] } });
    vi.mocked(getGoogleServices).mockResolvedValue({
      drive: { files: { list: mockList } },
    });

    await gmailTools.drive_list.handler({
      folderId: maliciousFolderId,
      maxResults: 20,
      orderBy: 'modifiedTime desc',
    });

    const actualQuery = mockList.mock.calls[0][0].q;

    // Should escape quotes
    expect(actualQuery).toContain("\\'");
  });
});
```

#### P1: Core Functionality Tests

**TC-D03: Shared Drive Support**
```typescript
describe('drive_search - Shared Drive Support', () => {
  it('should search in all drives including shared drives', async () => {
    const mockList = vi.fn().mockResolvedValue({ data: { files: [] } });
    vi.mocked(getGoogleServices).mockResolvedValue({
      drive: { files: { list: mockList } },
    });

    await gmailTools.drive_search.handler({ query: 'test', maxResults: 10 });

    expect(mockList).toHaveBeenCalledWith(
      expect.objectContaining({
        supportsAllDrives: true,
        includeItemsFromAllDrives: true,
        corpora: 'allDrives',
      })
    );
  });
});
```

**TC-D04: File Metadata Extraction**
```typescript
describe('drive_get_file - Metadata', () => {
  it('should extract all required metadata fields', async () => {
    const mockFile = {
      data: {
        id: 'file123',
        name: 'test.pdf',
        mimeType: 'application/pdf',
        createdTime: '2026-01-01T00:00:00Z',
        modifiedTime: '2026-01-02T00:00:00Z',
        webViewLink: 'https://drive.google.com/file/d/file123',
        size: '1024',
        owners: [{ emailAddress: 'owner@test.com' }],
        parents: ['folder123'],
        shared: true,
      },
    };

    vi.mocked(getGoogleServices).mockResolvedValue({
      drive: { files: { get: vi.fn().mockResolvedValue(mockFile) } },
    });

    const result = await gmailTools.drive_get_file.handler({ fileId: 'file123' });

    expect(result).toEqual({
      id: 'file123',
      name: 'test.pdf',
      type: 'application/pdf',
      createdTime: '2026-01-01T00:00:00Z',
      modifiedTime: '2026-01-02T00:00:00Z',
      link: 'https://drive.google.com/file/d/file123',
      size: '1024',
      owners: ['owner@test.com'],
      parentId: 'folder123',
      shared: true,
    });
  });
});
```

**Total Drive Tests:** 12 test cases

---

### 1.5 Calendar Tool Test Cases (calendar.ts)

**File:** `src/tools/__tests__/calendar.test.ts`

#### P1: Core Functionality Tests

**TC-C01: Timezone Handling**
```typescript
describe('calendar_create_event - Timezone', () => {
  it('should use Asia/Seoul timezone for parseTime', async () => {
    const mockInsert = vi.fn().mockResolvedValue({
      data: { id: 'event123', htmlLink: 'https://...' },
    });

    vi.mocked(getGoogleServices).mockResolvedValue({
      calendar: { events: { insert: mockInsert } },
    });

    await calendarTools.calendar_create_event.handler({
      title: 'Test Event',
      startTime: '2026-02-15 14:00',
      endTime: '2026-02-15 15:00',
      calendarId: 'primary',
      sendNotifications: false,
    });

    const event = mockInsert.mock.calls[0][0].requestBody;

    expect(event.start.timeZone).toBe('Asia/Seoul');
    expect(event.end.timeZone).toBe('Asia/Seoul');
    expect(event.start.dateTime).toBe('2026-02-15T14:00:00+09:00');
  });

  it('should handle ISO format timestamps', async () => {
    const mockInsert = vi.fn().mockResolvedValue({
      data: { id: 'event123', htmlLink: 'https://...' },
    });

    vi.mocked(getGoogleServices).mockResolvedValue({
      calendar: { events: { insert: mockInsert } },
    });

    await calendarTools.calendar_create_event.handler({
      title: 'Test Event',
      startTime: '2026-02-15T14:00:00+09:00',
      endTime: '2026-02-15T15:00:00+09:00',
      calendarId: 'primary',
      sendNotifications: false,
    });

    const event = mockInsert.mock.calls[0][0].requestBody;

    expect(event.start.dateTime).toBe('2026-02-15T14:00:00+09:00');
  });
});
```

**TC-C02: parseTime Function Testing**
```typescript
describe('parseTime utility', () => {
  const parseTime = (timeStr: string) => {
    if (timeStr.includes('T')) return timeStr;
    const [date, time] = timeStr.split(' ');
    return `${date}T${time}:00+09:00`;
  };

  it('should parse YYYY-MM-DD HH:mm format', () => {
    expect(parseTime('2026-02-15 14:30')).toBe('2026-02-15T14:30:00+09:00');
  });

  it('should pass through ISO format', () => {
    expect(parseTime('2026-02-15T14:30:00+09:00')).toBe('2026-02-15T14:30:00+09:00');
  });

  it('should handle edge case: midnight', () => {
    expect(parseTime('2026-02-15 00:00')).toBe('2026-02-15T00:00:00+09:00');
  });
});
```

**TC-C03: All-Day Event Handling**
```typescript
describe('calendar_create_all_day_event', () => {
  it('should create single-day all-day event', async () => {
    const mockInsert = vi.fn().mockResolvedValue({
      data: { id: 'event123', htmlLink: 'https://...' },
    });

    vi.mocked(getGoogleServices).mockResolvedValue({
      calendar: { events: { insert: mockInsert } },
    });

    await calendarTools.calendar_create_all_day_event.handler({
      title: 'Holiday',
      date: '2026-02-15',
      calendarId: 'primary',
    });

    const event = mockInsert.mock.calls[0][0].requestBody;

    expect(event.start.date).toBe('2026-02-15');
    expect(event.end.date).toBe('2026-02-15');
    expect(event.start.dateTime).toBeUndefined();
  });

  it('should create multi-day all-day event', async () => {
    const mockInsert = vi.fn().mockResolvedValue({
      data: { id: 'event123', htmlLink: 'https://...' },
    });

    vi.mocked(getGoogleServices).mockResolvedValue({
      calendar: { events: { insert: mockInsert } },
    });

    await calendarTools.calendar_create_all_day_event.handler({
      title: 'Conference',
      date: '2026-02-15',
      endDate: '2026-02-17',
      calendarId: 'primary',
    });

    const event = mockInsert.mock.calls[0][0].requestBody;

    expect(event.start.date).toBe('2026-02-15');
    expect(event.end.date).toBe('2026-02-17');
  });
});
```

**Total Calendar Tests:** 10 test cases

---

### 1.6 OAuth Tool Test Cases (oauth.ts)

**File:** `src/auth/__tests__/oauth.test.ts`

#### P0: Critical Security Tests

**TC-O01: Token Refresh Flow**
```typescript
describe('getAuthenticatedClient - Token Refresh', () => {
  it('should refresh expired token automatically', async () => {
    const expiredToken = {
      access_token: 'old_token',
      refresh_token: 'refresh_token_123',
      scope: 'https://www.googleapis.com/auth/gmail.modify',
      token_type: 'Bearer',
      expiry_date: Date.now() - 1000, // Expired 1 second ago
    };

    const mockRefreshAccessToken = vi.fn().mockResolvedValue({
      credentials: {
        access_token: 'new_token',
        refresh_token: 'refresh_token_123',
        expiry_date: Date.now() + 3600000,
      },
    });

    vi.spyOn(fs, 'existsSync').mockReturnValue(true);
    vi.spyOn(fs, 'readFileSync').mockReturnValue(JSON.stringify(expiredToken));
    vi.spyOn(fs, 'writeFileSync').mockImplementation(() => {});

    const mockOAuth2Client = {
      setCredentials: vi.fn(),
      refreshAccessToken: mockRefreshAccessToken,
    };

    vi.spyOn(google.auth, 'OAuth2').mockReturnValue(mockOAuth2Client as any);

    await getAuthenticatedClient();

    expect(mockRefreshAccessToken).toHaveBeenCalled();
    expect(fs.writeFileSync).toHaveBeenCalledWith(
      expect.stringContaining('token.json'),
      expect.stringContaining('new_token')
    );
  });

  it('should re-authenticate if refresh fails', async () => {
    const expiredToken = {
      access_token: 'old_token',
      refresh_token: 'invalid_refresh',
      expiry_date: Date.now() - 1000,
    };

    const mockRefreshAccessToken = vi
      .fn()
      .mockRejectedValue(new Error('Invalid refresh token'));

    const mockGetTokenFromBrowser = vi.fn().mockResolvedValue({
      access_token: 'new_token',
      refresh_token: 'new_refresh',
      expiry_date: Date.now() + 3600000,
    });

    vi.spyOn(fs, 'existsSync').mockReturnValue(true);
    vi.spyOn(fs, 'readFileSync').mockReturnValue(JSON.stringify(expiredToken));
    vi.spyOn(fs, 'writeFileSync').mockImplementation(() => {});

    // Mock OAuth flow
    vi.mocked(getTokenFromBrowser).mockImplementation(mockGetTokenFromBrowser);

    await getAuthenticatedClient();

    expect(mockGetTokenFromBrowser).toHaveBeenCalled();
  });
});
```

**TC-O02: State Parameter Validation (CSRF Protection)**
```typescript
describe('OAuth Flow - CSRF Protection', () => {
  it('should generate unique state parameter for each auth request', async () => {
    const mockGenerateAuthUrl = vi.fn((options) => {
      return `https://accounts.google.com/o/oauth2/v2/auth?state=${options.state}`;
    });

    const mockOAuth2Client = {
      generateAuthUrl: mockGenerateAuthUrl,
    };

    vi.spyOn(google.auth, 'OAuth2').mockReturnValue(mockOAuth2Client as any);

    // First request
    await getTokenFromBrowser(mockOAuth2Client as any);
    const state1 = mockGenerateAuthUrl.mock.calls[0][0].state;

    // Second request
    await getTokenFromBrowser(mockOAuth2Client as any);
    const state2 = mockGenerateAuthUrl.mock.calls[1][0].state;

    expect(state1).toBeDefined();
    expect(state2).toBeDefined();
    expect(state1).not.toBe(state2);
  });

  it('should validate state parameter in callback', async () => {
    // This test requires implementing state validation
    // Currently NOT implemented in oauth.ts - this is a security gap!

    const expectedState = 'random_state_123';
    const maliciousCallback = `/callback?code=auth_code&state=different_state`;

    // TODO: Implement state validation
    // expect(() => validateCallback(maliciousCallback, expectedState)).toThrow(/State mismatch/);
  });
});
```

**TC-O03: Concurrent Authentication Requests**
```typescript
describe('OAuth Flow - Concurrency', () => {
  it('should handle concurrent auth requests safely', async () => {
    const mockServerListen = vi.fn((port, callback) => callback());
    const mockServerClose = vi.fn((callback) => callback?.());

    const server = {
      listen: mockServerListen,
      close: mockServerClose,
    };

    vi.spyOn(http, 'createServer').mockReturnValue(server as any);

    const promises = [
      getTokenFromBrowser(mockOAuth2Client as any),
      getTokenFromBrowser(mockOAuth2Client as any),
    ];

    await expect(Promise.race(promises)).rejects.toThrow(/Port.*already in use/);
  });
});
```

**Total OAuth Tests:** 12 test cases

---

### 1.7 Tool Registration Test Cases (index.ts)

**File:** `src/__tests__/index.test.ts`

**TC-I01: Tool Registration Completeness**
```typescript
describe('MCP Server - Tool Registration', () => {
  it('should register all Gmail tools', () => {
    const registeredTools = Object.keys(allTools).filter((name) =>
      name.startsWith('gmail_')
    );

    expect(registeredTools).toContain('gmail_search');
    expect(registeredTools).toContain('gmail_read');
    expect(registeredTools).toContain('gmail_send');
    expect(registeredTools).toHaveLength(14); // Total Gmail tools
  });

  it('should register all Drive tools', () => {
    const registeredTools = Object.keys(allTools).filter((name) =>
      name.startsWith('drive_')
    );

    expect(registeredTools).toHaveLength(15); // Total Drive tools
  });

  it('should have unique tool names', () => {
    const toolNames = Object.keys(allTools);
    const uniqueNames = new Set(toolNames);

    expect(toolNames.length).toBe(uniqueNames.size);
  });
});
```

**TC-I02: Error Handling**
```typescript
describe('MCP Server - Error Handling', () => {
  it('should return error response on handler failure', async () => {
    const mockHandler = vi.fn().mockRejectedValue(new Error('API Error'));

    const toolWithError = {
      description: 'Test tool',
      schema: {},
      handler: mockHandler,
    };

    server.tool('test_tool', toolWithError.description, toolWithError.schema, async (params) => {
      try {
        const result = await toolWithError.handler(params);
        return { content: [{ type: 'text', text: JSON.stringify(result) }] };
      } catch (error: any) {
        return {
          content: [{ type: 'text', text: `Error: ${error.message}` }],
          isError: true,
        };
      }
    });

    const response = await server.callTool('test_tool', {});

    expect(response.isError).toBe(true);
    expect(response.content[0].text).toContain('API Error');
  });
});
```

**Total Index Tests:** 6 test cases

---

### 1.8 Mock Strategy

#### Mock File Structure

**File:** `__mocks__/googleapis.ts`
```typescript
import { vi } from 'vitest';

export const google = {
  auth: {
    OAuth2: vi.fn(() => ({
      setCredentials: vi.fn(),
      generateAuthUrl: vi.fn(() => 'https://mock-auth-url'),
      getToken: vi.fn(async (code) => ({
        tokens: {
          access_token: 'mock_access_token',
          refresh_token: 'mock_refresh_token',
          expiry_date: Date.now() + 3600000,
        },
      })),
      refreshAccessToken: vi.fn(async () => ({
        credentials: {
          access_token: 'new_mock_token',
          refresh_token: 'mock_refresh_token',
          expiry_date: Date.now() + 3600000,
        },
      })),
    })),
  },
  gmail: vi.fn(() => ({
    users: {
      messages: {
        list: vi.fn(),
        get: vi.fn(),
        send: vi.fn(),
        modify: vi.fn(),
        trash: vi.fn(),
        untrash: vi.fn(),
        attachments: {
          get: vi.fn(),
        },
      },
      drafts: {
        list: vi.fn(),
        get: vi.fn(),
        create: vi.fn(),
        send: vi.fn(),
        delete: vi.fn(),
      },
      labels: {
        list: vi.fn(),
      },
    },
  })),
  drive: vi.fn(() => ({
    files: {
      list: vi.fn(),
      get: vi.fn(),
      create: vi.fn(),
      copy: vi.fn(),
      update: vi.fn(),
    },
    permissions: {
      create: vi.fn(),
      delete: vi.fn(),
      list: vi.fn(),
    },
    about: {
      get: vi.fn(),
    },
    comments: {
      list: vi.fn(),
      create: vi.fn(),
    },
  })),
  calendar: vi.fn(() => ({
    events: {
      list: vi.fn(),
      get: vi.fn(),
      insert: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
      patch: vi.fn(),
      quickAdd: vi.fn(),
    },
    calendarList: {
      list: vi.fn(),
    },
    freebusy: {
      query: vi.fn(),
    },
  })),
  docs: vi.fn(() => ({
    documents: {
      create: vi.fn(),
      get: vi.fn(),
      batchUpdate: vi.fn(),
    },
  })),
  sheets: vi.fn(() => ({
    spreadsheets: {
      create: vi.fn(),
      get: vi.fn(),
      batchUpdate: vi.fn(),
      values: {
        get: vi.fn(),
        batchGet: vi.fn(),
        update: vi.fn(),
        append: vi.fn(),
        clear: vi.fn(),
      },
    },
  })),
  slides: vi.fn(() => ({
    presentations: {
      create: vi.fn(),
      get: vi.fn(),
      batchUpdate: vi.fn(),
    },
  })),
};

// Auto-mock googleapis
vi.mock('googleapis', () => ({ google }));
```

**File:** `__mocks__/open.ts`
```typescript
import { vi } from 'vitest';

export default vi.fn(async (url: string) => {
  console.log(`Mock: Would open ${url}`);
  return Promise.resolve();
});
```

---

### 1.9 Test Coverage Summary

| Module | Total Tests | P0 | P1 | P2 | P3 | Target Coverage |
|--------|-------------|----|----|----|----|-----------------|
| gmail.ts | 15 | 3 | 8 | 3 | 1 | 70% |
| drive.ts | 12 | 2 | 7 | 3 | 0 | 65% |
| calendar.ts | 10 | 0 | 7 | 3 | 0 | 60% |
| docs.ts | 8 | 0 | 5 | 3 | 0 | 55% |
| sheets.ts | 10 | 0 | 7 | 3 | 0 | 60% |
| slides.ts | 5 | 0 | 3 | 2 | 0 | 50% |
| oauth.ts | 12 | 5 | 5 | 2 | 0 | 75% |
| index.ts | 6 | 0 | 4 | 2 | 0 | 80% |
| **Total** | **78** | **10** | **46** | **21** | **1** | **65%** |

---

## Installer Smoke Test Strategy (FR-S3-02)

### 2.1 Test Framework

**Simple Bash Test Framework:**
```bash
#!/bin/bash
# installer/tests/test_framework.sh

PASS_COUNT=0
FAIL_COUNT=0

assert_equals() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [ "$expected" = "$actual" ]; then
    echo "✓ PASS: $message"
    ((PASS_COUNT++))
  else
    echo "✗ FAIL: $message"
    echo "  Expected: $expected"
    echo "  Actual: $actual"
    ((FAIL_COUNT++))
  fi
}

assert_file_exists() {
  local filepath="$1"
  local message="$2"

  if [ -f "$filepath" ]; then
    echo "✓ PASS: $message"
    ((PASS_COUNT++))
  else
    echo "✗ FAIL: $message (file not found: $filepath)"
    ((FAIL_COUNT++))
  fi
}

assert_command_exists() {
  local command="$1"
  local message="$2"

  if command -v "$command" > /dev/null 2>&1; then
    echo "✓ PASS: $message"
    ((PASS_COUNT++))
  else
    echo "✗ FAIL: $message (command not found: $command)"
    ((FAIL_COUNT++))
  fi
}

print_summary() {
  echo ""
  echo "===================================="
  echo "Test Summary"
  echo "===================================="
  echo "PASS: $PASS_COUNT"
  echo "FAIL: $FAIL_COUNT"
  echo "===================================="

  if [ $FAIL_COUNT -gt 0 ]; then
    exit 1
  fi
}
```

---

### 2.2 Module JSON Validation Test

**File:** `installer/tests/test_module_json.sh`
```bash
#!/bin/bash
source "$(dirname "$0")/test_framework.sh"

echo "Testing module.json files..."

for module_json in installer/modules/*/module.json; do
  module_name=$(basename $(dirname "$module_json"))
  echo ""
  echo "Testing: $module_name/module.json"

  # Test 1: Valid JSON
  if jq empty "$module_json" 2>/dev/null; then
    assert_equals "true" "true" "$module_name: Valid JSON syntax"
  else
    assert_equals "true" "false" "$module_name: Valid JSON syntax"
    continue
  fi

  # Test 2: Required fields
  required_fields=("name" "displayName" "description" "version" "type" "order")
  for field in "${required_fields[@]}"; do
    value=$(jq -r ".$field // empty" "$module_json")
    if [ -n "$value" ]; then
      assert_equals "true" "true" "$module_name: Has required field '$field'"
    else
      assert_equals "true" "false" "$module_name: Has required field '$field'"
    fi
  done

  # Test 3: Type validation
  type=$(jq -r '.type' "$module_json")
  if [[ "$type" == "cli" || "$type" == "mcp" || "$type" == "plugin" ]]; then
    assert_equals "true" "true" "$module_name: Valid type value"
  else
    assert_equals "true" "false" "$module_name: Valid type value (got: $type)"
  fi

  # Test 4: Complexity validation
  complexity=$(jq -r '.complexity' "$module_json")
  if [[ "$complexity" == "simple" || "$complexity" == "moderate" || "$complexity" == "complex" ]]; then
    assert_equals "true" "true" "$module_name: Valid complexity value"
  else
    assert_equals "true" "false" "$module_name: Valid complexity value (got: $complexity)"
  fi

  # Test 5: MCP config validation (if type is mcp)
  if [ "$type" = "mcp" ]; then
    mcp_config=$(jq -r '.mcpConfig' "$module_json")
    if [ "$mcp_config" != "null" ]; then
      assert_equals "true" "true" "$module_name: MCP module has mcpConfig"
    else
      assert_equals "true" "false" "$module_name: MCP module has mcpConfig"
    fi
  fi
done

print_summary
```

---

### 2.3 Install Script Syntax Test

**File:** `installer/tests/test_install_syntax.sh`
```bash
#!/bin/bash
source "$(dirname "$0")/test_framework.sh"

echo "Testing install.sh syntax..."

# Test main install scripts
for script in installer/install.sh installer/install.ps1; do
  if [ -f "$script" ]; then
    echo ""
    echo "Testing: $script"

    if [[ "$script" == *.sh ]]; then
      # Bash syntax check
      if bash -n "$script" 2>/dev/null; then
        assert_equals "true" "true" "$(basename $script): Valid Bash syntax"
      else
        assert_equals "true" "false" "$(basename $script): Valid Bash syntax"
      fi
    elif [[ "$script" == *.ps1 ]]; then
      # PowerShell syntax check (if pwsh available)
      if command -v pwsh > /dev/null 2>&1; then
        if pwsh -NoProfile -NonInteractive -Command "& { \$ErrorActionPreference = 'Stop'; Get-Content '$script' | Out-Null }" 2>/dev/null; then
          assert_equals "true" "true" "$(basename $script): Valid PowerShell syntax"
        else
          assert_equals "true" "false" "$(basename $script): Valid PowerShell syntax"
        fi
      else
        echo "⊘ SKIP: $(basename $script) (pwsh not available)"
      fi
    fi
  fi
done

# Test module install scripts
for script in installer/modules/*/install.sh; do
  module_name=$(basename $(dirname "$script"))
  echo ""
  echo "Testing: $module_name/install.sh"

  if bash -n "$script" 2>/dev/null; then
    assert_equals "true" "true" "$module_name: Valid Bash syntax"
  else
    assert_equals "true" "false" "$module_name: Valid Bash syntax"
  fi

  # Check for common patterns
  if grep -q "#!/bin/bash" "$script"; then
    assert_equals "true" "true" "$module_name: Has shebang"
  else
    assert_equals "true" "false" "$module_name: Has shebang"
  fi
done

print_summary
```

---

### 2.4 JSON Parser Test (All Runtimes)

**File:** `installer/tests/test_json_parser.sh`
```bash
#!/bin/bash
source "$(dirname "$0")/test_framework.sh"

echo "Testing parse_json() function across runtimes..."

# Source the install script to get parse_json function
source installer/install.sh

test_json='{"name": "test", "version": "1.0.0", "nested": {"key": "value"}}'

# Test 1: jq (if available)
if command -v jq > /dev/null 2>&1; then
  result=$(echo "$test_json" | jq -r '.name')
  assert_equals "test" "$result" "jq: Parse simple string"

  result=$(echo "$test_json" | jq -r '.nested.key')
  assert_equals "value" "$result" "jq: Parse nested string"
fi

# Test 2: Python (if available)
if command -v python3 > /dev/null 2>&1; then
  result=$(echo "$test_json" | python3 -c "import sys, json; print(json.load(sys.stdin)['name'])")
  assert_equals "test" "$result" "Python3: Parse simple string"
fi

# Test 3: Node.js (if available)
if command -v node > /dev/null 2>&1; then
  result=$(echo "$test_json" | node -e "const data = JSON.parse(require('fs').readFileSync(0, 'utf-8')); console.log(data.name)")
  assert_equals "test" "$result" "Node.js: Parse simple string"
fi

# Test 4: Fallback grep (should work everywhere)
result=$(echo "$test_json" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
assert_equals "test" "$result" "Grep fallback: Parse simple string"

print_summary
```

---

### 2.5 Module Ordering Test

**File:** `installer/tests/test_module_ordering.sh`
```bash
#!/bin/bash
source "$(dirname "$0")/test_framework.sh"

echo "Testing module installation order..."

# Get all module orders
declare -A module_orders

for module_json in installer/modules/*/module.json; do
  module_name=$(jq -r '.name' "$module_json")
  order=$(jq -r '.order' "$module_json")
  module_orders[$module_name]=$order
done

# Test 1: base module should be order 0
assert_equals "0" "${module_orders[base]}" "base module has order 0"

# Test 2: Required modules should have lower order than optional
base_order=${module_orders[base]}
for module_json in installer/modules/*/module.json; do
  module_name=$(jq -r '.name' "$module_json")
  required=$(jq -r '.required' "$module_json")
  order=${module_orders[$module_name]}

  if [ "$required" = "true" ] && [ "$module_name" != "base" ]; then
    if [ "$order" -lt 5 ]; then
      assert_equals "true" "true" "$module_name: Required module has low order ($order < 5)"
    else
      assert_equals "true" "false" "$module_name: Required module has low order ($order >= 5)"
    fi
  fi
done

# Test 3: No duplicate orders
sorted_orders=$(printf '%s\n' "${module_orders[@]}" | sort -n)
unique_orders=$(printf '%s\n' "${module_orders[@]}" | sort -n | uniq)

if [ "$sorted_orders" = "$unique_orders" ]; then
  assert_equals "true" "true" "No duplicate order values"
else
  assert_equals "true" "false" "No duplicate order values"
fi

print_summary
```

---

### 2.6 Installer Smoke Test Summary

| Test Suite | Test File | Test Count | Purpose |
|------------|-----------|------------|---------|
| Module JSON Validation | test_module_json.sh | 7 × 7 modules = 49 | JSON syntax, required fields, type/complexity validation |
| Install Script Syntax | test_install_syntax.sh | 2 + 7 = 9 | Bash/PowerShell syntax validation |
| JSON Parser | test_json_parser.sh | 4 × 3 runtimes = 12 | Cross-runtime JSON parsing |
| Module Ordering | test_module_ordering.sh | 3 | Installation order validation |
| **Total** | | **73** | |

---

## CI Test Matrix (FR-S3-03, FR-S3-04)

### 3.1 GitHub Actions Workflow

**File:** `.github/workflows/test.yml`
```yaml
name: Comprehensive Test Suite

on:
  push:
    branches: [master, develop]
  pull_request:
    branches: [master]
  workflow_dispatch:
    inputs:
      test_type:
        description: 'Test type to run'
        type: choice
        options:
          - all
          - unit
          - installer
        default: 'all'

env:
  NODE_VERSION: '20'
  TERM: xterm
  CI: true

jobs:
  # ============================================
  # Unit Tests - Google MCP
  # ============================================
  unit-tests:
    if: ${{ github.event.inputs.test_type == 'all' || github.event.inputs.test_type == 'unit' || github.event.inputs.test_type == '' }}
    name: Unit Tests (Google MCP)
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: google-workspace-mcp/package-lock.json

      - name: Install dependencies
        working-directory: google-workspace-mcp
        run: npm ci

      - name: Run unit tests
        working-directory: google-workspace-mcp
        run: npm test

      - name: Generate coverage report
        working-directory: google-workspace-mcp
        run: npm run test:coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: ./google-workspace-mcp/coverage/coverage-final.json
          flags: unit-tests
          fail_ci_if_error: true

      - name: Check coverage thresholds
        working-directory: google-workspace-mcp
        run: |
          COVERAGE=$(jq '.total.lines.pct' coverage/coverage-summary.json)
          if (( $(echo "$COVERAGE < 60" | bc -l) )); then
            echo "❌ Coverage $COVERAGE% is below threshold 60%"
            exit 1
          else
            echo "✅ Coverage $COVERAGE% meets threshold"
          fi

  # ============================================
  # Installer Smoke Tests - OS Matrix
  # ============================================
  installer-smoke-tests:
    if: ${{ github.event.inputs.test_type == 'all' || github.event.inputs.test_type == 'installer' || github.event.inputs.test_type == '' }}
    name: Installer Smoke Tests (${{ matrix.os }})
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install jq (Ubuntu)
        if: matrix.os == 'ubuntu-latest'
        run: sudo apt-get install -y jq

      - name: Install jq (macOS)
        if: matrix.os == 'macos-latest'
        run: brew install jq

      - name: Install jq (Windows)
        if: matrix.os == 'windows-latest'
        shell: pwsh
        run: choco install jq -y

      - name: Run module JSON tests
        shell: bash
        run: |
          chmod +x installer/tests/test_framework.sh
          chmod +x installer/tests/test_module_json.sh
          bash installer/tests/test_module_json.sh

      - name: Run install script syntax tests
        shell: bash
        run: |
          chmod +x installer/tests/test_install_syntax.sh
          bash installer/tests/test_install_syntax.sh

      - name: Run JSON parser tests
        shell: bash
        run: |
          chmod +x installer/tests/test_json_parser.sh
          bash installer/tests/test_json_parser.sh

      - name: Run module ordering tests
        shell: bash
        run: |
          chmod +x installer/tests/test_module_ordering.sh
          bash installer/tests/test_module_ordering.sh

  # ============================================
  # Full Installer Test - Module Matrix
  # ============================================
  installer-full-test:
    if: ${{ github.event_name == 'workflow_dispatch' && github.event.inputs.test_type == 'all' }}
    name: Full Installer Test (${{ matrix.os }} - ${{ matrix.module }})
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest]
        module: [base, github, notion, figma, google, atlassian]
        exclude:
          # Skip google/atlassian on Ubuntu (requires Docker Desktop)
          - os: ubuntu-latest
            module: google
          - os: ubuntu-latest
            module: atlassian
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run installer
        shell: bash
        run: |
          chmod +x installer/install.sh
          MODULES='${{ matrix.module }}' bash installer/install.sh --ci

      - name: Verify installation
        shell: bash
        run: |
          echo "Verifying ${{ matrix.module }} installation..."

          # Base module checks
          if [ "${{ matrix.module }}" = "base" ]; then
            command -v node || echo "WARN: node not in PATH"
            command -v git || echo "WARN: git not in PATH"
            command -v claude || echo "WARN: claude not in PATH"
          fi

          # MCP module checks
          if [ "${{ matrix.module }}" = "google" ] || [ "${{ matrix.module }}" = "github" ]; then
            if [ -f "$HOME/.claude/mcp.json" ]; then
              echo "✓ MCP config exists"
              cat "$HOME/.claude/mcp.json"
            else
              echo "✗ MCP config missing"
              exit 1
            fi
          fi

  # ============================================
  # Security Scan
  # ============================================
  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run npm audit
        working-directory: google-workspace-mcp
        run: npm audit --audit-level=moderate
        continue-on-error: true

      - name: Run shellcheck on install scripts
        run: |
          sudo apt-get install -y shellcheck
          find installer -name "*.sh" -exec shellcheck {} \;
        continue-on-error: true

  # ============================================
  # Test Summary
  # ============================================
  test-summary:
    name: Test Summary
    runs-on: ubuntu-latest
    needs: [unit-tests, installer-smoke-tests]
    if: always()
    steps:
      - name: Check test results
        run: |
          echo "Unit Tests: ${{ needs.unit-tests.result }}"
          echo "Installer Smoke Tests: ${{ needs.installer-smoke-tests.result }}"

          if [ "${{ needs.unit-tests.result }}" != "success" ] || [ "${{ needs.installer-smoke-tests.result }}" != "success" ]; then
            echo "❌ Some tests failed"
            exit 1
          else
            echo "✅ All tests passed"
          fi
```

---

### 3.2 CI Test Decision Tree

```
┌─────────────────────────────────────────────────────────────────┐
│                     CI Test Decision Tree                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Event: Push to master/develop                                  │
│    ├─ Run: unit-tests (always)                                  │
│    ├─ Run: installer-smoke-tests (always, all OS)               │
│    └─ Run: security-scan (always)                               │
│                                                                  │
│  Event: Pull Request                                            │
│    ├─ Run: unit-tests (always)                                  │
│    ├─ Run: installer-smoke-tests (always, all OS)               │
│    └─ Run: security-scan (always)                               │
│                                                                  │
│  Event: workflow_dispatch (manual)                              │
│    ├─ test_type = 'all'                                         │
│    │   ├─ Run: unit-tests                                       │
│    │   ├─ Run: installer-smoke-tests                            │
│    │   ├─ Run: installer-full-test (OS × Module matrix)         │
│    │   └─ Run: security-scan                                    │
│    ├─ test_type = 'unit'                                        │
│    │   └─ Run: unit-tests only                                  │
│    └─ test_type = 'installer'                                   │
│        └─ Run: installer-smoke-tests only                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

### 3.3 CI Matrix Coverage

| Job | ubuntu-latest | macos-latest | windows-latest | Total Runs |
|-----|---------------|--------------|----------------|------------|
| unit-tests | ✓ | - | - | 1 |
| installer-smoke-tests | ✓ | ✓ | ✓ | 3 |
| installer-full-test (base) | ✓ | ✓ | - | 2 |
| installer-full-test (github) | ✓ | ✓ | - | 2 |
| installer-full-test (notion) | ✓ | ✓ | - | 2 |
| installer-full-test (figma) | ✓ | ✓ | - | 2 |
| installer-full-test (google) | - | ✓ | - | 1 |
| installer-full-test (atlassian) | - | ✓ | - | 1 |
| security-scan | ✓ | - | - | 1 |
| **Total** | | | | **15** |

---

## Test Case Priority Map

### Priority Definitions

| Priority | Description | Acceptance Criteria | Blocking |
|----------|-------------|---------------------|----------|
| **P0** | Critical security/data integrity | Must pass 100% | Blocks deployment |
| **P1** | Core functionality | Must pass 90%+ | Blocks release |
| **P2** | Edge cases/error handling | Should pass 80%+ | Blocks GA |
| **P3** | UX/formatting/non-critical | Nice to have | Non-blocking |

---

### Complete Test Case Inventory

#### P0: Critical Security Tests (10 tests)

| ID | Test Case | File | Risk | Impact |
|----|-----------|------|------|--------|
| TC-G01 | Header injection in gmail_send | gmail.test.ts | CSRF, Phishing | Critical |
| TC-G02 | Email address validation | gmail.test.ts | Injection | High |
| TC-D01 | Query escaping in drive_search | drive.test.ts | Data leak | Critical |
| TC-D02 | FolderId escaping in drive_list | drive.test.ts | Path traversal | High |
| TC-O01 | Token refresh flow | oauth.test.ts | Auth bypass | Critical |
| TC-O02 | State parameter validation (CSRF) | oauth.test.ts | CSRF attack | Critical |
| TC-O03 | Concurrent auth requests | oauth.test.ts | Race condition | Medium |
| TC-S01 | Input sanitization (Sheets) | sheets.test.ts | Formula injection | High |
| TC-D03 | Permission validation | docs.test.ts | Unauthorized access | High |
| TC-A01 | Attachment size limit | gmail.test.ts | DoS | Medium |

**P0 Coverage Requirement:** 100% (10/10 must pass)

---

#### P1: Core Functionality Tests (46 tests)

| Category | Tests | Coverage Target |
|----------|-------|-----------------|
| Gmail API calls | 8 | 90% |
| Drive API calls | 7 | 85% |
| Calendar timezone handling | 7 | 85% |
| Docs content manipulation | 5 | 80% |
| Sheets data operations | 7 | 85% |
| OAuth flow | 5 | 90% |
| Tool registration | 4 | 95% |
| Error handling | 3 | 80% |

**P1 Coverage Requirement:** 90%+ (42/46 must pass)

---

#### P2: Edge Case Tests (21 tests)

| Category | Tests | Examples |
|----------|-------|----------|
| Gmail edge cases | 3 | Empty results, large attachments, encoding |
| Drive edge cases | 3 | Shared drives, permissions, quota |
| Calendar edge cases | 3 | All-day events, recurring events, timezones |
| Docs edge cases | 3 | Large documents, tables, images |
| Sheets edge cases | 3 | Formula validation, large datasets |
| OAuth edge cases | 2 | Expired tokens, network errors |
| Installer edge cases | 4 | Missing deps, permission errors |

**P2 Coverage Requirement:** 80%+ (17/21 should pass)

---

#### P3: UX/Non-Critical Tests (1 test)

| ID | Test Case | Purpose |
|----|-----------|---------|
| TC-U01 | Error message formatting | User experience |

**P3 Coverage Requirement:** Best effort

---

### Test Execution Order (PDCA Flow)

```
Phase 1: Setup (Do)
├─ Install test framework (Vitest)
├─ Create mock infrastructure
└─ Setup CI workflow

Phase 2: P0 Tests (Check)
├─ Run all P0 security tests
├─ Must achieve 100% pass rate
└─ Block if any P0 fails

Phase 3: P1 Tests (Check)
├─ Run all P1 core functionality tests
├─ Must achieve 90%+ pass rate
└─ Fix critical failures

Phase 4: P2 Tests (Check)
├─ Run all P2 edge case tests
├─ Target 80%+ pass rate
└─ Document known issues

Phase 5: Coverage Analysis (Act)
├─ Generate coverage report
├─ Identify untested code paths
└─ Iterate if coverage < 60%

Phase 6: CI Integration (Act)
├─ Run full test suite in CI
├─ Validate on all OS targets
└─ Generate test report
```

---

## Implementation Roadmap

### Week 1: Test Infrastructure Setup

**Day 1-2: Framework Setup**
- [ ] Install Vitest + dependencies
- [ ] Create vitest.config.ts
- [ ] Setup test file structure
- [ ] Create mock files

**Day 3-4: P0 Security Tests**
- [ ] TC-G01: Header injection test
- [ ] TC-G02: Email validation test
- [ ] TC-D01: Query escaping test
- [ ] TC-D02: FolderId escaping test
- [ ] TC-O01: Token refresh test
- [ ] TC-O02: State parameter test

**Day 5: P0 Validation**
- [ ] Run all P0 tests
- [ ] Fix any failures
- [ ] Achieve 100% P0 pass rate

---

### Week 2: P1 Core Functionality Tests

**Day 6-8: Gmail + Drive Tests**
- [ ] TC-G03: MIME parsing test
- [ ] TC-G04: Attachment truncation test
- [ ] Gmail search/list tests
- [ ] Drive shared drive tests
- [ ] Drive metadata tests

**Day 9-10: Calendar + OAuth Tests**
- [ ] TC-C01: Timezone handling test
- [ ] TC-C02: parseTime test
- [ ] TC-C03: All-day event test
- [ ] OAuth concurrent auth test

**Day 11: P1 Validation**
- [ ] Run all P1 tests
- [ ] Target 90%+ pass rate
- [ ] Fix critical failures

---

### Week 3: P2 Edge Cases + Installer Tests

**Day 12-13: Edge Case Tests**
- [ ] Gmail edge cases
- [ ] Drive edge cases
- [ ] Calendar edge cases
- [ ] Error handling tests

**Day 14-15: Installer Smoke Tests**
- [ ] Create test_framework.sh
- [ ] Create test_module_json.sh
- [ ] Create test_install_syntax.sh
- [ ] Create test_json_parser.sh
- [ ] Create test_module_ordering.sh

**Day 16: Installer Validation**
- [ ] Run all installer tests
- [ ] Validate on macOS/Linux
- [ ] Fix syntax errors

---

### Week 4: CI Integration + Documentation

**Day 17-18: CI Workflow**
- [ ] Create .github/workflows/test.yml
- [ ] Setup OS matrix
- [ ] Setup module matrix
- [ ] Configure coverage reporting

**Day 19: CI Validation**
- [ ] Test workflow on PR
- [ ] Test workflow on push
- [ ] Test manual workflow_dispatch
- [ ] Validate coverage thresholds

**Day 20-21: Documentation + Handoff**
- [ ] Update README with test instructions
- [ ] Document test patterns
- [ ] Create test maintenance guide
- [ ] Final QA review

---

## Quality Metrics and Gates

### Coverage Gates

| Gate | Metric | Threshold | Action if Below |
|------|--------|-----------|-----------------|
| **Deployment Gate** | P0 Pass Rate | 100% | Block deployment |
| **Release Gate** | P1 Pass Rate | 90% | Block release candidate |
| **GA Gate** | Total Coverage | 60% | Delay GA |
| **GA Gate** | P2 Pass Rate | 80% | Document known issues |

---

### Test Quality Metrics

| Metric | Measurement | Target |
|--------|-------------|--------|
| Test Execution Time | Total CI runtime | < 10 minutes |
| Test Flakiness | Failed → Passed retries | < 2% |
| Code Coverage | Lines covered | 60%+ |
| Branch Coverage | Branches covered | 50%+ |
| Security Test Coverage | P0 tests / Total security risks | 100% |

---

### CI/CD Quality Gates

```yaml
# Quality gates enforced in CI
quality-gates:
  unit-tests:
    coverage:
      lines: 60%
      functions: 60%
      branches: 50%
    security-tests:
      pass-rate: 100%

  installer-tests:
    smoke-tests:
      pass-rate: 100%
    full-tests:
      pass-rate: 90%

  security-scan:
    npm-audit:
      severity: moderate
    shellcheck:
      severity: warning
```

---

## Test Maintenance Guidelines

### Adding New Tests

1. **Identify Priority:** Classify as P0/P1/P2/P3
2. **Create Test File:** Follow naming convention `*.test.ts`
3. **Write Test Case:** Use describe/it/expect pattern
4. **Add Mocks:** Update `__mocks__/googleapis.ts` if needed
5. **Update Coverage:** Verify coverage threshold still met
6. **Document:** Add to test case inventory

### Updating Existing Tests

1. **Preserve P0 Tests:** Never decrease P0 test coverage
2. **Version Lock Mocks:** Update mocks when API changes
3. **Maintain Threshold:** Keep coverage >= 60%
4. **CI Validation:** Run full CI before merging

### Test Debugging

```bash
# Run single test file
npm test -- gmail.test.ts

# Run in watch mode
npm run test:watch

# Run with coverage
npm run test:coverage

# Run with UI
npm run test:ui

# Debug specific test
npm test -- -t "should prevent CRLF injection"
```

---

## Appendix: Example Test Code Snippets

### A. Complete Gmail Test File Template

```typescript
// google-workspace-mcp/src/tools/__tests__/gmail.test.ts
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { gmailTools } from '../gmail';
import { getGoogleServices } from '../../auth/oauth';

// Mock googleapis
vi.mock('../../auth/oauth');

describe('Gmail Tools', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe('gmail_send - Security', () => {
    // TC-G01: Header injection prevention
    it('should prevent CRLF injection in subject', async () => {
      // ... (see section 1.3 for full code)
    });

    // TC-G02: Email validation
    it('should reject invalid email formats', async () => {
      // ... (see section 1.3 for full code)
    });
  });

  describe('gmail_read - MIME Parsing', () => {
    // TC-G03: Multipart MIME parsing
    it('should parse multipart/alternative with text/plain', async () => {
      // ... (see section 1.3 for full code)
    });

    // TC-G04: Attachment truncation
    it('should truncate body to 5000 characters', async () => {
      // ... (see section 1.3 for full code)
    });
  });

  describe('gmail_search - Edge Cases', () => {
    // TC-G05: Empty results
    it('should handle empty search results', async () => {
      // ... (see section 1.3 for full code)
    });
  });
});
```

---

### B. Complete Installer Test Template

```bash
#!/bin/bash
# installer/tests/test_module_json.sh

source "$(dirname "$0")/test_framework.sh"

echo "Testing module.json files..."

for module_json in installer/modules/*/module.json; do
  module_name=$(basename $(dirname "$module_json"))
  echo ""
  echo "Testing: $module_name/module.json"

  # Test 1: Valid JSON
  if jq empty "$module_json" 2>/dev/null; then
    assert_equals "true" "true" "$module_name: Valid JSON syntax"
  else
    assert_equals "true" "false" "$module_name: Valid JSON syntax"
    continue
  fi

  # ... (see section 2.2 for full code)
done

print_summary
```

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-12 | QA Strategist | Initial comprehensive test strategy |

---

**End of Test Strategy Document**
