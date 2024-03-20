# Distribution Verification Report

Full verification of the plugin distribution pipeline. Last updated April 17, 2026.

---

## Verification Results

### 1. updatePlugins.xml — PASS

| Check | Result |
|-------|--------|
| `id` matches plugin.xml | `devstatsplugin` — matches |
| `version` matches plugin source | `1.0.9` — matches `gradle.properties` |
| `since-build` matches plugin.xml | `233` — matches |
| `url` points to release asset | `https://github.com/Vanderbilt-Development-Statistics/MysteryPlugin-Pilot/releases/download/v1.0.9/dev-stats-plugin-1.0.9.zip` |
| XML is well-formed | Valid XML, parses correctly |
| GitHub Pages serves the file | Confirmed accessible at `https://vanderbilt-development-statistics.github.io/MysteryPlugin-Pilot/updatePlugins.xml` |

### 2. GitHub Release Asset — PASS

| Check | Result |
|-------|--------|
| Release `v1.0.9` exists | Yes, published 2026-04-17 (Latest) |
| Asset `dev-stats-plugin-1.0.9.zip` attached | Yes |
| Download URL returns valid zip | HTTP 200 after 1 redirect (302 to `release-assets.githubusercontent.com`) |
| IntelliJ follows the redirect | Yes — IntelliJ's HTTP client follows 302 redirects |
| All prior releases preserved | v1.0.0 through v1.0.8 still available |

### 3. Plugin Zip Structure — PASS

The output of `./gradlew clean buildPlugin` produces `build/distributions/dev-stats-plugin-1.0.9.zip` containing a top-level directory with `lib/` and the plugin JAR plus dependencies (OkHttp, JSON, Kotlin stdlib, annotations).

### 4. plugin.xml Consistency — PASS

```xml
<id>devstatsplugin</id>
<name>Development Statistics</name>
<vendor>Vanderbilt University</vendor>
<idea-version since-build="233" />
<depends>com.intellij.modules.platform</depends>
```

All fields are consistent with `updatePlugins.xml`. The `<depends>` tag references only `com.intellij.modules.platform` (the base IntelliJ platform).

### 5. GitHub Pages Deployment — PASS

The workflow `deploy-repo.yml` uses `actions/deploy-pages@v4`. The XML is confirmed accessible at:
```
https://vanderbilt-development-statistics.github.io/MysteryPlugin-Pilot/updatePlugins.xml
```

### 6. Student Project Template (recursions.zip) — PASS

| Check | Result |
|-------|--------|
| `externalDependencies.xml` in `recursions/.idea/` | Present — IDE auto-prompts for plugin installation |
| No `__MACOSX` artifacts | Clean — rebuilt from terminal |
| Source files present | `Recursions.java`, `RecursionsTest.java`, `RecursionsDemo.java` |
| IntelliJ config present | `.idea/`, `recursions.iml` |
| Clean ZIP structure | Single `recursions/` directory, no root-level duplicates |

---

## Known Issues (Informational)

### ISSUE 1: Plugin is unsigned (MEDIUM — affects UX)

**Status:** Documented in installation guides.

Starting with IntelliJ 2024.2, the IDE displays a warning dialog when installing unsigned third-party plugins. Students will see an "Untrusted Plugin" warning. The installation guide instructs students to click **Accept** to proceed.

For future deployments, consider signing the plugin via the `signPlugin` Gradle task.

### ISSUE 2: Plugin is visible and can be disabled/uninstalled by students (INFO)

After installation, the plugin appears in **Settings > Plugins > Installed** as "Development Statistics" by "Vanderbilt University". Students can disable or uninstall it. For the known pilot study, this is acceptable.

### ISSUE 3: Student-visible strings (INFO)

| Where | What students see |
|-------|-------------------|
| Marketplace search result | **Development Statistics** by Vanderbilt University |
| Plugin description | "Dev-Stats is a simple tool designed to track your development statistics" |
| Installed plugins list | Development Statistics, v1.0.9 |

Class names inside the JAR (e.g., `StudentDevelopmentListener`, `FlaskAPISender`) are not visible through the IDE UI. The hardcoded API endpoint is in `DevStatsConfig.properties` inside the JAR — unlikely to be discovered in practice.

---

## Summary

The distribution pipeline is **fully functional and verified** for v1.0.9. The `updatePlugins.xml` format is correct, the GitHub Release asset is properly structured, GitHub Pages is serving the XML, the download URL works, and the student project template includes `externalDependencies.xml` for auto-prompted plugin installation.

Students who add the custom repository URL and open the project will be prompted to install the plugin automatically. The installation guide documents the expected untrusted plugin warning and provides manual installation steps as a fallback.
