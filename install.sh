#!/usr/bin/env bash
#
# Mock Spark Cluster - One-line installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/coding-chapters/mock-services-channel/main/install.sh | bash
#
set -euo pipefail

CHANNEL="${CHANNEL:-https://raw.githubusercontent.com/coding-chapters/mock-services-channel/main/apps.json}"
APPS="start-distributed-cluster start-hdfs-cluster start-spark-cluster show-cluster-processes start-history-server regenerate-mock-spark-shell mock-spark-shell"

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
    OS="$(uname -s)"
    ARCH="$(uname -m)"
    case "$OS-$ARCH" in
      Linux-x86_64)  CS_URL="https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz" ;;
      Linux-aarch64) CS_URL="https://github.com/coursier/coursier/releases/latest/download/cs-aarch64-pc-linux.gz" ;;
      Darwin-arm64)  CS_URL="https://github.com/coursier/coursier/releases/latest/download/cs-aarch64-apple-darwin.gz" ;;
      Darwin-x86_64) CS_URL="https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-apple-darwin.gz" ;;
      *) echo "Unsupported platform: $OS-$ARCH"; exit 1 ;;
    esac
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
