# 🧰 Terminal Toolkit — Index

A curated, **portable** CLI stack for a cloud-focused **deep-learning engineer**. The shell and command-line tools below run the same on native Ubuntu, WSL, or a remote server. The terminal *emulator* ([[Ghostty-Hands-On-Intro|Ghostty]]) is a separate, environment-specific layer (Linux/macOS only) and lives in its own folder. Each note is hands-on and tuned to this setup.

## The notes (portable core)

| Note                         | Tools                     | What it gives you                                                   |
| ---------------------------- | ------------------------- | ------------------------------------------------------------------- |
| [[Setup-Inventory]]          | (everything, at a glance) | Full parts list + links to reproduce this setup on a new laptop     |
| [[Zsh-Setup-Reference]]      | (your current setup)      | What's already active + the PATH lines the rest need                |
| [[Shell-Power-Layer]]        | fzf · fd · atuin          | Fuzzy history/files/dirs + a real history database — **start here** |
| [[Git-and-Dev-Flow]]         | delta · lazygit · just    | Readable diffs, a git TUI, a per-repo command runner                |
| [[Data-Investigation-CLI]]   | duckdb · visidata · s5cmd | Inspect Parquet/CSV/S3 and pull training data fast                  |
| [[Inspecting-Kubeflow-Pods]] | kubectl · k9s · stern     | Debug the pods running your pipeline steps                          |

## Terminal emulator (environment-specific)

Not part of the portable toolkit. Use Ghostty on **Linux/macOS**; on **WSL** drive these tools through the Windows host terminal (e.g. Windows Terminal) instead.

- [[Ghostty-Hands-On-Intro]] · [[Ghostty-Config-Starter]] — GPU-accelerated emulator (splits, tabs, live config reload)

## Suggested install order

1. **[[Shell-Power-Layer]]** — `fzf` is the connective tissue; everything else feels better once it's in.
2. **[[Git-and-Dev-Flow]]** — daily git becomes readable and fast.
3. Then **[[Data-Investigation-CLI]]** and **[[Inspecting-Kubeflow-Pods]]** as your work needs them.

## Already installed on this box

`zoxide` · `eza` · `bat` (batcat) · `ripgrep` · `tmux` · `jq` · `yq` · `jnv` · `dust` · `gh` · `helm` · `kustomize` · `direnv` · `uv` · `btop` · `kubectl`

## Worth trying next

Extras beyond the core notes, grouped by what they help with (full descriptions in [[Setup-Inventory]]):

- **Shell & prompt**: `starship` (fast cross-shell prompt: git, k8s context, venv).
- **Text & data**: `yq` (jq for YAML), `jnv` (interactive JSON), `sd` (friendlier sed), `csvlens` (CSV viewer), `hyperfine` (benchmarking).
- **System**: `dust`/`duf` (disk usage/free), `procs` (modern ps).
- **Kubernetes**: `kubecolor` (colorized `kubectl`).
- **Containers**: `lazydocker` (Docker TUI), `dive` (image-layer inspector).
- **Sessions & files**: `zellij` (tmux alternative), `yazi` (file manager).
- **Discovery**: `tealdeer` (`tldr` cheat-sheets).

## Optional

- [[Switching-Contexts-Optional]] — `kubectx`/`kubens` for hopping between multiple clusters/namespaces. Only worth it if you juggle more than one.
