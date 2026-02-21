#!/usr/bin/env bash
#
# Mock Spark Cluster - One-line installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/codingchapters/mock-services/main/install.sh | bash
#
set -euo pipefail

CHANNEL="https://raw.githubusercontent.com/codingchapters/mock-services/main/apps.json"
APPS="start-distributed-cluster start-hdfs-cluster start-spark-cluster show-cluster-processes start-history-server regenerate-mock-spark-shell"

info() { echo "=> $1"; }

# ── 1. Coursier ─────────────────────────────────────────────────────────────

info "Checking coursier (cs)..."
if command -v cs &>/dev/null; then
  echo "   cs found"
else
  info "Installing coursier..."
  if command -v brew &>/dev/null; then
    brew install coursier/formulas/coursier
  else
    ARCH="$(uname -m)"
    if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
      CS_URL="https://github.com/coursier/coursier/releases/latest/download/cs-aarch64-apple-darwin.gz"
    else
      CS_URL="https://github.com/coursier/launchers/raw/master/cs-x86_64-apple-darwin.gz"
    fi
    mkdir -p "$HOME/bin"
    curl -fL "$CS_URL" | gzip -d > "$HOME/bin/cs"
    chmod +x "$HOME/bin/cs"
    export PATH="$HOME/bin:$PATH"
  fi
  cs setup --yes 2>/dev/null || true
fi

CS_BIN="$(dirname "$(command -v cs)")"

# ── 2. Install launchers ────────────────────────────────────────────────────

info "Installing mock-spark-cluster launchers..."
cs install --channel "$CHANNEL" $APPS

# ── 3. gum ───────────────────────────────────────────────────────────────────

info "Checking gum (interactive TUI)..."
if command -v gum &>/dev/null; then
  echo "   gum found"
else
  info "Installing gum..."
  if command -v brew &>/dev/null; then
    brew install gum
  else
    echo "   gum not found. Install manually: https://github.com/charmbracelet/gum#installation"
    echo "   (ms launcher will not work without gum)"
  fi
fi

# ── 4. ms launcher ──────────────────────────────────────────────────────────

info "Creating 'ms' interactive launcher..."

cat > "$CS_BIN/ms" << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

if ! command -v gum &>/dev/null; then
  echo "gum is not installed. Install it with: brew install gum"
  exit 1
fi

CHOICE=$(gum choose \
  "Start Distributed Cluster" \
  "Start Spark Cluster" \
  "Start HDFS Cluster" \
  "Start History Server" \
  "Show Cluster Processes")

case "$CHOICE" in
  "Start Distributed Cluster") start-distributed-cluster "$@" ;;
  "Start Spark Cluster")       start-spark-cluster "$@" ;;
  "Start HDFS Cluster")        start-hdfs-cluster "$@" ;;
  "Start History Server")      start-history-server "$@" ;;
  "Show Cluster Processes")    show-cluster-processes "$@" ;;
esac
SCRIPT

chmod +x "$CS_BIN/ms"

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "========================================"
echo "  Installation complete!"
echo "========================================"
echo ""

if [[ ":$PATH:" != *":$CS_BIN:"* ]]; then
  echo "Add Coursier bin to your PATH:"
  echo "  export PATH=\"\$PATH:$CS_BIN\""
  echo ""
fi

echo "Usage:"
echo "  ms                           # interactive menu"
echo "  start-distributed-cluster    # start full cluster"
echo "  show-cluster-processes       # show running cluster"
echo ""
