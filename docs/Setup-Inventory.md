# 🗺️ Setup Inventory — Reproduce This Shell

> [!info] Purpose
> A high-level parts list of the whole terminal setup so it can be rebuilt on a new laptop. Each tool links to its docs/repo and points to a how-to (an internal note where one exists, otherwise the official guide).
> **Legend:** ✅ installed on this machine · ➕ recommended, not yet installed
> **Base:** Ubuntu 24.04 · zsh `5.9`
> **Portable core:** the shell + CLI tools below run the same on native Ubuntu, WSL, or a remote server. The terminal *emulator* is the one machine-specific layer (see the section right below).
> Example shell config: [`zshrc.example`](zshrc.example)

## Terminal emulator (environment-specific)

> [!note] Not part of the portable toolkit
> Everything else in this file runs on native Ubuntu, WSL, or a remote server. The emulator is the one machine-specific piece: use Ghostty on **Linux/macOS**; on **WSL** you drive these tools through the Windows host terminal (e.g. Windows Terminal) instead.

| Tool | Status | What it does | How-to |
|---|---|---|---|
| [Ghostty](https://ghostty.org) | ✅ | GPU-accelerated terminal emulator, **Linux/macOS only** (native splits, tabs, live config reload) | [[Ghostty-Hands-On-Intro]] · [[Ghostty-Config-Starter]] |

## Shell foundation

| Tool | Status | What it does | How-to |
|---|---|---|---|
| [zsh](https://www.zsh.org) | ✅ | The shell itself | [[Zsh-Setup-Reference]] |
| [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) | ✅ | zsh framework: manages plugins, themes, completions | [[Zsh-Setup-Reference]] |
| [agnoster theme](https://github.com/agnoster/agnoster-zsh-theme) | ✅ | Powerline prompt (git status, path) — needs a Nerd Font | [[Zsh-Setup-Reference]] |
| [FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts) | ✅ | Monospace font with ligatures + icon glyphs (for prompt/eza icons) | [Install guide](https://github.com/ryanoasis/nerd-fonts#font-installation) |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | ✅ | Greyed-out inline suggestion from history; `→`/`End` to accept | [[Zsh-Setup-Reference]] |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | ✅ | Colors commands green/red as you type | [[Zsh-Setup-Reference]] |
| [starship](https://starship.rs) | ➕ | Fast cross-shell prompt showing git status, k8s context, language/venv, and command duration; an alternative to the agnoster theme (still needs a Nerd Font) | [Guide](https://starship.rs/guide/) |

## Core CLI — navigation, files, search

| Tool | Status | What it does | How-to |
|---|---|---|---|
| [zoxide](https://github.com/ajeetdsouza/zoxide) | ✅ | Smarter `cd` — jump by frecency (`z <frag>`, `zi` to pick) | [[Zsh-Setup-Reference]] |
| [eza](https://github.com/eza-community/eza) | ✅ | Modern `ls` with icons, colors, git status (`ls`/`ll`) | [[Zsh-Setup-Reference]] |
| [bat](https://github.com/sharkdp/bat) | ✅ | `cat` with syntax highlighting + paging (`batcat`) | [[Zsh-Setup-Reference]] |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | ✅ | Extremely fast recursive text search (`rg`) | [User guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md) |
| [fd](https://github.com/sharkdp/fd) | ✅ | Fast, sane `find` that respects `.gitignore` (`fdfind`) | [[Shell-Power-Layer]] |
| [fzf](https://github.com/junegunn/fzf) | ✅ | Fuzzy finder for history/files/dirs; the connective tissue | [[Shell-Power-Layer]] |
| [atuin](https://github.com/atuinsh/atuin) | ✅ | Shell history in SQLite with full-screen fuzzy search | [[Shell-Power-Layer]] |
| [tmux](https://github.com/tmux/tmux) | ✅ | Terminal multiplexer (persistent sessions over SSH) | [Getting started](https://github.com/tmux/tmux/wiki/Getting-Started) |
| [jq](https://github.com/jqlang/jq) | ✅ | Command-line JSON processor | [Tutorial](https://jqlang.org/tutorial/) |
| [yq](https://github.com/mikefarah/yq) | ✅ | `jq` for YAML (also JSON/XML) — ideal for Kubernetes manifests and Helm values | [Docs](https://mikefarah.gitbook.io/yq/) |
| [jnv](https://github.com/ynqa/jnv) | ✅ | Interactive JSON viewer with live `jq`-style filtering | [README](https://github.com/ynqa/jnv#readme) |
| [sd](https://github.com/chmln/sd) | ➕ | Intuitive find-and-replace, a friendlier `sed` (`sd 'old' 'new' file`) | [README](https://github.com/chmln/sd#readme) |
| [tealdeer](https://github.com/dbrgn/tealdeer) | ➕ | Fast `tldr` client: concise, example-driven cheat-sheets for any command | [Docs](https://tealdeer-rs.github.io/tealdeer/) |
| [hyperfine](https://github.com/sharkdp/hyperfine) | ➕ | Command-line benchmarking with warmup runs and statistics | [README](https://github.com/sharkdp/hyperfine#readme) |
| [zellij](https://github.com/zellij-org/zellij) | ➕ | Modern terminal multiplexer (panes, tabs, layouts, discoverable keybinds); a `tmux` alternative | [Docs](https://zellij.dev/documentation/) |
| [yazi](https://github.com/sxyazi/yazi) | ➕ | Blazing-fast terminal file manager with async I/O and file/image previews | [Docs](https://yazi-rs.github.io/) |

## Git & development flow

| Tool | Status | What it does | How-to |
|---|---|---|---|
| [git](https://git-scm.com) | ✅ | Version control | [[Git-and-Dev-Flow]] |
| [git-lfs](https://git-lfs.com) | ✅ | Large-file storage (models, datasets) | [Tutorial](https://github.com/git-lfs/git-lfs/wiki/Tutorial) |
| [gh](https://cli.github.com) | ✅ | GitHub CLI (PRs, issues, auth, git credential helper) | [Manual](https://cli.github.com/manual/) |
| [delta](https://github.com/dandavison/delta) | ➕ | Syntax-highlighted, side-by-side git diffs | [[Git-and-Dev-Flow]] |
| [lazygit](https://github.com/jesseduffield/lazygit) | ➕ | Full-screen git TUI (stage, commit, rebase) | [[Git-and-Dev-Flow]] |
| [just](https://github.com/casey/just) | ➕ | Per-repo command runner (a friendlier Make) | [[Git-and-Dev-Flow]] |
| [direnv](https://direnv.net) | ✅ | Auto-load/unload project env on `cd` (`.envrc`) | [[Git-and-Dev-Flow]] |

## Python, data & ML

| Tool | Status | What it does | How-to |
|---|---|---|---|
| [uv](https://github.com/astral-sh/uv) | ✅ | Fast Python package/venv/tool manager | [Docs](https://docs.astral.sh/uv/) |
| [duckdb](https://duckdb.org) | ➕ | In-process SQL over Parquet/CSV/S3 — no warehouse | [[Data-Investigation-CLI]] |
| [visidata](https://www.visidata.org) | ➕ | Terminal spreadsheet for any tabular file (`vd`) | [[Data-Investigation-CLI]] |
| [s5cmd](https://github.com/peak/s5cmd) | ➕ | Fast, parallel S3 transfers (uses `~/.aws`) | [[Data-Investigation-CLI]] |
| [csvlens](https://github.com/YS-L/csvlens) | ➕ | Terminal CSV/TSV viewer (like `less` for tables), fast on large files | [[Data-Investigation-CLI]] |

## Kubernetes (consumer / investigator)

| Tool | Status | What it does | How-to |
|---|---|---|---|
| [kubectl](https://kubernetes.io/docs/reference/kubectl/) | ✅ | The Kubernetes CLI | [[Inspecting-Kubeflow-Pods]] |
| [helm](https://helm.sh) | ✅ | Kubernetes package manager (charts) | [Quickstart](https://helm.sh/docs/intro/quickstart/) |
| [kustomize](https://kustomize.io) | ✅ | Template-free Kubernetes manifest customization | [Guide](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/) |
| [k9s](https://k9scli.io) | ➕ | TUI cockpit to navigate pods/logs/describe/exec | [[Inspecting-Kubeflow-Pods]] |
| [stern](https://github.com/stern/stern) | ➕ | Tail logs across many pods at once, color-coded | [[Inspecting-Kubeflow-Pods]] |
| [kubectx / kubens](https://github.com/ahmetb/kubectx) | ➕ | Fast context/namespace switching | [[Switching-Contexts-Optional]] |
| [kubecolor](https://github.com/kubecolor/kubecolor) | ➕ | Colorizes `kubectl` output; drop-in via `alias kubectl=kubecolor` | [[Inspecting-Kubeflow-Pods]] |

## System & GPU monitoring

| Tool                                          | Status | What it does                                       | How-to                                              |
| --------------------------------------------- | ------ | -------------------------------------------------- | --------------------------------------------------- |
| [btop](https://github.com/aristocratos/btop)  | ✅      | Rich CPU/RAM/process/disk TUI monitor              | [README](https://github.com/aristocratos/btop#btop) |
| [nvtop](https://github.com/Syllo/nvtop)       | ➕      | `htop`-style GPU monitor (util, VRAM, per-process) | [[Shell-Power-Layer]]                               |
| [nvitop](https://github.com/XuehaiPan/nvitop) | ✅      | Richer GPU/process view                            | [[Shell-Power-Layer]]                               |
| [dust](https://github.com/bootandy/dust)      | ✅      | Tree-based disk-usage summary, a friendlier `du`   | [README](https://github.com/bootandy/dust#usage)    |
| [duf](https://github.com/muesli/duf)          | ➕      | Disk free/usage overview in a clean table (`df`)   | [README](https://github.com/muesli/duf#readme)      |
| [procs](https://github.com/dalance/procs)     | ➕      | Modern `ps` with color, tree view, and search      | [Docs](https://github.com/dalance/procs#usage)      |

## Containers

| Tool | Status | What it does | How-to |
|---|---|---|---|
| [lazydocker](https://github.com/jesseduffield/lazydocker) | ➕ | Full-screen Docker/compose TUI (containers, logs, images); sibling of `lazygit` | [README](https://github.com/jesseduffield/lazydocker#readme) |
| [dive](https://github.com/wagoodman/dive) | ➕ | Explore a Docker image layer by layer to find wasted space | [README](https://github.com/wagoodman/dive#readme) |

## Languages & runtimes

| Tool | Status | What it does | How-to |
|---|---|---|---|
| [Go](https://go.dev) | ✅ | Go toolchain (also used to `go install` some tools above) | [Docs](https://go.dev/doc/) |

---

## Rebuilding on a new laptop — order

1. Set up your terminal emulator (**Ghostty** on Linux/macOS; on **WSL** use the Windows host terminal). Install **zsh**, set it as default (`chsh -s $(which zsh)`), then install **oh-my-zsh** and a **Nerd Font**.
2. Clone the two oh-my-zsh custom plugins (autosuggestions, syntax-highlighting), then adapt [`zshrc.example`](zshrc.example) into `~/.zshrc` and copy over `~/.gitconfig` and `~/.config/ghostty/config`.
3. Install the ✅ core tools (mostly `apt` + `uv`), then work through the ➕ tools via the how-to notes in the order in [[Terminal-Toolkit]].

> [!tip] Keep this list honest
> When you install a ➕ tool, flip it to ✅ here. This file is the source of truth for "what's on my machine".

Index: [[Terminal-Toolkit]]
