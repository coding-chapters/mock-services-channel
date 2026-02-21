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
mock-services "MyApp"        # interactive Spark REPL
```

---

## Docker Test

Verify the install script works on a fresh Linux machine:

```bash
docker build --no-cache -f Dockerfile.test -t mock-services-test .
```

This builds a container that:
1. Installs coursier from scratch
2. Runs `install.sh` with the local `apps.json` channel
3. Verifies `show-cluster-processes` and `mock-services` commands are runnable

**Note**: First build is slow (~3-5 min) — downloads Spark + Hadoop + all transitive JARs. Allocate at least 4 GB Docker memory to avoid OOM kills.
