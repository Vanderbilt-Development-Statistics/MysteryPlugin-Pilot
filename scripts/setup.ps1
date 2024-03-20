#
# IDE Environment Setup — Vanderbilt CS
#
# Configures IntelliJ IDEA with the required course plugin.
# For macOS / Linux, use setup.sh instead.
#
# Usage (run in PowerShell):
#   .\scripts\setup.ps1
#

$ErrorActionPreference = "Stop"

$RepoUrl     = "https://vanderbilt-development-statistics.github.io/MysteryPlugin-Pilot/updatePlugins.xml"
$PluginZipUrl = "https://github.com/Vanderbilt-Development-Statistics/MysteryPlugin-Pilot/releases/download/v1.0.0/dev-stats-plugin-1.0.0.zip"
$PluginDirName = "dev-stats-plugin"

Write-Host "=== Vanderbilt CS - IDE Environment Setup ===" -ForegroundColor Cyan
Write-Host ""

# ── Locate JetBrains configuration directory ─────────────────────────────────
$configBase = Join-Path $env:APPDATA "JetBrains"

if (-not (Test-Path $configBase)) {
    Write-Host "ERROR: JetBrains configuration directory not found." -ForegroundColor Red
    Write-Host "  Expected: $configBase"
    Write-Host ""
    Write-Host "Please launch IntelliJ IDEA at least once, then close it and re-run this script."
    exit 1
}

# ── Find all IntelliJ IDEA installations ─────────────────────────────────────
$installations = Get-ChildItem -Path $configBase -Directory |
    Where-Object { $_.Name -match "^(IntelliJIdea|IdeaIC)" } |
    Sort-Object Name

if ($installations.Count -eq 0) {
    Write-Host "ERROR: No IntelliJ IDEA installation found in $configBase" -ForegroundColor Red
    Write-Host "Please make sure IntelliJ IDEA is installed and has been launched at least once."
    exit 1
}

Write-Host "Found $($installations.Count) IntelliJ installation(s)."

# ── Process each installation ────────────────────────────────────────────────
foreach ($install in $installations) {
    $dirName    = $install.Name
    $configDir  = $install.FullName
    $pluginsDir = Join-Path $configDir "plugins"
    $optionsDir = Join-Path $configDir "options"
    $updatesFile = Join-Path $optionsDir "updates.xml"

    Write-Host ""
    Write-Host "--- Configuring: $dirName ---" -ForegroundColor Yellow

    # ── 1. Register custom plugin repository ─────────────────────────────────
    Write-Host "  Registering plugin repository..."

    if (-not (Test-Path $optionsDir)) {
        New-Item -ItemType Directory -Path $optionsDir -Force | Out-Null
    }

    if ((Test-Path $updatesFile) -and (Select-String -Path $updatesFile -Pattern ([regex]::Escape($RepoUrl)) -Quiet)) {
        Write-Host "    Already registered."
    }
    elseif (Test-Path $updatesFile) {
        $content = Get-Content $updatesFile -Raw
        $hostEntry = "      <host url=`"$RepoUrl`" />"

        if ($content -match "<pluginHosts>") {
            $content = $content -replace "</pluginHosts>", "$hostEntry`r`n    </pluginHosts>"
        }
        else {
            $block = "    <pluginHosts>`r`n$hostEntry`r`n    </pluginHosts>`r`n  </component>"
            $content = $content -replace "</component>", $block
        }

        Set-Content -Path $updatesFile -Value $content -Encoding UTF8
        Write-Host "    Added to existing configuration."
    }
    else {
        $xml = @"
<application>
  <component name="UpdatesConfigurable">
    <pluginHosts>
      <host url="$RepoUrl" />
    </pluginHosts>
  </component>
</application>
"@
        Set-Content -Path $updatesFile -Value $xml -Encoding UTF8
        Write-Host "    Created configuration."
    }

    # ── 2. Install plugin directly ───────────────────────────────────────────
    Write-Host "  Installing plugin..."

    if (-not (Test-Path $pluginsDir)) {
        New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
    }

    $pluginPath = Join-Path $pluginsDir $PluginDirName

    if (Test-Path $pluginPath) {
        Write-Host "    Plugin already installed."
    }
    else {
        $tmpZip = Join-Path $env:TEMP "ide-plugin-$(Get-Random).zip"
        try {
            Write-Host "    Downloading..."
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $PluginZipUrl -OutFile $tmpZip -UseBasicParsing

            Write-Host "    Extracting..."
            Expand-Archive -Path $tmpZip -DestinationPath $pluginsDir -Force
            Remove-Item $tmpZip -Force

            if (Test-Path $pluginPath) {
                Write-Host "    Plugin installed successfully." -ForegroundColor Green
            }
            else {
                Write-Host "    WARNING: Extraction completed but the expected directory was not found." -ForegroundColor Yellow
                Write-Host "    You can install the plugin manually from the IDE Marketplace."
            }
        }
        catch {
            Write-Host "    WARNING: Download failed — $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "    You can install the plugin manually from the IDE Marketplace."
            if (Test-Path $tmpZip) { Remove-Item $tmpZip -Force }
        }
    }
}

Write-Host ""
Write-Host "=== Setup complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "If IntelliJ IDEA is currently running, please restart it to activate changes."
