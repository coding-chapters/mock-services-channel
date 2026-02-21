# Mock Spark Cluster Apps

Coursier channel for installing mock Spark cluster launchers. JARs are resolved from Maven on first run — no repo clone, no sbt, no build step needed.

**Requires JDK 17+**

---

## One-line Install

```bash
# macOS/Linux
curl -fsSL https://raw.githubusercontent.com/codingchapters/mock-services/main/install.sh | bash

# Windows (PowerShell)
irm https://raw.githubusercontent.com/codingchapters/mock-services/main/install.ps1 | iex
```

This installs:
- **coursier** (if not already installed)
- **6 cluster launchers** (resolved from Maven)
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
```

All commands accept `--num-nodes N` to configure the number of worker/data nodes (default: 3).

---

## What's NOT included

**`mock-spark-shell`** (interactive Spark REPL) is not available via Coursier because its main class is generated source from the SBT plugin. For the Spark Shell, use the full development setup:
- [mock-services repo](https://github.com/codingchapters/mock-services) with `setup.sh`
