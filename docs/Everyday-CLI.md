# 🧰 Everyday CLI — friendlier coreutils

A set of drop-in replacements for the classic Unix tools, tuned for a cloud ML workflow where you jump between repos, sift through logs, and poke at data files all day. Each tool below is installed by the repo's `setup.sh`.

## zoxide — smarter cd by frecency

`zoxide` tracks the directories you visit and lets you jump to them by a fuzzy substring instead of typing full paths, which is handy when you bounce between many repos and dataset mounts. Installed by the repo's `setup.sh`.

```sh
# Jump to the most "frecent" dir matching "train"
z train

# Match on multiple keywords (e.g. .../projects/vision/data)
z vision data

# Interactive pick among matches with fzf
zi

# See what zoxide thinks the best match is, without cd-ing
zoxide query models

# Manually add a path to the database (e.g. an S3 mount point)
zoxide add /mnt/s3/datasets
```

> [!tip] `zi` opens an interactive fuzzy picker over your ranked directories, which is the fastest way to reach a path you visit rarely but do not remember exactly.

Docs: [zoxide docs](https://github.com/ajeetdsouza/zoxide#readme)

## eza — modern ls with icons/git

`eza` is a colorful `ls` replacement with icons, a tree mode, and inline git status, which makes scanning a checkpoint directory or a busy repo much faster. In this setup `ls` and `ll` are aliased to `eza`. Installed by the repo's `setup.sh`.

```sh
# Long listing with git status and icons
eza -l --git --icons

# All files, human sizes, directories first
eza -la --header --group-directories-first

# Tree view two levels deep (skip huge nested dirs)
eza --tree --level=2

# Sort by modification time, newest last, to find the latest checkpoint
eza -l --sort=modified

# Show only directories in the current tree
eza -D
```

> [!tip] Add `--total-size` to a long listing (`eza -l --total-size`) to see real recursive directory sizes, which is a quick way to spot a bloated `checkpoints/` or `wandb/` folder.

Docs: [eza docs](https://github.com/eza-community/eza#readme)

## bat — cat with syntax highlighting and paging

`bat` prints files with syntax highlighting, line numbers, and git-change markers, and it pages automatically for long output, which beats `cat` for reading YAML manifests, configs, and training logs. Installed by the repo's `setup.sh`.

```sh
# View a Kubernetes manifest with highlighting
bat job.yaml

# Show a slice of a long training log (lines 100-140)
bat -r 100:140 train.log

# Reveal tabs, spaces, and line endings in a stubborn config
bat -A .env

# Force a language when the extension is missing
bat -l yaml deployment

# Plain output (no line numbers/decorations) for piping
bat -p requirements.txt
```

> [!tip] Set `bat` as your git pager for highlighted diffs: `git config --global core.pager 'bat --plain'`. On Ubuntu the binary may be `batcat`, this setup aliases `bat` for you.

Docs: [bat docs](https://github.com/sharkdp/bat#readme)

## ripgrep — very fast recursive search

`rg` searches your tree recursively and fast, respecting `.gitignore` by default, which is ideal for hunting a config key across a monorepo or grepping a hyperparameter through experiment code. Installed by the repo's `setup.sh`.

```sh
# Find every place a learning rate is set
rg learning_rate

# Case-insensitive, only in Python files
rg -i -t py "def train"

# List just the files that mention S3, no matched lines
rg -l s3://

# Show 3 lines of context around each CUDA error
rg -C 3 "CUDA out of memory" train.log

# Search inside ignored/hidden files too (e.g. .env, build dirs)
rg -uu AWS_ACCESS_KEY_ID
```

> [!tip] `rg --files -g '*.parquet'` lists matching filenames without searching their contents, giving you a fast, gitignore-aware way to enumerate every Parquet shard under a data directory.

Docs: [ripgrep docs](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)

## sd — intuitive find-and-replace, friendlier sed

`sd` does find-and-replace with plain regex syntax and no cryptic escaping, so bulk-editing image tags in manifests or renaming a symbol across files is far less error-prone than `sed`. Installed by the repo's `setup.sh`.

```sh
# Rewrite an image tag in a manifest, in place
sd 'myapp:v1' 'myapp:v2' deployment.yaml

# Replace with a regex and a capture group
sd 'gpus: (\d+)' 'gpus: 8' job.yaml

# Literal-string mode, no regex interpretation
sd -s 's3://old-bucket/' 's3://new-bucket/' config.yaml

# Preview changes as a diff before writing anything
sd -p 'batch_size = \d+' 'batch_size = 64' train.py

# Use it in a pipe (reads stdin, writes stdout)
kubectl get pods -o name | sd 'pod/' ''
```

> [!tip] Reach for `-p`/`--preview` first. It shows a colored diff of what would change without touching the file, which lets you sanity-check a regex before running it in place across many manifests.

Docs: [sd docs](https://github.com/chmln/sd#readme)

## tealdeer — fast tldr client for community cheat-sheets

`tealdeer` is a quick `tldr` client that shows practical, example-first cheat-sheets for commands, which saves you from digging through dense man pages for `tar`, `kubectl`, or `aws`. The command is `tldr`. Installed by the repo's `setup.sh`.

```sh
# Practical examples for a command
tldr tar

# Refresh the local cache of cheat-sheets
tldr --update

# List every page available offline
tldr --list

# Look up a specific subcommand page
tldr kubectl

# Force a platform's page (e.g. linux) explicitly
tldr --platform linux ps
```

> [!tip] Run `tldr --update` once after setup (and occasionally after) so pages work fully offline, which is useful on a jump host or inside a training pod with no outbound internet.

Docs: [tealdeer docs](https://tealdeer-rs.github.io/tealdeer/)

See also: [[Terminal-Toolkit]] (index) · [[Shell-Power-Layer]]
