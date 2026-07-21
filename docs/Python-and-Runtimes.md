# 🐍 Python & Runtimes

Your day-to-day workflow lives on top of two runtimes: Python for the ML stack and Go for a handful of CLI tools this toolkit installs from source. This note covers the two managers that keep both fast and reproducible.

## uv — fast Python package, venv, and tool manager

`uv` is a Rust-based drop-in replacement for `pip`, `venv`, `virtualenv`, and `pipx`, and it resolves and installs dependencies an order of magnitude faster than the classic toolchain. For ML projects with heavy, deeply-pinned dependency trees (torch, transformers, cuda wheels), that speed and its lockfile-driven reproducibility save you real time. Installed by the repo's `setup.sh`.

```sh
# Pin and install a specific interpreter, managed by uv itself
uv python install 3.12

# Create a virtual environment in ./.venv using that interpreter
uv venv --python 3.12

# Add runtime dependencies to pyproject.toml and the lockfile in one step
uv add torch transformers "datasets>=3"

# Sync the environment to exactly match uv.lock (reproducible installs)
uv sync --frozen

# Run a command inside the project env without activating it
uv run python train.py --epochs 3

# Install a CLI tool into an isolated, globally-available environment
uv tool install ruff
```

> [!tip] Prefer `uv sync --frozen` in CI and on shared machines. It fails instead of silently updating `uv.lock`, so every teammate and every training run resolves the exact same wheels.

Docs: [uv docs](https://docs.astral.sh/uv/)

## Go — the Go toolchain, also used to `go install` CLI tools

Go gives you a compiler and module tooling for building and running Go programs, and it doubles as the installer for several fast CLI utilities in this toolkit that ship as Go source. Compiled tools are single static binaries, which makes them trivial to drop onto a remote box or into a container. Installed by the repo's `setup.sh`.

```sh
# Build and install a CLI tool from a module path into ~/go/bin
go install github.com/jesseduffield/lazygit@latest

# Compile the current module into a binary in the working directory
go build -o bin/app ./cmd/app

# Compile and run a program in one step, without leaving an artifact
go run ./cmd/app

# Run the test suite for all packages, verbosely
go test -v ./...

# Download and verify the dependencies pinned in go.mod / go.sum
go mod download
```

> [!tip] `go install` drops binaries into `~/go/bin`, and this setup already puts that directory on your `PATH`. So after `go install ...@latest`, the tool is runnable by name in a new shell with no extra steps.

Docs: [Go docs](https://go.dev/doc/)

See also: [[Terminal-Toolkit]] (index)
