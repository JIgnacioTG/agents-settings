---
name: e2e-evidence
description: Use when validating frontend changes with Playwright E2E tests or browser automation and evidence screenshots, traces, videos, or reports must be captured and reported.
---

# E2E Evidence

Use this skill for frontend validation that needs visual proof, especially Playwright E2E testing, Playwright UI runs, and browser-driven acceptance checks.

## Evidence Folder

- Store agent-generated evidence under `.omo/evidence/` because this repository convention is local-only and gitignored.
- Use a scoped subfolder such as `.omo/evidence/<change-or-session>/screenshots/` for intentional screenshots.
- Keep filenames ordered and descriptive, for example `01-before-ui-change.png`, `02-after-ui-change.png`, `03-success-message.png`, or `04-error-message.png`.

## Required Evidence

Before running or writing E2E coverage, identify the user-visible behavior the change adds or fixes and decide which evidence demonstrates that behavior.

- Capture evidence of the UI change itself: the changed screen, component, layout, visual state, or interaction result that the E2E test covers.
- Capture evidence of success and error messaging when the covered flow can show either state. Use focused screenshots for transient toasts, inline validation, banners, dialogs, or other feedback messages.
- Capture enough surrounding context to prove the evidence belongs to the changed flow, not an unrelated page.
- Prefer one purposeful artifact per required state over many generic screenshots.

## Playwright Test Contract

- Prefer Playwright-native artifacts over ad-hoc screenshot handling.
- For intentional evidence screenshots inside Playwright tests, use `testInfo.outputPath(...)` and `page.screenshot(...)`:

```ts
const screenshotPath = testInfo.outputPath('screenshots', 'dashboard-loaded.png');
await page.screenshot({ path: screenshotPath, fullPage: true });
await testInfo.attach('dashboard-loaded', { path: screenshotPath, contentType: 'image/png' });
```

- Configure Playwright projects that need agent evidence with an artifact root under `.omo/evidence`, for example `outputDir: '.omo/evidence/playwright'`.
- Keep diagnostic artifacts enabled when useful: `screenshot: 'only-on-failure'`, `trace: 'on-first-retry'`, and `video: 'retain-on-failure'`.
- Use Playwright's HTML report as the human-facing evidence index when available.

## Manual Browser Validation Contract

- If validation uses browser automation outside a Playwright test file, still save screenshots under `.omo/evidence/<change-or-session>/screenshots/`.
- Capture meaningful states, not just the final screen: before action, after important transitions, the changed UI state, and any success or error messages relevant to the tested behavior.
- Prefer full-page screenshots for layout/regression checks and viewport screenshots for focused interactions.

## Final Output Contract

Frontend E2E validation is not complete unless the final response lists:

- Exact screenshot paths.
- Playwright HTML report path, if generated.
- Trace or video paths, if generated.
- The validated user flow or UI states covered by each artifact.
- Which artifact proves the UI change.
- Which artifact proves the success or error message, when the flow includes one.

End the message with an evidence location line that names the directory or report path where the evidence was saved. If screenshots could not be captured, state the concrete blocker and what evidence was captured instead.
