# Repo Migration Plan

> **From**: `popup-jacob/popup-claude` (master)
> **To**: `popup-studio-ai/ai-driven-work-quickstart` (main)
> **Scope**: Everything in adw/ except landing-page/ (already at `popup-studio-ai/ai-driven-work-landing`)

---

## 1. Impact Summary

| Category | Files | Count |
|----------|-------|:-----:|
| Installer scripts (BASE_URL) | install.sh, install.ps1, diagnose.sh, diagnose.ps1 | 4 |
| Docker image URL | modules/google/install.sh, install.ps1, module.json | 3 |
| Landing page (separate repo) | InstallGuide.tsx, FAQ.tsx, DiagnoseButton.tsx, Footer.tsx | 4 |
| Documentation (.md) | README, ARCHITECTURE, setup guides, test docs, analysis docs | ~10 |
| GitHub Actions | .github/workflows/test-installer.yml | 1 |
| Docker image registry | ghcr.io/popup-jacob → ghcr.io/popup-studio-ai | 1 |

---

## 2. URL Changes

### 2.1 Script BASE_URL (Critical)

Users run these commands to install — must work after migration.

| File | Line | Before | After |
|------|:----:|--------|-------|
| `installer/install.sh` | 26 | `raw.githubusercontent.com/popup-jacob/popup-claude/master/installer` | `raw.githubusercontent.com/popup-studio-ai/ai-driven-work-quickstart/main/installer` |
| `installer/install.ps1` | 57 | Same pattern | Same change |
| `installer/diagnose.sh` | 6,8 | Same pattern | Same change |
| `installer/diagnose.ps1` | 5,7 | Same pattern | Same change |

### 2.2 Docker Image URL

| File | Before | After |
|------|--------|-------|
| `modules/google/install.sh` | `ghcr.io/popup-jacob/google-workspace-mcp:latest` | `ghcr.io/popup-studio-ai/google-workspace-mcp:latest` |
| `modules/google/install.ps1` | Same | Same change |
| `modules/google/module.json` | Same | Same change |

### 2.3 Landing Page (separate repo: popup-studio-ai/ai-driven-work-landing)

| File | Content to Change |
|------|-------------------|
| `src/components/InstallGuide.tsx` | BASE_URL constant |
| `src/components/FAQ.tsx` | WINDOWS_CMD, MAC_CMD diagnose URLs |
| `src/components/DiagnoseButton.tsx` | WINDOWS_CMD, MAC_CMD diagnose URLs |
| `src/components/Footer.tsx` | GitHub repo link + display name |

### 2.4 Documentation (.md files)

All references to `popup-jacob/popup-claude` in:
- README.md
- installer/ARCHITECTURE.md
- google-workspace-mcp/README.md
- docs/SETUP_GOOGLE_INTERNAL_ADMIN.md
- docs/SETUP_GOOGLE_EXTERNAL_ADMIN.md
- docs/02-design/security-spec.md
- docs/02-design/features/comprehensive-test-design.md
- docs/03-analysis/adw-comprehensive.analysis.md
- docs/03-analysis/security-verification-report.md
- docs/05-testing/manual-test-checklist.md
- docs/02-design/features/sprint-5-implementation-roadmap.md

---

## 3. Execution Steps (Order Matters)

### Step 1: Create new repo
- Create `popup-studio-ai/ai-driven-work-quickstart` on GitHub (public, empty, no README)
- Default branch: `main`

### Step 2: Build and push Docker image to new registry
- Build multi-arch image from `google-workspace-mcp/`
- Push to `ghcr.io/popup-studio-ai/google-workspace-mcp:latest`
- Verify: `docker pull ghcr.io/popup-studio-ai/google-workspace-mcp:latest`

```bash
cd google-workspace-mcp
docker buildx build --platform linux/amd64,linux/arm64 \
  --push -t ghcr.io/popup-studio-ai/google-workspace-mcp:latest .
```

### Step 3: Replace all URLs in adw code
- Find and replace `popup-jacob/popup-claude` → `popup-studio-ai/ai-driven-work-quickstart`
- Find and replace `ghcr.io/popup-jacob/google-workspace-mcp` → `ghcr.io/popup-studio-ai/google-workspace-mcp`
- Change branch reference `master` → `main` in all raw.githubusercontent.com URLs

### Step 4: Push to new repo
```bash
cd adw
git remote set-url origin https://github.com/popup-studio-ai/ai-driven-work-quickstart.git
git branch -M main
git push -u origin main
```

### Step 5: Update landing page (separate repo)
- Change URLs in InstallGuide.tsx, FAQ.tsx, DiagnoseButton.tsx, Footer.tsx
- Commit and push to `popup-studio-ai/ai-driven-work-landing`

### Step 6: Add redirect notice to old repo
- Update `popup-jacob/popup-claude` README with notice:
  "This repo has moved to https://github.com/popup-studio-ai/ai-driven-work-quickstart"
- Keep old repo for a transition period (existing users may reference it)

### Step 7: Test
- [ ] `curl -fsSL https://raw.githubusercontent.com/popup-studio-ai/ai-driven-work-quickstart/main/installer/install.sh | bash` works
- [ ] `powershell -ep bypass -c "irm https://raw.githubusercontent.com/popup-studio-ai/ai-driven-work-quickstart/main/installer/install.ps1 | iex"` works
- [ ] `docker pull ghcr.io/popup-studio-ai/google-workspace-mcp:latest` works
- [ ] Landing page install commands point to new URL
- [ ] Diagnose commands work from new URL

---

## 4. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Existing users have old URLs bookmarked | Install commands fail | Keep old repo with redirect notice for 3+ months |
| CDN cache on raw.githubusercontent.com | New files not available immediately | Wait ~5 min after push before testing |
| Docker image pull fails from new registry | Google MCP module install fails | Build and verify image exists BEFORE changing URLs |
| Branch rename master → main | URL 404 | Ensure new repo default branch is `main` |
| Existing users have `ghcr.io/popup-jacob/...` in MCP config | Their Google MCP keeps working (old image) | Keep old image available, or add both tags |
| GitHub Actions secrets/permissions | CI fails in new repo | Set up GHCR token and workflow permissions |

---

## 5. Rollback Plan

If something goes wrong after migration:
1. Revert URL changes in adw code
2. Push back to `popup-jacob/popup-claude`
3. Old landing page URLs still work (separate repo, unchanged)
4. Old Docker image still available at `ghcr.io/popup-jacob/...`

---

## 6. Post-Migration Cleanup

- [ ] Update MEMORY.md with new repo info
- [ ] Update .bkit/agent-state.json references
- [ ] Archive or delete `i18n-checklist.md` if no longer needed
- [ ] Verify GitHub Actions run successfully in new repo
- [ ] Update any external references (bkit.ai docs, YouTube descriptions, etc.)
