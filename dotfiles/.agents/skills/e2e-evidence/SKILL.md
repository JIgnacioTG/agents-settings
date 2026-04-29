---
name: e2e-evidence
description: Use when validating frontend changes with Playwright E2E tests or browser automation and evidence screenshots, traces, videos, or reports must be captured and reported.
---

# E2E Evidence

Use this skill for frontend validation that needs visual proof, especially Playwright E2E testing, Playwright UI runs, and browser-driven acceptance checks.

## Evidence Folder

- Store agent-generated evidence under `.sisyphus/evidence/` because this repository convention is local-only and gitignored.
- Use a scoped subfolder such as `.sisyphus/evidence/<change-or-session>/screenshots/` for intentional screenshots.
- Keep filenames ordered and descriptive, for example `01-login-page.png`, `02-dashboard-loaded.png`, or `03-error-state.png`.

## Playwright Test Contract

- Prefer Playwright-native artifacts over ad-hoc screenshot handling.
- For intentional evidence screenshots inside Playwright tests, use `testInfo.outputPath(...)` and `page.screenshot(...)`:

```ts
const screenshotPath = testInfo.outputPath('screenshots', 'dashboard-loaded.png');
await page.screenshot({ path: screenshotPath, fullPage: true });
await testInfo.attach('dashboard-loaded', { path: screenshotPath, contentType: 'image/png' });
```

- Configure Playwright projects that need agent evidence with an artifact root under `.sisyphus/evidence`, for example `outputDir: '.sisyphus/evidence/playwright'`.
- Keep diagnostic artifacts enabled when useful: `screenshot: 'only-on-failure'`, `trace: 'on-first-retry'`, and `video: 'retain-on-failure'`.
- Use Playwright's HTML report as the human-facing evidence index when available.

## Manual Browser Validation Contract

- If validation uses browser automation outside a Playwright test file, still save screenshots under `.sisyphus/evidence/<change-or-session>/screenshots/`.
- Capture meaningful states, not just the final screen: before action, after important transitions, and final validated state.
- Prefer full-page screenshots for layout/regression checks and viewport screenshots for focused interactions.

## Final Output Contract

Frontend E2E validation is not complete unless the final response lists:

- Exact screenshot paths.
- Playwright HTML report path, if generated.
- Trace or video paths, if generated.
- The validated user flow or UI states covered by each artifact.

If screenshots could not be captured, state the concrete blocker and what evidence was captured instead.
