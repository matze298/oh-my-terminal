# 📈 System & GPU Monitoring

Fast, modern replacements for the classic `top`/`df`/`du`/`ps` tools, plus GPU monitors for training runs. Reach for these when you are triaging a slow K8s pod, checking whether a Parquet download filled the disk, or watching VRAM during a training job.

## btop — rich CPU/RAM/process/disk TUI

A polished, mouse-friendly resource monitor showing CPU, memory, disks, network, and processes in one dashboard. Great for a quick health read on a node or a jump box. Installed by the repo's `setup.sh`.

```sh
# Launch the full dashboard
btop
# Start on a saved layout preset (0-9)
btop --preset 0
# Set the refresh interval to 2000 ms
btop --update 2000
# Force UTF-8 glyphs on a stubborn or remote terminal
btop --utf-force
# Low-color mode for limited terminals (SSH into a pod)
btop --low-color
```

Most useful in-app keys:

| Key | Action |
| --- | --- |
| `Esc`, `m` | Toggle the main menu |
| `1` `2` `3` `4` | Toggle the CPU, memory, network, and process boxes |
| `e` | Toggle process tree view |
| `f` | Filter processes (type to search) |
| `Up`/`Down`, `Enter` | Select a process and open its details |
| `t` / `k` | Send SIGTERM / SIGKILL to the selected process |
| `q` | Quit |

> [!tip] Save the layout you like with the options menu, then relaunch straight into it with `btop --preset 0`. Handy for keeping a process-only view on one node and a full view on another.

Docs: [btop docs](https://github.com/aristocratos/btop#btop)

## dust — intuitive tree-based disk usage, friendlier du

A visual, tree-based `du` that sorts the biggest directories to the top with inline bars. Perfect for finding which cached dataset or checkpoint dir is eating your disk. Installed by the repo's `setup.sh`.

```sh
# Tree of the current directory, biggest first
dust
# Limit the tree to 2 levels deep
dust -d 2
# Show the top 20 largest entries under a path
dust -n 20 /var/log
# Aggregate usage by file type (spot large .parquet files)
dust -t
# Ignore a directory while scanning
dust -X node_modules .
```

> [!tip] On a huge dataset tree, cap the recursion with `dust -d 1` first to see which top-level dir dominates, then drill in. This is far faster than letting it walk millions of Parquet part files.

Docs: [dust docs](https://github.com/bootandy/dust#readme)

## duf — disk free/usage overview in a clean table, friendlier df

A `df` replacement that groups mounts into readable, color-coded tables with usage bars. Quick way to confirm a mounted PVC or an S3 FUSE mount still has headroom. Installed by the repo's `setup.sh`.

```sh
# Overview of all mounted devices
duf
# Only local disks (hide network and pseudo mounts)
duf --only local
# Inspect specific mount points
duf /home /mnt/data
# Sort rows by available space
duf --sort avail
# Include hidden and pseudo filesystems too
duf --all
# Machine-readable output for scripts
duf --json
```

> [!tip] Piping `duf --json` into `jq` lets you assert free space in a CI or pre-training check, for example failing early if the checkpoint volume is under a threshold before a long GPU run starts.

Docs: [duf docs](https://github.com/muesli/duf#readme)

## procs — modern ps with color, tree, search

A colorized `ps` with keyword search, a process tree, sortable columns, and a live watch mode. Ideal for finding a specific training worker or data-loader process by name. Installed by the repo's `setup.sh`.

```sh
# List all processes with colorized columns
procs
# Search by name or PID
procs python
# Process tree showing parent/child relationships
procs --tree
# Sort descending by CPU usage
procs --sortd cpu
# Match multiple keywords (logical AND)
procs --and python train
# Auto-refreshing live view
procs --watch
```

> [!tip] `procs --and` narrows to processes matching every keyword, so `procs --and python train` isolates your training script from every other Python process on a busy node.

Docs: [procs docs](https://github.com/dalance/procs#readme)

## nvtop — htop-style GPU monitor (util, VRAM, per-process)

An htop-like TUI for GPUs, plotting utilization and VRAM over time and listing the processes on each device. Your first look when a training job stalls or VRAM creeps toward an OOM. Installed by the repo's `setup.sh`.

```sh
# Launch the GPU monitor
nvtop
# Refresh every 0.5 s (delay is in tenths of a second)
nvtop -d 5
# Monochrome mode for basic terminals
nvtop -C
```

Most useful in-app keys:

- `F2`: open the setup window (choose visible GPUs and columns)
- `F6`: sort the process list by a field
- `Up`/`Down`: select a process
- `F9`: send a signal to (kill) the selected process
- `F10` or `q`: quit

> [!tip] Watch the VRAM plot climb during the first few training steps. If it keeps rising step after step instead of leveling off, you likely have a memory leak (for example holding tensors in a Python list) rather than a genuinely too-large batch.

Docs: [nvtop docs](https://github.com/Syllo/nvtop#readme)

## nvitop — richer GPU/process view

An interactive monitor with more detail than nvtop, including per-process GPU memory, host CPU and memory, and user attribution. Great on shared GPU boxes where you need to see who is running what. Installed by the repo's `setup.sh`.

```sh
# Launch the interactive monitor
nvitop
# Full layout with all panels
nvitop -m full
# Compact layout
nvitop -m compact
# Show only GPUs 0 and 1
nvitop -o 0 1
# Filter processes to your own user
nvitop -u $USER
```

Most useful in-app keys:

- `a` / `f` / `c`: switch to auto, full, or compact display mode
- `Up`/`Down`, `Tab`: select a process and switch panels
- `T` / `K` / `I`: send SIGTERM / SIGKILL / SIGINT to the selected process
- `e`: show the selected process's environment variables
- `h`: help, `q`: quit

> [!tip] On a shared node, `nvitop -u $USER` shows only your processes so you can reclaim your own leaked GPU memory without touching a colleague's job. Press `e` on a process to confirm its `CUDA_VISIBLE_DEVICES` before you send a signal.

Docs: [nvitop docs](https://github.com/XuehaiPan/nvitop#readme)

See also: [[Terminal-Toolkit]] (index)
