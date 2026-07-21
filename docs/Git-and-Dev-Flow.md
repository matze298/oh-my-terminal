# 🔀 Git & Dev Flow — delta · lazygit · just

> [!info] Your setup (auto-detected)
> - **git** `2.43.0`, **gh** `2.45` (git credential helper), **git-lfs** configured
> - `~/.gitconfig` has no pager/diff styling yet — this note adds it
> - Companion to [[Shell-Power-Layer]] and [[Terminal-Toolkit]].

Tools that make everyday git faster to read, faster to operate, and give every repo a standard "how do I run things" entry point. Core version control (`git`, `git-lfs`, `gh`) plus the quality-of-life additions `delta`, `lazygit`, `just`, and `hyperfine`.

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

## git — everyday version control

Git tracks changes to your code and lets you move between branches without losing work. It is the foundation for the GitHub-based flow the rest of this note builds on. Installed by the repo's `setup.sh`.

```sh
# See what changed and what is staged
git status -sb

# Create and switch to a new branch in one step
git switch -c feat/data-loader

# Stage a file, then commit with a message
git add train.py && git commit -m "Add streaming data loader"

# Discard uncommitted changes to a tracked file
git restore configs/model.yaml

# Update your feature branch onto the latest main
git fetch origin && git rebase origin/main
```

> [!tip] Use `git switch` and `git restore` instead of the overloaded `git checkout`. They split branch changes and file restoration into two clear commands, so you are far less likely to blow away work by accident.

Docs: [Git docs](https://git-scm.com/doc)

## git-lfs — large files as lightweight pointers

Git LFS keeps big binaries like model checkpoints and datasets out of your Git history, storing a small pointer in the repo and the real bytes on an LFS server. This keeps clones fast and diffs readable even when a `.pt` weighs gigabytes. Installed by the repo's `setup.sh`.

```sh
# One-time setup of the LFS hooks for your user
git lfs install

# Track a file pattern (this writes to .gitattributes)
git lfs track "*.pt"

# Commit the .gitattributes change so teammates track it too
git add .gitattributes && git commit -m "Track model checkpoints with LFS"

# List the files currently managed by LFS
git lfs ls-files

# Fetch and check out the actual LFS content for your branch
git lfs pull
```

> [!tip] Run `git lfs track` before you first add a large file. If you commit a big binary without tracking it first, it lands in normal Git history, and rewriting that out later with `git lfs migrate import` is far more painful than getting the pattern in early.

Docs: [git-lfs docs](https://github.com/git-lfs/git-lfs/wiki/Tutorial)

## gh — GitHub from the terminal

The GitHub CLI brings repos, pull requests, and Actions runs into your shell, so you rarely need to leave the terminal to manage a GitHub-based workflow. It handles auth, cloning, PR review, and watching CI. Installed by the repo's `setup.sh`.

```sh
# Authenticate once, following the interactive prompts
gh auth login

# Clone one of your repos by name
gh repo clone your-org/model-training

# Create a new private repo from the current directory
gh repo create model-training --private --source=. --push

# Open a pull request for the current branch
gh pr create --fill --base main

# Check out a colleague's PR locally by number
gh pr checkout 42

# Watch the latest CI run and get notified when it finishes
gh run watch
```

> [!tip] `gh pr create --fill` pulls the title and body straight from your commit messages, so writing clear commits pays off twice. Add `--web` on any `pr` or `repo` command to jump to the same view in your browser when you want the full UI.

Docs: [gh docs](https://cli.github.com/manual/)

## hyperfine — statistical command-line benchmarking

Hyperfine runs a command many times, warms up caches, and reports mean, standard deviation, and min/max so your timings are trustworthy. It is ideal for comparing data-loading scripts or inference commands without hand-rolling `time` loops. Installed by the repo's `setup.sh`.

```sh
# Benchmark a single command
hyperfine 'python infer.py --batch 32'

# Warm up 3 runs first so cold caches do not skew results
hyperfine --warmup 3 'python load_dataset.py'

# Compare two commands head to head
hyperfine 'python infer_v1.py' 'python infer_v2.py'

# Sweep a parameter across values
hyperfine -L batch 8,16,32,64 'python infer.py --batch {batch}'

# Export a results table you can paste into this note
hyperfine --warmup 3 --export-markdown bench.md 'python infer.py'
```

> [!tip] Always pass `--warmup` for anything that touches disk or the OS page cache. The first run of a data-loading command is usually much slower, and without a warmup that outlier inflates your mean and hides the steady-state performance you actually care about.

Docs: [hyperfine docs](https://github.com/sharkdp/hyperfine#readme)

---

**Next:** [[Data-Investigation-CLI]] · [[Inspecting-Kubeflow-Pods]] · index at [[Terminal-Toolkit]]
