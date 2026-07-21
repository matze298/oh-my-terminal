# 🧰 Terminal Toolkit — Index

A curated, **portable** CLI stack for a cloud-focused **machine learning engineer**. The shell and command-line tools below run the same on native Ubuntu, WSL, or a remote server. The terminal *emulator* ([[Ghostty-Hands-On-Intro|Ghostty]]) is a separate, environment-specific layer (Linux/macOS only) and lives in its own folder. Each note is hands-on and tuned to this setup.

Install any subset with the interactive `setup.sh` at the repo root, the notes below explain what each tool gives you and how to use it.

## The notes (portable core)

| Note | Tools | What it gives you |
|---|---|---|
| [[Setup-Inventory]] | (everything, at a glance) | Full parts list + Core/Opt tiers to reproduce this setup |
| [[Zsh-Setup-Reference]] | zsh · oh-my-zsh · agnoster · starship · Nerd Font | The shell foundation and prompt |
| [[Everyday-CLI]] | zoxide · eza · bat · ripgrep · sd · tealdeer | Friendlier coreutils for daily work |
| [[Shell-Power-Layer]] | fzf · fd · atuin | Fuzzy history/files/dirs + a real history database, **start here** |
| [[Sessions-and-Files]] | tmux · zellij · yazi | Persistent SSH sessions and a file manager |
| [[Git-and-Dev-Flow]] | git · git-lfs · gh · delta · lazygit · just · hyperfine | Version control, readable diffs, a git TUI, benchmarking |
| [[Data-Investigation-CLI]] | jq · yq · jnv · duckdb · visidata · s5cmd · csvlens | Inspect JSON/YAML and Parquet/CSV/S3 |
| [[Inspecting-Kubeflow-Pods]] | kubectl · kubecolor · k9s · stern | Debug the pods running your pipeline steps |
| [[Kubernetes-Packaging]] | helm · kustomize | Render and diff manifests before applying |
| [[Switching-Contexts-Optional]] | kubectx · kubens | Hop between clusters/namespaces |
| [[System-Monitoring]] | btop · dust · duf · procs · nvtop · nvitop | System and GPU resource monitors |
| [[Containers]] | lazydocker · dive | Docker TUI and image-layer inspection |
| [[Python-and-Runtimes]] | uv · go | Python env management and the Go toolchain |

## Terminal emulator (environment-specific)

Not part of the portable toolkit. Use Ghostty on **Linux/macOS**; on **WSL** drive these tools through the Windows host terminal (e.g. Windows Terminal) instead.

- [[Ghostty-Hands-On-Intro]] · [[Ghostty-Config-Starter]] — GPU-accelerated emulator (splits, tabs, live config reload)

## Suggested install order

1. **[[Shell-Power-Layer]]** — `fzf` is the connective tissue; everything else feels better once it's in.
2. **[[Git-and-Dev-Flow]]** — daily git becomes readable and fast.
3. Then **[[Data-Investigation-CLI]]** and **[[Inspecting-Kubeflow-Pods]]** as your work needs them.

## Tools at a glance

Everything the installer can set up, grouped by what it helps with (full
descriptions in [[Setup-Inventory]]; core vs opt tiers in `lib/tools.manifest`):

- **Shell & prompt**: zsh · oh-my-zsh · agnoster · Nerd Font · zsh-autosuggestions · zsh-syntax-highlighting · starship
- **Navigation & files**: zoxide · eza · bat · fd · fzf · yazi
- **Search & text**: ripgrep · sd · jq · yq · jnv
- **Sessions**: tmux · zellij
- **History & discovery**: atuin · tealdeer
- **Git & dev**: git · git-lfs · gh · delta · lazygit · just · direnv · hyperfine
- **Python & data**: uv · duckdb · visidata · csvlens · s5cmd
- **Kubernetes**: kubectl · helm · kustomize · kubecolor · k9s · stern · kubectx
- **Containers**: lazydocker · dive
- **System & GPU**: btop · dust · duf · procs · nvtop · nvitop

`kubectx`/`kubens` are only worth it if you juggle more than one cluster or
namespace, see [[Switching-Contexts-Optional]].
