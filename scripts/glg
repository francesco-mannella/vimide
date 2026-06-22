#!/usr/bin/env python3
"""Print a columnar git branch tree with colors and unicode graphics.

Usage: bin/gitlog.sh [col_width [desc_width]]   (defaults: 14  60)
"""
import subprocess, sys, textwrap

col_w  = int(sys.argv[1]) if len(sys.argv) > 1 else 14
desc_w = int(sys.argv[2]) if len(sys.argv) > 2 else 60

R   = "\033[0m"
B   = "\033[1m"
DIM = "\033[2m"
PALETTE = ["\033[36m", "\033[33m", "\033[32m", "\033[35m", "\033[34m", "\033[31m"]

# ── branches (oldest first = leftmost) ────────────────────────────────────────
raw_refs = subprocess.check_output(
    ["git", "for-each-ref",
     "--format=%(refname:short)\t%(committerdate:unix)", "refs/heads/"],
    text=True,
).strip().splitlines()
branches = [
    ln.split("\t")[0]
    for ln in sorted(raw_refs, key=lambda l: int(l.split("\t")[1]))
]
col = {b: PALETTE[i % len(PALETTE)] for i, b in enumerate(branches)}

def git_log(ref, fmt):
    out = subprocess.check_output(
        ["git", "log", "--format=" + fmt, ref], text=True
    ).splitlines()
    out.reverse()
    return out

branch_commits = {b: git_log(b, "%h") for b in branches}

all_commits = subprocess.check_output(
    ["git", "log", "--format=%h", "--all", "--topo-order"], text=True
).split()
all_commits.reverse()

subjects = {}
for line in subprocess.check_output(
    ["git", "log", "--format=%h\t%s", "--all"], text=True
).splitlines():
    h, _, s = line.partition("\t")
    subjects[h.strip()] = s.strip()

# ── ownership: oldest branch containing each commit ───────────────────────────
commit_branch = {}
for b in branches:
    for h in branch_commits[b]:
        commit_branch.setdefault(h, b)

parents = {}
for line in subprocess.check_output(
    ["git", "log", "--format=%h\t%p", "--all"], text=True
).splitlines():
    h, _, p = line.partition("\t")
    parents[h.strip()] = p.strip().split() if p.strip() else []

# ── annotations: (is_merge, origin_branch) ────────────────────────────────────
annotations = {}
for b in branches:
    for h in branch_commits[b]:
        if commit_branch.get(h) != b:
            continue
        for par in parents.get(h, []):
            orig = commit_branch.get(par)
            if orig and orig != b:
                annotations[h] = (False, orig)
        break

for h, ps in parents.items():
    if len(ps) >= 2:
        orig = commit_branch.get(ps[1])
        if orig and orig != commit_branch.get(h):
            annotations[h] = (True, orig)

# ── column widths: fit branch name + 2 padding minimum ────────────────────────
widths = [max(col_w, len(b) + 2) for b in branches]
total_w = sum(widths)

# ── header ────────────────────────────────────────────────────────────────────
hdr = "".join(f"{B}{col[b]}{b:<{w}}{R}" for b, w in zip(branches, widths))
hdr += f"{B}{'description':<{desc_w}}{R}"
print(hdr)
sep = "┬".join("─" * w for w in widths) + "┬" + "─" * desc_w
print(sep)

# ── commit rows ───────────────────────────────────────────────────────────────
blank = " " * total_w

for h in all_commits:
    owner = commit_branch.get(h)
    if owner is None:
        continue
    bc = col[owner]

    # branch columns: colored "● hash" in owner slot, spaces elsewhere
    row = "".join(
        f"{bc}{'● ' + h:<{w}}{R}" if b == owner else " " * w
        for b, w in zip(branches, widths)
    )
    # annotation: "╭─ ← origin" in the same column, above the first commit
    ann = annotations.get(h)
    if ann:
        is_merge, orig = ann
        prefix = ""
        for b, w in zip(branches, widths):
            if b == owner:
                break
            prefix += " " * w
        arrow = "╭─ merge ← " if is_merge else "╭─ ← "
        origin_col = col.get(orig, "")
        print(f"{prefix}{DIM}{bc}{arrow}{R}{B}{origin_col}{orig}{R}")

    lines = textwrap.wrap(subjects.get(h, ""), desc_w) or [""]
    print(row + lines[0])
    for cont in lines[1:]:
        print(blank + cont)
