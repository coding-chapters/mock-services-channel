# Mock Services Channel

Coursier channel for installing mock Spark cluster launchers. JARs are resolved from Maven on first run — no repo clone, no sbt, no build step needed.

**Requires JDK 21+**

---

## One-line Install

**macOS/Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/coding-chapters/mock-services-channel/main/install.sh | bash
```

**Windows (PowerShell)**
```powershell
irm https://raw.githubusercontent.com/coding-chapters/mock-services-channel/main/install.ps1 | iex
```

This installs:
- **coursier** (if not already installed)
- **7 launchers** (resolved from Maven)
- **gum** (interactive TUI)
- **`ms`** command (interactive launcher menu)

---

## Usage

```bash
ms                           # interactive menu
start-distributed-cluster    # HDFS + Spark + History Server
start-spark-cluster          # Spark-only (no HDFS)
start-hdfs-cluster           # HDFS-only (no Spark)
start-history-server         # standalone History Server
show-cluster-processes       # display running cluster processes
mock-spark-shell "MyApp"     # interactive Spark REPL
```

All cluster commands accept `--num-nodes N` to configure the number of worker/data nodes (default: 3).
