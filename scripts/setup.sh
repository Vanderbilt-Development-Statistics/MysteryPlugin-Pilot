#!/usr/bin/env bash
#
# IDE Environment Setup — Vanderbilt CS
#
# Configures IntelliJ IDEA with the required course plugin.
# Supports macOS and Linux. For Windows, use setup.ps1.
#
# Usage:
#   chmod +x scripts/setup.sh
#   ./scripts/setup.sh
#

set -euo pipefail

REPO_URL="https://vanderbilt-development-statistics.github.io/MysteryPlugin-Pilot/updatePlugins.xml"
PLUGIN_ZIP_URL="https://github.com/Vanderbilt-Development-Statistics/MysteryPlugin-Pilot/releases/download/v1.0.9/dev-stats-plugin-1.0.9.zip"
PLUGIN_DIR_NAME="dev-stats-plugin"

echo "=== Vanderbilt CS — IDE Environment Setup ==="
echo ""

# ── Detect OS ────────────────────────────────────────────────────────────────
OS="unknown"
case "$OSTYPE" in
    darwin*)  OS="macos" ;;
    linux*)   OS="linux" ;;
    *)
        echo "ERROR: Unsupported operating system: $OSTYPE"
        echo "This script supports macOS and Linux. For Windows, use setup.ps1."
        exit 1
        ;;
esac

echo "Detected OS: $OS"

# ── Locate JetBrains configuration directory ─────────────────────────────────
if [[ "$OS" == "macos" ]]; then
    CONFIG_BASE="$HOME/Library/Application Support/JetBrains"
else
    CONFIG_BASE="$HOME/.config/JetBrains"
fi

if [[ ! -d "$CONFIG_BASE" ]]; then
    echo ""
    echo "ERROR: JetBrains configuration directory not found."
    echo "  Expected: $CONFIG_BASE"
    echo ""
    echo "Please launch IntelliJ IDEA at least once, then close it and re-run this script."
    exit 1
fi

# ── Find all IntelliJ IDEA installations ─────────────────────────────────────
IDE_DIRS=()
while IFS= read -r -d '' d; do
    IDE_DIRS+=("$d")
done < <(find "$CONFIG_BASE" -maxdepth 1 -type d \( -name "IntelliJIdea*" -o -name "IdeaIC*" \) -print0 2>/dev/null | sort -z)

if [[ ${#IDE_DIRS[@]} -eq 0 ]]; then
    echo ""
    echo "ERROR: No IntelliJ IDEA configuration found in $CONFIG_BASE"
    echo "Please make sure IntelliJ IDEA is installed and has been launched at least once."
    exit 1
fi

echo "Found ${#IDE_DIRS[@]} IntelliJ installation(s)."

# ── Helper: determine the plugins directory for a given config dir ───────────
plugins_dir_for() {
    local config_dir="$1"
    local dir_name
    dir_name=$(basename "$config_dir")

    if [[ "$OS" == "macos" ]]; then
        echo "$config_dir/plugins"
    else
        echo "$HOME/.local/share/JetBrains/$dir_name/plugins"
    fi
}

# ── Helper: register the custom plugin repository URL ────────────────────────
register_repo() {
    local config_dir="$1"
    local options_dir="$config_dir/options"
    local updates_file="$options_dir/updates.xml"

    mkdir -p "$options_dir"

    # Already registered?
    if [[ -f "$updates_file" ]] && grep -q "$REPO_URL" "$updates_file" 2>/dev/null; then
        echo "    Repository URL already registered."
        return 0
    fi

    if [[ -f "$updates_file" ]]; then
        # File exists — inject our URL
        local tmp_file
        tmp_file=$(mktemp)

        if grep -q "<pluginHosts>" "$updates_file" 2>/dev/null; then
            # Append inside existing <pluginHosts> block
            awk -v url="$REPO_URL" '
                /<\/pluginHosts>/ { print "      <host url=\"" url "\" />" }
                { print }
            ' "$updates_file" > "$tmp_file"
        else
            # Add a new <pluginHosts> block before </component>
            awk -v url="$REPO_URL" '
                /<\/component>/ {
                    print "    <pluginHosts>"
                    print "      <host url=\"" url "\" />"
                    print "    </pluginHosts>"
                }
                { print }
            ' "$updates_file" > "$tmp_file"
        fi

        mv "$tmp_file" "$updates_file"
        echo "    Repository URL added to existing configuration."
    else
        # Create a fresh updates.xml
        cat > "$updates_file" << 'XMLEOF'
<application>
  <component name="UpdatesConfigurable">
    <pluginHosts>
      <host url="PLACEHOLDER" />
    </pluginHosts>
  </component>
</application>
XMLEOF
        # Use a temp file to replace placeholder (avoids sed -i portability issues)
        local tmp_file
        tmp_file=$(mktemp)
        awk -v url="$REPO_URL" '{ gsub("PLACEHOLDER", url); print }' "$updates_file" > "$tmp_file"
        mv "$tmp_file" "$updates_file"
        echo "    Repository URL registered (new configuration)."
    fi
}

# ── Helper: install the plugin zip into the plugins directory ────────────────
install_plugin() {
    local plugins_dir="$1"
    mkdir -p "$plugins_dir"

    if [[ -d "$plugins_dir/$PLUGIN_DIR_NAME" ]]; then
        echo "    Plugin already installed."
        return 0
    fi

    local tmp_zip
    tmp_zip=$(mktemp /tmp/ide-plugin-XXXXXX.zip)

    echo "    Downloading plugin..."
    if curl -fsSL --retry 3 -o "$tmp_zip" "$PLUGIN_ZIP_URL" 2>/dev/null; then
        echo "    Extracting..."
        unzip -qo "$tmp_zip" -d "$plugins_dir"
        rm -f "$tmp_zip"

        if [[ -d "$plugins_dir/$PLUGIN_DIR_NAME" ]]; then
            echo "    Plugin installed successfully."
        else
            echo "    WARNING: Extraction completed but the expected plugin directory was not found."
            echo "    You can install the plugin manually from the IDE Marketplace."
        fi
    else
        echo "    WARNING: Download failed. You can install the plugin manually from the IDE Marketplace."
        rm -f "$tmp_zip"
    fi
}

# ── Main: configure each installation ────────────────────────────────────────
for ide_dir in "${IDE_DIRS[@]}"; do
    dir_name=$(basename "$ide_dir")
    echo ""
    echo "--- Configuring: $dir_name ---"

    echo "  Registering plugin repository..."
    register_repo "$ide_dir"

    plugins_dir=$(plugins_dir_for "$ide_dir")
    echo "  Installing plugin to $plugins_dir ..."
    install_plugin "$plugins_dir"
done

echo ""
echo "=== Setup complete ==="
echo ""
echo "If IntelliJ IDEA is currently running, please restart it to activate changes."
