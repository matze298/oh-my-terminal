# ⚡ Shell Power Layer — fzf · fd · atuin

> [!info] Your setup (auto-detected)
> - **OS**: Ubuntu 24.04.4 LTS, **zsh** `5.9` + oh-my-zsh (theme `agnoster`)
> - **Already have**: zoxide `0.9.3` (`z`), eza (`ls`/`ll`), bat (`batcat`) `0.24`, ripgrep `14.1`
> - **This note installs**: `fzf`, `fd`, `atuin` — none present yet
> - **GPU**: NVIDIA RTX PRO 4000 Blackwell (driver `580`) → GPU monitors at the end
> - Companion to [[Zsh-Setup-Reference]] and [[Ghostty-Hands-On-Intro]].

This is the layer that makes everything else feel 10x. `fzf` is the connective tissue: it turns history, files, `git`, `kubectl`, and `zoxide` into interactive fuzzy pickers. `fd` feeds it fast. `atuin` gives your 125k-line history a real database.

Work through the checkboxes with a terminal open.

---

## 1. fzf — the fuzzy finder everything plugs into

**Install (apt, quick start):**

```sh
sudo apt install fzf
```

Ubuntu's `fzf` (`0.44`) ships its shell integration as files you source. Confirm the exact paths, then add them to `~/.zshrc`:

```sh
dpkg -L fzf | grep -E '\.zsh$'     # shows key-bindings.zsh and completion.zsh
```

```sh
# ~/.zshrc  (after `source $ZSH/oh-my-zsh.sh`)
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh
```

> [!tip] Want the latest fzf instead
> The apt build is a year behind. For newest features (including `source <(fzf --zsh)`), install from source:
> ```sh
> git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --key-bindings --completion --no-update-rc
> ```
> Then `source ~/.fzf.zsh` in `~/.zshrc` and skip the apt sourcing lines above.

**The three key bindings you'll use constantly:**

| Key | What it does |
|---|---|
| `ctrl+r` | Fuzzy-search command **history** (replaces zsh's default) |
| `ctrl+t` | Fuzzy-pick a **file/dir** and insert its path at the cursor |
| `alt+c` | Fuzzy-pick a directory and **cd** into it |
| `**<tab>` | Fuzzy-complete **any** command's argument (see below) |

- [x] Press `ctrl+r`, type fragments of an old command, `enter` to run it
- [x] Type `vim ` then `ctrl+t`, pick a file, watch the path drop in
- [x] `alt+c` into a deep directory without typing the path

**The `**<tab>` trigger** works on almost any command:

```sh
kill -9 **<tab>          # pick a process
cd **<tab>               # pick a directory
git checkout **<tab>     # pick a branch/file
ssh **<tab>              # pick a known host
```

**Pipe anything into fzf** for ad-hoc pickers:

```sh
git branch | fzf                       # pick a branch
docker ps --format '{{.Names}}' | fzf  # pick a container
```

---

## 2. fd — fast, sane `find` (and fzf's engine)

**Install** (on Ubuntu the binary is `fdfind`, so alias it):

```sh
sudo apt install fd-find
```

```sh
# ~/.zshrc
alias fd='fdfind'
```

Why it beats `find`: respects `.gitignore`, skips hidden junk by default, colorized, regex-friendly, and *fast*.

```sh
fd report            # every path matching "report"
fd -e parquet        # all .parquet files
fd -H -e py train    # include hidden; .py files matching "train"
fd -t d checkpoints  # directories only
```

**Wire it into fzf** so `ctrl+t` / `alt+c` use it (faster, respects `.gitignore`), and add a `bat` preview:

```sh
# ~/.zshrc
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 60% --layout reverse --border --preview 'batcat --color=always --style=numbers {} 2>/dev/null | head -200'"
```

- [x] Reload (`source ~/.zshrc`), press `ctrl+t`, confirm you see the `bat` preview pane

---

## 3. atuin — your shell history, upgraded to a database

Your `.zsh_history` has ~125k lines that plain `ctrl+r` can barely search. `atuin` records every command into SQLite with timestamp, directory, exit code, and duration, then gives you a full-screen fuzzy search.

**Install** (not in apt — official installer):

```sh
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
```

```sh
# ~/.zshrc  (put this LAST, after fzf's sourcing)
eval "$(atuin init zsh --disable-up-arrow)"
```

> [!warning] atuin takes over `ctrl+r`
> `atuin init` rebinds `ctrl+r` to its own search UI, overriding fzf's. That's usually what you want — atuin's search is richer. fzf keeps `ctrl+t` and `alt+c`. `--disable-up-arrow` leaves your up-arrow doing normal zsh line recall instead of opening atuin.

**Daily use:**

| Command / key | What it does |
|---|---|
| `ctrl+r` | Full-screen fuzzy history search (scoped, ranked) |
| `atuin search --cwd . <term>` | History run *in this directory* |
| `atuin stats` | Top commands, busiest days |
| `atuin search -e 0 <term>` | Only commands that **succeeded** (exit 0) |

- [x] Press `ctrl+r`, search a command, note the exit-code/time columns
- [x] Run `atuin stats` to see your most-used commands

> [!tip] Sync is optional and off by default
> atuin works fully offline. End-to-end encrypted sync across machines is opt-in (`atuin register` / `atuin login`) and you can self-host the server. Skip it entirely if you only use one box.

---

## 4. Bonus — GPU monitors for the DL box

`btop` (you have it) covers CPU/RAM. For your NVIDIA GPU during training:

| Tool     | Install                  | Why                                                                |
| -------- | ------------------------ | ------------------------------------------------------------------ |
| `nvtop`  | `sudo apt install nvtop` | `htop`-style TUI for GPU util, memory, per-process VRAM            |
| `nvitop` | `uv tool install nvitop` | Richer view: tree of GPU processes, colored bars, `nvitop -m full` |

```sh
nvtop            # live GPU dashboard
nvitop           # or the fancier one
watch -n1 nvidia-smi   # the no-install fallback
```

- [x] Run `nvtop` while a training job is active

---

## The full `~/.zshrc` block to add

Paste this after `source $ZSH/oh-my-zsh.sh` (order matters — fzf first, atuin last):

```sh
# --- fuzzy finding ---
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh
alias fd='fdfind'
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 60% --layout reverse --border --preview 'batcat --color=always --style=numbers {} 2>/dev/null | head -200'"

# --- smarter history (keep last) ---
eval "$(atuin init zsh --disable-up-arrow)"
```

- [x] Add the block, `source ~/.zshrc`, sanity-check `ctrl+r`, `ctrl+t`, `alt+c`

---

**Next:** [[Git-and-Dev-Flow]] · [[Data-Investigation-CLI]] · [[Inspecting-Kubeflow-Pods]] · index at [[Terminal-Toolkit]]
