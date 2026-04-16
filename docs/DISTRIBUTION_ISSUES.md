# Distribution Verification Report

Full verification of the plugin distribution pipeline, tested April 2026.

---

## Verification Results

### 1. updatePlugins.xml — PASS

| Check | Result |
|-------|--------|
| `id` matches plugin.xml | `devstatsplugin` — matches |
| `version` matches plugin.xml | `1.0.0` — matches |
| `since-build` matches plugin.xml | `233` — matches |
| `url` points to release asset | Matches `browser_download_url` exactly |
| XML is well-formed | Valid XML, parses correctly |
| GitHub Pages serves the file | Confirmed accessible in browser |

### 2. GitHub Release Asset — PASS

| Check | Result |
|-------|--------|
| Release `v1.0.0` exists | Yes, published 2026-03-03 |
| Asset `dev-stats-plugin-1.0.0.zip` exists | Yes, 3,044,163 bytes |
| Content type | `application/zip` |
| Download count | 4 |
| Download URL returns valid zip | HTTP 200 after 1 redirect (302 to `release-assets.githubusercontent.com`) |
| IntelliJ follows the redirect | Yes — IntelliJ's HTTP client follows 302 redirects. The `github.com/.../releases/download/...` URL format is standard and works. |

### 3. Plugin Zip Structure — PASS

```
dev-stats-plugin/
  lib/
    dev-stats-plugin-1.0.0.jar          (123 KB — main plugin)
    dev-stats-plugin-1.0.0-searchableOptions.jar
    kotlin-stdlib-1.9.23.jar
    annotations-13.0.jar
    okhttp-5.0.0-alpha.14.jar
    okio-jvm-3.9.0.jar
    json-20240303.jar
```

This is the correct output of `./gradlew buildPlugin` — a top-level directory containing `lib/` with the plugin JAR and its dependencies.

### 4. plugin.xml Inside JAR — PASS

```xml
<id>devstatsplugin</id>
<name>Development Statistics</name>
<version>1.0.0</version>
<vendor>Vanderbilt University</vendor>
<idea-version since-build="233" />
<depends>com.intellij.modules.platform</depends>
```

All fields are consistent with `updatePlugins.xml`. The `<depends>` tag references only `com.intellij.modules.platform` (the base IntelliJ platform), which is correct and does not reference the JetBrains Marketplace.

### 5. GitHub Pages Deployment — PASS

The workflow `deploy-repo.yml` uses `actions/deploy-pages@v4` (modern GitHub Actions deployment, no `gh-pages` branch needed). It has run successfully 4 times. The XML is confirmed accessible at:
```
https://vanderbilt-development-statistics.github.io/MysteryPlugin-Pilot/updatePlugins.xml
```

---

## Issues Found

### ISSUE 1: Plugin is unsigned (MEDIUM — affects UX)

**Finding:** `jarsigner -verify` confirms the JAR is unsigned.

**Impact:** Starting with IntelliJ 2024.2, the IDE displays a warning dialog when installing unsigned third-party plugins. Students will see a prompt like:

> "You are about to install a plugin from a third-party vendor. Do you want to proceed?"

or a more prominent "Untrusted Plugin" warning, depending on the exact IDE version.

**Recommendation:** For the pilot study, this is manageable — document the expected warning in the installation guide (done). For future deployments, consider signing the plugin using the JetBrains Marketplace signing process or a custom certificate via the `signPlugin` Gradle task.

---

### ISSUE 2: No `externalDependencies.xml` in student project (LOW — missed opportunity)

**Finding:** The student project template (`project4.zip`) contains an `.idea/` directory with `modules.xml`, `misc.xml`, and `workspace.xml`, but no `externalDependencies.xml`.

**Impact:** When a student opens the project, the IDE has no way to know that `devstatsplugin` is required. The IDE will NOT auto-prompt for installation.

**If added**, the IDE would show a notification like:
> "Required plugin 'Development Statistics' is not installed. Install?"

This only works if the custom repository URL is already registered (Step 1 of the installation guide). The order of operations matters:
1. Add custom repo URL first
2. THEN open the project
3. IDE detects the missing required plugin and offers to install it

**Recommendation:** Add this file to the project template's `.idea/` directory:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ExternalDependencies">
    <plugin id="devstatsplugin" />
  </component>
</project>
```

This makes Step 2 (searching and installing) partially automatic — the IDE prompts the student instead of requiring a manual search.

---

### ISSUE 3: Plugin is visible and can be disabled/uninstalled by students (INFO)

**Finding:** After installation, the plugin appears in **Settings > Plugins > Installed** as "Development Statistics" by "Vanderbilt University". Students can:
- Uncheck the checkbox to **disable** it
- Right-click and select **Uninstall**

**Impact:** For the pilot study where students know about the plugin, this is fine. For a future hidden deployment, there is no built-in IntelliJ mechanism to prevent users from disabling or uninstalling a plugin.

---

### ISSUE 4: Student-visible strings reveal the plugin's purpose (INFO)

**Finding:** The following strings are visible during and after installation:

| Where | What students see |
|-------|-------------------|
| Marketplace search result | **Development Statistics** by Vanderbilt University |
| Plugin description | "Dev-Stats is a simple tool designed to track your development statistics" |
| Installed plugins list | Development Statistics, v1.0.0 |
| Plugin icon | Custom SVG icon (179 KB) |

Class names inside the JAR (e.g., `StudentDevelopmentListener`, `FlaskAPISender`, `RequestQueueManager`) are **not** normally visible to students through the IDE UI.

The hardcoded API endpoint (`https://dev-stats.app.vanderbilt.edu/logs`) is in `DevStatsConfig.properties` inside the JAR. A technically sophisticated student could find it by extracting the JAR, but this is unlikely in practice.

**Recommendation:** For the pilot study, these strings are fine since students know they're participating. For a future hidden deployment, the plugin name, description, and vendor should be made generic.

---

### ISSUE 5: `__MACOSX` artifacts in project4.zip (LOW — cosmetic)

**Finding:** `project4.zip` contains `__MACOSX/` resource fork directories, which are an artifact of zipping on macOS. These are harmless but unprofessional.

**Recommendation:** Re-create the zip from a terminal:
```bash
cd /path/to/project4-parent && zip -r project4.zip project4/ -x "*.DS_Store" "__MACOSX/*"
```

---

## Summary

The distribution pipeline is **fully functional**. The `updatePlugins.xml` format is correct, the GitHub Release asset is properly structured, GitHub Pages is serving the XML, and the download URL works (including redirect following).

The original error ("downloading from plugins.jetbrains.com") was caused by the custom repository URL not being registered in the student's IDE — a student-side configuration issue, not an infrastructure issue. The installation guide documents the correct process.

The only actionable improvement for the pilot is adding `externalDependencies.xml` to the student project template to enable auto-prompted installation.
