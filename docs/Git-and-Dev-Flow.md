# 🔀 Git & Dev Flow — delta · lazygit · just

> [!info] Your setup (auto-detected)
> - **git** `2.43.0`, **gh** `2.45` (git credential helper), **git-lfs** configured
> - `~/.gitconfig` has no pager/diff styling yet — this note adds it
> - Companion to [[Shell-Power-Layer]] and [[Terminal-Toolkit]].

Three tools that make everyday git faster to read, faster to operate, and give every repo a standard "how do I run things" entry point.

---

## 1. delta — diffs you can actually read

**Install** (apt package is `git-delta`, binary is `delta`):

```sh
sudo apt install git-delta
```

**Configure** `~/.gitconfig` (append these sections):

```ini
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only
[delta]
    navigate = true          # n / N jump between files in the diff
    line-numbers = true
    side-by-side = true
    syntax-theme = Nord
[merge]
    conflictStyle = zdiff3   # clearer conflict markers
[diff]
    colorMoved = default     # highlight moved lines distinctly
```

Now every diff-producing command is prettier automatically:

```sh
git diff            # side-by-side, syntax-highlighted, line numbers
git show HEAD
git log -p          # press n / N to jump file-to-file
```

- [ ] Run `git diff` in a repo with changes and confirm side-by-side output
- [ ] In `git log -p`, press `n` to jump to the next file

> [!tip] Turn off side-by-side on narrow panes
> In a small Ghostty split, `side-by-side = false` reads better. Toggle per-command: `git -c delta.side-by-side=false diff`.

---

## 2. lazygit — a full git TUI

Stage hunks, commit, rebase, cherry-pick, resolve conflicts, and browse history without memorizing flags.

**Install** (not in apt — official release binary to `/usr/local/bin`):

```sh
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit && sudo install /tmp/lazygit /usr/local/bin
```

Launch inside any repo:

```sh
lazygit          # tip: alias lg='lazygit'
```

| Key | Action |
|---|---|
| `space` | Stage / unstage the selected file or hunk |
| `c` | Commit (opens message editor) |
| `P` / `p` | Push / pull |
| `+` / `_` | Next / previous panel |
| `z` / `Z` | Undo / redo (reflog-backed) |
| `?` | Context-sensitive help (start here) |

- [ ] Open `lazygit`, stage a file with `space`, commit with `c`
- [ ] Press `?` to see every keybind for the focused panel

---

## 3. just — a modern command runner

A `justfile` is a Makefile without the tabs-and-phony-targets pain: a place to park the commands each repo actually needs, so "how do I train / lint / serve this" is always `just <thing>`.

**Install:**

```sh
sudo apt install just
```

Drop a `justfile` in a repo root:

```make
# justfile
set dotenv-load                      # auto-load .env

default:
    @just --list                     # bare `just` shows available recipes

setup:
    uv sync

train epochs="10":
    uv run python train.py --epochs {{epochs}}

lint:
    uv run ruff check .

tb:
    uv run tensorboard --logdir runs/
```

```sh
just             # list recipes
just setup
just train epochs=50
```

- [ ] Add a `justfile` with a `setup` and `train` recipe to a current project
- [ ] Run `just` to list, then `just setup`

> [!tip] Pairs with direnv
> You already have `direnv`. Put project env in `.envrc` (auto-loaded on `cd`) and `set dotenv-load` lets `just` recipes see the same variables.

---

**Next:** [[Data-Investigation-CLI]] · [[Inspecting-Kubeflow-Pods]] · index at [[Terminal-Toolkit]]
