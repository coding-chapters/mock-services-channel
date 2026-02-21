#
# Mock Spark Cluster - One-line installer (Windows)
#
# Usage:
#   irm https://raw.githubusercontent.com/coding-chapters/mock-services-channel/main/install.ps1 | iex
#
$ErrorActionPreference = "Stop"

$Channel = "https://raw.githubusercontent.com/coding-chapters/mock-services-channel/main/apps.json"
$Apps = @(
    "start-distributed-cluster",
    "start-hdfs-cluster",
    "start-spark-cluster",
    "show-cluster-processes",
    "start-history-server",
    "regenerate-mock-spark-shell"
)

function Info($msg) { Write-Host "=> $msg" }

# ── 1. Coursier ─────────────────────────────────────────────────────────────

Info "Checking coursier (cs)..."
if (Get-Command cs -ErrorAction SilentlyContinue) {
    Write-Host "   cs found"
} else {
    Info "Installing coursier..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id coursier.cs --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host "   winget not found. Install coursier manually: https://get-coursier.io/docs/cli-installation"
        exit 1
    }
    cs setup --yes 2>$null
}

# ── 2. Install launchers ────────────────────────────────────────────────────

Info "Installing mock-spark-cluster launchers..."
$AppsStr = $Apps -join " "
Invoke-Expression "cs install --channel $Channel $AppsStr"

# ── 3. gum ───────────────────────────────────────────────────────────────────

Info "Checking gum (interactive TUI)..."
if (Get-Command gum -ErrorAction SilentlyContinue) {
    Write-Host "   gum found"
} else {
    Info "Installing gum..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id charmbracelet.gum --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host "   gum not found. Install manually: https://github.com/charmbracelet/gum#installation"
    }
}

# ── 4. ms launcher ──────────────────────────────────────────────────────────

Info "Creating 'ms' PowerShell function..."

$MsFunction = @'

# Mock Spark Cluster launcher
function ms {
    if (-not (Get-Command gum -ErrorAction SilentlyContinue)) {
        Write-Host "gum is not installed. Install it with: winget install charmbracelet.gum"
        return
    }
    $choice = gum choose `
        "Start Distributed Cluster" `
        "Start Spark Cluster" `
        "Start HDFS Cluster" `
        "Start History Server" `
        "Show Cluster Processes"

    switch ($choice) {
        "Start Distributed Cluster" { start-distributed-cluster @args }
        "Start Spark Cluster"       { start-spark-cluster @args }
        "Start HDFS Cluster"        { start-hdfs-cluster @args }
        "Start History Server"      { start-history-server @args }
        "Show Cluster Processes"    { show-cluster-processes @args }
    }
}
'@

if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
}

$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -and $profileContent.Contains("function ms")) {
    Write-Host "   function 'ms' already in $PROFILE"
} else {
    Add-Content -Path $PROFILE -Value $MsFunction
    Write-Host "   Added function 'ms' to $PROFILE"
}

# ── Done ─────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "========================================"
Write-Host "  Installation complete!"
Write-Host "========================================"
Write-Host ""
Write-Host "Usage:"
Write-Host "  ms                           # interactive menu"
Write-Host "  start-distributed-cluster    # start full cluster"
Write-Host "  show-cluster-processes       # show running cluster"
Write-Host ""
