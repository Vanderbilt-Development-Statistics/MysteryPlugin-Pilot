# Plugin Installation Guide

Step-by-step instructions for installing the Development Statistics plugin from the Vanderbilt custom plugin repository.

---

## Prerequisites

- **IntelliJ IDEA** (Community or Ultimate), version **2023.3 or newer**
- An internet connection

---

## Step 1: Add the Custom Plugin Repository

The plugin is hosted on a private repository and is not available on the JetBrains Marketplace. You must add the repository URL to your IDE before you can install it.

1. Open IntelliJ IDEA.
2. Navigate to the **Plugins** settings:
   - **From the Welcome Screen:** Click **Plugins** in the left sidebar.
   - **From an open project:** Go to **File > Settings** (Windows/Linux) or **IntelliJ IDEA > Settings** (macOS), then select **Plugins**.
3. Click the **gear icon** (⚙️) near the top of the Plugins panel, next to the "Marketplace" and "Installed" tabs.
4. Select **Manage Plugin Repositories...** from the dropdown menu.
5. In the **Custom Plugin Repositories** dialog, click the **+** button.
6. Paste the following URL exactly:
   ```
   https://vanderbilt-development-statistics.github.io/MysteryPlugin-Pilot/updatePlugins.xml
   ```
7. Click **OK** to close the Custom Plugin Repositories dialog.

**How to verify this step worked:**
- After clicking OK, the dialog should close without errors.
- If you see a "Connection failed" error, check your internet connection and make sure the URL is typed exactly as shown (no extra spaces or characters).

---

## Step 2: Install the Plugin

1. In the Plugins panel, make sure you are on the **Marketplace** tab.
2. In the search bar, type: **Development Statistics**
3. The plugin should appear in the search results, published by **Vanderbilt University**.
4. Click the **Install** button next to the plugin.
5. **If you see an "Untrusted Plugin" or "Third-Party Plugin" warning:**
   - This is expected. The plugin is provided directly by Vanderbilt University and is not published on the JetBrains Marketplace, so IntelliJ displays a standard warning.
   - Click **Accept** (or **Install Anyway** / **Trust and Install**, depending on your IDE version) to proceed.
6. Wait for the download and installation to complete.

**How to verify this step worked:**
- The Install button should change to a **Restart IDE** button (or show "Installed" with a restart prompt).
- If the plugin does not appear in search results, close the Plugins panel entirely and reopen it, then search again. Make sure the custom repository URL was saved in Step 1.

---

## Step 3: Restart the IDE

1. After installation, IntelliJ will prompt you to restart. Click **Restart IDE**.
2. If no prompt appears, manually restart: **File > Exit**, then reopen IntelliJ.

---

## Step 4: Verify the Plugin is Active

1. After restarting, go to **File > Settings > Plugins** (or **IntelliJ IDEA > Settings > Plugins** on macOS).
2. Click the **Installed** tab.
3. Find **"Development Statistics"** in the list.
4. Confirm that the checkbox next to it is **checked** (enabled).

**What you should see:**
- Plugin name: **Development Statistics**
- Version: **1.0.0**
- Vendor: **Vanderbilt University**
- Status: **Enabled** (checkbox checked)

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Plugin doesn't appear in Marketplace search | Close and reopen the entire Plugins panel (not just the tab). Verify the custom repository URL was saved in Step 1 by going back to ⚙️ > Manage Plugin Repositories and checking the URL is listed. |
| "Connection failed" when adding repository URL | Check your internet connection. If you are on a VPN or restricted network, try disconnecting. Verify the URL has no typos. |
| "Untrusted Plugin" warning during install | This is expected for plugins from custom repositories. Click Accept/Trust to proceed. |
| Plugin installed but not visible in Installed tab | Restart the IDE. If still not visible, go to ⚙️ > Manage Plugin Repositories, remove the URL, re-add it, and reinstall. |
| IDE tries to download from plugins.jetbrains.com | The custom repository URL was not registered. Go back to Step 1 and add it. |
