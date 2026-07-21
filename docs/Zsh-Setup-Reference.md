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

## The foundation tools

These are the pieces that make up the shell foundation itself. Most are configured in `~/.zshrc` rather than run as commands.

## oh-my-zsh — framework that manages your plugins, themes, and completions

oh-my-zsh is a community framework for zsh that wires up plugins, themes, and completions from a single `~/.zshrc`. It saves you from hand-rolling completion and prompt boilerplate. Installed by the repo's `setup.sh`.

```sh
# ~/.zshrc: enable plugins (space-separated, no commas)
plugins=(git docker kubectl aws terraform)

# Pick a theme (see the agnoster section below)
ZSH_THEME="agnoster"

# Update the framework and bundled plugins on demand
omz update
```

> [!tip] Reload changes without opening a new terminal by running `omz reload` (or `exec zsh`) after editing `~/.zshrc`.

Docs: [oh-my-zsh wiki](https://github.com/ohmyzsh/ohmyzsh/wiki)

## agnoster theme — powerline prompt with git status and path segments

agnoster is a Powerline-style oh-my-zsh theme that renders your path, git branch, and dirty state as colored arrow segments. It needs a Nerd Font so the arrow and branch glyphs display correctly. Installed by the repo's `setup.sh`.

```sh
# ~/.zshrc: activate the theme
ZSH_THEME="agnoster"

# Hide the "user@host" segment when you are the default local user
DEFAULT_USER="$USER"
```

> [!tip] agnoster shows a lightning-bolt segment when the previous command exited non-zero, so a red segment after a run means your last command failed.

Docs: [agnoster docs](https://github.com/agnoster/agnoster-zsh-theme#readme)

## FiraCode Nerd Font — monospace font with ligatures and icon glyphs

FiraCode Nerd Font is a patched monospace font that adds programming ligatures plus the icon glyphs that Powerline themes and prompts like agnoster and starship rely on. Set it as your terminal emulator's font, since the shell itself cannot choose the font. Installed by the repo's `setup.sh`.

```sh
# Confirm the font is installed on your system
fc-list | grep -i firacode

# List just the family names available
fc-list : family | grep -i "FiraCode Nerd Font"
```

> [!tip] Set your terminal font to "FiraCode Nerd Font Mono" (the Mono variant keeps glyphs single-width) so prompt segments and icons line up correctly.

Docs: [Nerd Fonts installation docs](https://github.com/ryanoasis/nerd-fonts#font-installation)

## zsh-autosuggestions — greyed-out inline suggestions from your history

zsh-autosuggestions predicts the rest of your command from your history and shows it as greyed-out text as you type. Accept it with the Right-arrow or End key, which is a big time saver for long, repeated commands like kubectl and aws invocations. Installed by the repo's `setup.sh`.

```sh
# ~/.zshrc: add it as an oh-my-zsh custom plugin
plugins=(git zsh-autosuggestions)

# Optional: accept only the next word with Ctrl+Right
bindkey '^[[1;5C' forward-word
```

> [!tip] If a suggestion is hard to read against your color scheme, tune it with `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"` in `~/.zshrc` before oh-my-zsh loads.

Docs: [zsh-autosuggestions docs](https://github.com/zsh-users/zsh-autosuggestions#readme)

## zsh-syntax-highlighting — colors your command line as you type

zsh-syntax-highlighting validates your command line in real time, coloring known commands green and unknown ones red before you press Enter. It catches typos and bad paths early. Load it last so it can wrap the other plugins' widgets. Installed by the repo's `setup.sh`.

```sh
# ~/.zshrc: this plugin MUST be the last entry in the list
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

> [!tip] Red command text means zsh cannot find that executable on your `PATH`, so a red `kubectl` usually points to a broken install or a missing shell rehash rather than a typo.

Docs: [zsh-syntax-highlighting docs](https://github.com/zsh-users/zsh-syntax-highlighting#readme)

## starship — fast cross-shell prompt with cloud-native context

starship is a fast, Rust-based prompt that shows git state, Kubernetes context, active Python venv, and command duration out of the box. It is a drop-in alternative to agnoster and works the same way across zsh, bash, and fish. When installed, this repo's `~/.zshrc` initializes it automatically (overriding the agnoster theme). Installed by the repo's `setup.sh`.

```sh
# ~/.zshrc: initialize starship (this setup does this for you)
eval "$(starship init zsh)"
```

```toml
# ~/.config/starship.toml: surface cloud-native context
[kubernetes]
disabled = false        # off by default, turn it on

[python]
format = 'via [${symbol}${version}(\($virtualenv\))]($style) '
```

> [!tip] The kubernetes module is disabled by default, so set `disabled = false` under `[kubernetes]` to see your current cluster and namespace before you run any kubectl command.

Docs: [starship config docs](https://starship.rs/config/)

## Where to go next

The rest of the toolkit builds on this base:

- [[Shell-Power-Layer]] — fzf, fd, atuin (the biggest upgrade; adds a `~/.zshrc` block)
- [[Git-and-Dev-Flow]] — delta, lazygit, just
- [[Data-Investigation-CLI]] — duckdb, visidata, s5cmd
- [[Inspecting-Kubeflow-Pods]] — kubectl, k9s, stern
- [[Terminal-Toolkit]] — the index / install order
- [[Ghostty-Hands-On-Intro]] — your terminal emulator
