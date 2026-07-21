# 🗂️ Sessions & Files

Your daily workhorses for keeping remote work alive and moving around files. The multiplexers keep training jobs running when your SSH connection drops, and the file manager lets you browse Parquet trees and logs without leaving the terminal.

## tmux — persistent sessions that survive SSH drops

tmux is a terminal multiplexer that keeps your shells running on the remote host even after you disconnect. This is the difference between a dropped VPN losing a 6-hour training run and just reattaching to find it still going. Installed by the repo's `setup.sh`.

```sh
# Start a named session on the training box, then launch your job
tmux new -s train

# List sessions after reconnecting over SSH
tmux ls

# Reattach to the running training session
tmux attach -t train

# One-liner: attach if it exists, otherwise create it
tmux new -A -s train

# Tear it down once the run is done
tmux kill-session -t train
```

Key bindings (default prefix is Ctrl-b: press it, release, then the key):

| Keys | Action |
| --- | --- |
| `Ctrl-b` `d` | Detach (session keeps running) |
| `Ctrl-b` `c` | New window |
| `Ctrl-b` `n` / `p` | Next / previous window |
| `Ctrl-b` `%` | Split pane vertically (side by side) |
| `Ctrl-b` `"` | Split pane horizontally (stacked) |
| `Ctrl-b` arrow | Move between panes |
| `Ctrl-b` `z` | Zoom the current pane full screen |
| `Ctrl-b` `[` | Enter copy mode to scroll back through logs |

> [!tip] Run tmux on the remote host, not on your laptop. Start the session right after you SSH in, launch training inside it, then detach with `Ctrl-b` `d`. When your laptop sleeps or the network flaps, the job never notices, you just `ssh` back and `tmux attach -t train`.

Docs: [tmux docs](https://github.com/tmux/tmux/wiki/Getting-Started)

## zellij — modern multiplexer with discoverable keybinds

zellij does the same persistent-session job as tmux but shows a live keybinding hint bar at the bottom, so you never have to memorize a cheat sheet. Panes, tabs, and reusable layouts make it easy to lay out a training pane, a `watch nvidia-smi` pane, and a log tail at once. Installed by the repo's `setup.sh`.

```sh
# Start a named session for your GPU work
zellij -s train

# List running sessions after reconnecting
zellij ls

# Attach to an existing session over SSH
zellij attach train

# Attach if present, otherwise create it
zellij attach --create train

# Remove an old exited session
zellij delete-session train
```

Key bindings (zellij is modal: press a mode key, then act):

| Keys | Action |
| --- | --- |
| `Ctrl-o` `d` | Detach (session keeps running) |
| `Ctrl-p` then `n` | Pane mode, new pane |
| `Ctrl-p` then `d` / `r` | Split down / to the right |
| `Ctrl-p` then `f` | Toggle fullscreen for the pane |
| `Ctrl-p` then `x` | Close the focused pane |
| `Ctrl-t` then `n` | Tab mode, new tab |
| `Ctrl-s` | Scroll and search mode (page back through output) |

> [!tip] Detaching is `Ctrl-o` then `d`, which is easy to confuse with quitting. `Ctrl-q` quits and ends the session, killing whatever runs inside it. When you want your training to survive, always detach with `Ctrl-o` `d`, never `Ctrl-q`.

Docs: [zellij docs](https://zellij.dev/documentation/)

## yazi — blazing-fast file manager with previews

yazi is a terminal file manager with instant previews, so you can walk a partitioned Parquet tree, eyeball checkpoint directories, and skim log files without opening each one. It is fast enough to feel instant even on directories with thousands of shards. Installed by the repo's `setup.sh`.

```sh
# Open the file manager in the current directory
yazi

# Open straight into your dataset directory
yazi /data/parquet

# Browse checkpoints on the remote box over SSH
yazi ~/runs/train/checkpoints

# Write the final directory to a file so your shell can cd there on exit
yazi --cwd-file=/tmp/yazi-cwd
cd "$(cat /tmp/yazi-cwd)"
```

Key bindings:

| Keys | Action |
| --- | --- |
| `h` `j` `k` `l` | Parent dir, down, up, enter dir / open |
| `gg` / `G` | Jump to top / bottom |
| `.` | Toggle hidden files |
| `Space` | Toggle selection and move down |
| `y` / `x` / `p` | Yank (copy) / cut / paste |
| `d` / `D` | Move to trash / delete permanently |
| `s` / `S` | Search files with `fd` / grep contents with `ripgrep` |
| `z` / `Z` | Jump with zoxide / fuzzy-find with fzf |
| `q` | Quit |

> [!tip] yazi cannot change your shell's directory on its own. Wrap it in a shell function that uses `--cwd-file`, so quitting drops you into the directory you were browsing. This turns yazi into a visual `cd` for deep, sharded dataset trees, and preview panes work over SSH too.

Docs: [yazi docs](https://yazi-rs.github.io/)

See also: [[Terminal-Toolkit]] (index)
