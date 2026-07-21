# 🔎 Data Investigation CLI — duckdb · visidata · s5cmd

> [!info] Your setup (auto-detected)
> - **Python** `3.12` + **uv** `0.11`, AWS creds present (`~/.aws`)
> - `aws` CLI is **not** installed — `s5cmd` below doesn't need it, it reads `~/.aws` directly
> - Companion to [[Shell-Power-Layer]] and [[Terminal-Toolkit]].

You're on the *consumer* end: the data team hands you Parquet/CSV (often on S3), and you need to inspect it, sanity-check it, and pull it down for deep-learning training. These three tools do exactly that from the terminal, no notebook or warehouse required.

---

## 1. duckdb — SQL over Parquet/CSV/S3, in-process

An embedded analytics engine that queries files *directly*. No server, no import step. Perfect for "what's actually in this dataset before I train on it".

**Install** (not in apt — official installer, lands in `~/.local/bin`):

```sh
curl https://install.duckdb.org | sh
```

Ensure `~/.local/bin` is on your `PATH` (see [[Zsh-Setup-Reference]]).

**The pre-training checks you'll run most:**

```sh
# Peek at rows
duckdb -c "SELECT * FROM 'train.parquet' LIMIT 5"

# Schema and types
duckdb -c "DESCRIBE SELECT * FROM 'train.parquet'"

# Stats per column: nulls, min/max, distinct, quantiles — one command
duckdb -c "SUMMARIZE SELECT * FROM 'train.parquet'"

# Class balance
duckdb -c "SELECT label, count(*) AS n FROM 'train.parquet' GROUP BY label ORDER BY n DESC"

# Null count for a suspect column
duckdb -c "SELECT count(*) FILTER (WHERE feature IS NULL) AS nulls FROM 'train.parquet'"
```

**Globs and sharded datasets** just work:

```sh
duckdb -c "SELECT count(*) FROM 'shards/*.parquet'"
```

**Query S3 directly** (uses your `~/.aws` credential chain):

```sh
duckdb -c "
  INSTALL httpfs; LOAD httpfs;
  SET s3_region='eu-central-1';
  SELECT count(*) FROM 's3://my-bucket/dataset/*.parquet';
"
```

**Convert / sample** for a quick local subset to iterate on:

```sh
duckdb -c "COPY (SELECT * FROM 'train.parquet' USING SAMPLE 5%) TO 'sample.csv' (HEADER)"
```

**Into pandas** when you want a DataFrame for training code:

```python
import duckdb
df = duckdb.query("SELECT * FROM 'train.parquet' WHERE split='train'").df()
```

- [ ] Run `SUMMARIZE` on a real dataset and read the null/distinct columns
- [ ] Check class balance with a `GROUP BY` query

> [!tip] Interactive session
> Just run `duckdb` for a REPL. `.mode box` for pretty tables, `.timer on` to see query time, `.quit` to exit.

---

## 2. visidata (vd) — a spreadsheet TUI for any file

When you'd rather *eyeball* the data than write SQL. Opens CSV, Parquet, JSON, Excel, and more in an interactive terminal grid.

**Install** (via uv so Parquet support is included):

```sh
uv tool install --with pyarrow --with pandas visidata
```

```sh
vd train.parquet
vd data.csv
```

| Key | Action |
|---|---|
| `ctrl+h` | **Help** — searchable list of every command (start here) |
| `Shift+F` | Frequency table / histogram of the current column |
| `[` / `]` | Sort ascending / descending by current column |
| `Shift+I` | Describe sheet: stats for every column |
| `/` | Search rows in the current column |
| `Enter` | Dive into the selected cell/row |
| `gq` | Quit everything |

- [ ] Open a Parquet file, move to a column, press `Shift+F` for its distribution
- [ ] Press `Shift+I` for a full-column stats summary

---

## 3. s5cmd — fast S3 transfers for getting data local

Parallelized S3 client, dramatically faster than the standard CLI for many/large objects. Reads your `~/.aws` profiles.

**Install** (not in apt — you have Go `1.22`, so):

```sh
go install github.com/peak/s5cmd/v2@latest    # lands in ~/go/bin (ensure it's on PATH)
```

Prefer no build? Grab a release tarball from `github.com/peak/s5cmd/releases` and `sudo install s5cmd /usr/local/bin`.

**Everyday use:**

```sh
s5cmd ls s3://my-bucket/dataset/                       # browse
s5cmd du s3://my-bucket/dataset/                        # total size before pulling
s5cmd cp 's3://my-bucket/dataset/*.parquet' ./data/     # parallel download
s5cmd --numworkers 32 cp 's3://.../*.parquet' ./data/   # crank parallelism
AWS_PROFILE=research s5cmd ls s3://other-bucket/         # pick a profile
s5cmd --dry-run cp 's3://.../*' ./data/                  # preview, transfer nothing
```

- [ ] `s5cmd du` a prefix to see its size, then `s5cmd cp` a subset locally

> [!tip] Chain it with duckdb
> Pull a shard locally with `s5cmd`, then `duckdb -c "SUMMARIZE SELECT * FROM './data/*.parquet'"` to validate before committing to a full download.

---

## jq — command-line JSON processor

`jq` slices, filters, and transforms JSON with a small expression language, which makes it your default lens on API responses and `kubectl -o json` output. Installed by the repo's `setup.sh`.

```sh
# Pretty-print (and validate) a JSON file
jq . response.json

# Pull one field as raw text, no surrounding quotes
jq -r '.metadata.name' pod.json

# Filter an array, then project two fields into a compact object
kubectl get pods -o json | jq '.items[] | select(.status.phase != "Running") | {name: .metadata.name, phase: .status.phase}'

# Build a TSV row per item for downstream tools
kubectl get nodes -o json | jq -r '.items[] | [.metadata.name, .status.nodeInfo.kubeletVersion] | @tsv'

# Count items grouped by a key
jq -r 'group_by(.status.phase) | map({phase: .[0].status.phase, count: length})' pods.json
```

> [!tip] Pass shell values in safely with `--arg` (string) or `--argjson` (parsed JSON) instead of interpolating into the filter, e.g. `jq --arg ns prod '.items[] | select(.metadata.namespace == $ns)'`.

Docs: [jq manual](https://jqlang.org/manual/)

## yq — jq for YAML

`yq` (mikefarah/yq) brings jq-style expressions to YAML, so you can read and edit Kubernetes manifests and Helm values in place. It also converts between YAML and JSON, which lets you round-trip manifests through the jq ecosystem. Installed by the repo's `setup.sh`.

```sh
# Read a nested field from a manifest
yq '.spec.replicas' deployment.yaml

# Convert YAML to JSON (then hand off to jq if you like)
yq -o=json '.' values.yaml

# Edit in place: bump the replica count
yq -i '.spec.replicas = 5' deployment.yaml

# Select containers and print their images across a multi-doc file
yq '.spec.template.spec.containers[].image' deployment.yaml

# Merge Helm values files, later files winning
yq eval-all '. as $item ireduce ({}; . * $item)' base.yaml override.yaml
```

> [!tip] A multi-document manifest (objects separated by `---`) is handled with `yq ea` (`eval-all`) when you need to see or combine all documents at once rather than one at a time.

Docs: [yq docs](https://mikefarah.gitbook.io/yq/)

## jnv — interactive JSON viewer with live jq filtering

`jnv` opens JSON in a TUI where you type a jq-style filter and see the result update live, which beats re-running `jq` while you hunt for the right path. Installed by the repo's `setup.sh`.

```sh
# Explore a JSON file interactively
jnv response.json

# Pipe live cluster state straight in
kubectl get pods -o json | jnv

# Inspect an API response without saving it first
curl -s https://api.example.com/v1/items | jnv
```

> [!tip] Start broad with `.` to see the whole tree, then refine the filter incrementally (for example `.items[]` then `.items[].metadata`). The key completion helps you discover the structure as you type.

Docs: [jnv docs](https://github.com/ynqa/jnv#readme)

## csvlens — less for CSV/TSV tables

`csvlens` is a terminal pager built for tabular data, giving you aligned columns, scrolling, and in-app search over CSV or TSV files without leaving the shell. Installed by the repo's `setup.sh`.

```sh
# Open a CSV with aligned columns
csvlens data.csv

# View a tab-separated file
csvlens -d '\t' data.tsv

# View jq-generated TSV via stdin (tell csvlens the delimiter)
kubectl get pods -o json | jq -r '.items[] | [.metadata.name, .status.phase] | @tsv' | csvlens -d '\t'

# Open a semicolon-delimited export
csvlens -d ';' export.csv
```

> [!tip] Inside csvlens, press `/<regex>` to find and highlight matches (`n`/`N` to step through them), and `&<regex>` to filter the view down to matching rows only. Use the arrow keys or `hjkl` to move around wide tables.

Docs: [csvlens docs](https://github.com/YS-L/csvlens#readme)

---

**Next:** [[Inspecting-Kubeflow-Pods]] · back to index [[Terminal-Toolkit]]
