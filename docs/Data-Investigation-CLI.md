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

**Next:** [[Inspecting-Kubeflow-Pods]] · back to index [[Terminal-Toolkit]]
