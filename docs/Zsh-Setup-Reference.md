# 🐚 Your zsh Setup — Quick Reference

> [!info] Auto-detected from `~/.zshrc`
> Ubuntu 24.04.4, **zsh** `5.9`, **oh-my-zsh** (theme `agnoster`). This is a snapshot of what you already run, plus the two PATH lines the other notes rely on.

## What's already active

| You type | You get | Source |
|---|---|---|
| `z <dir>` / `zi` | Jump to a frecency-ranked dir / pick interactively | zoxide `0.9.3` |
| `ls` / `ll` | eza with icons, colors, dirs-first (`ll` = long + hidden) | alias → eza |
| `bat <file>` | Syntax-highlighted `cat` with paging | alias → batcat |
| `<start of cmd>` → `→` / `End` | Accept the greyed-out suggestion | zsh-autosuggestions |
| (as you type) | Commands turn green/red for valid/invalid | zsh-syntax-highlighting |
| `google <query>` | Web search from the shell | oh-my-zsh `web-search` |
| `copypath` / `copyfile` | Copy CWD path / file contents to clipboard | oh-my-zsh plugins |
| `gst` `gco` `gp` `gl` … | Git shortcuts | oh-my-zsh `git` plugin |
| `cd <dir with .envrc>` | Auto-load project env | direnv `2.32` |

**Plugins loaded:** `git zsh-autosuggestions zsh-syntax-highlighting web-search copypath copyfile`
Full git alias list: `alias | grep "='git"`.

## Two PATH lines to add

Several tools in the other notes install into `~/.local/bin` (duckdb, `uv tool install ...`) or `~/go/bin` (`go install ...`). zsh doesn't pick these up by default, so add:

```sh
# ~/.zshrc  (near the top, before other tool setup)
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
```

After `uv tool install ...`, you can also run `uv tool update-shell` to have uv manage its own PATH entry.

## Full example config

A complete, commented reference `~/.zshrc` (this base plus the toolkit additions) lives at [`zshrc.example`](zshrc.example). Copy the parts you want, it is not meant to be run as-is.

## Where to go next

The rest of the toolkit builds on this base:

- [[Shell-Power-Layer]] — fzf, fd, atuin (the biggest upgrade; adds a `~/.zshrc` block)
- [[Git-and-Dev-Flow]] — delta, lazygit, just
- [[Data-Investigation-CLI]] — duckdb, visidata, s5cmd
- [[Inspecting-Kubeflow-Pods]] — kubectl, k9s, stern
- [[Terminal-Toolkit]] — the index / install order
- [[Ghostty-Hands-On-Intro]] — your terminal emulator
