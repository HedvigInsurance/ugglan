#!/usr/bin/env python3
"""Fail if a Claude instruction file references a file that doesn't exist.

Checks every tracked CLAUDE*.md plus .claude/agents, .claude/rules and .claude/skills. A reference is a backticked token outside code
blocks that is either a file name (Foo.swift, bar.sh, …) or a repo path (scripts/…, Projects/…). It resolves if it
exists relative to the repo root or to the doc's own directory (or its Sources/), or if a tracked file ends with it —
so `Foo.swift` and `Sources/Bar/Foo.swift` both resolve. Bare extensions (`.graphql`) and tokens with placeholders
(<Module>, *, …) are skipped.

Stale file references were the main way these docs went out of date, so CI runs this next to the generated-files
check. Run it locally with: scripts/check-claude-docs.py
"""

import os
import re
import subprocess
import sys

EXTENSIONS = r"swift|md|sh|py|yml|yaml|json|graphql|xcconfig|plist"
TOKEN = re.compile(r"`([A-Za-z0-9_.@/+-]+)`")
FILE_LIKE = re.compile(rf"\.({EXTENSIONS})$")
PATH_PREFIXES = ("scripts/", "Projects/", "Dependencies/", "Tuist/", ".github/", ".claude/")


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True, check=True).stdout.splitlines()


def main():
    os.chdir(git("rev-parse", "--show-toplevel")[0])
    tracked = git("ls-files")
    tracked_set = set(tracked)
    tracked_dirs = {os.path.dirname(p) for p in tracked}
    for p in list(tracked_dirs):
        while p:
            p = os.path.dirname(p)
            tracked_dirs.add(p)
    basenames = {os.path.basename(p) for p in tracked}
    docs = [
        p for p in tracked
        if re.search(r"(^|/)CLAUDE[^/]*\.md$", p) or re.match(r"\.claude/(agents|rules|skills)/.*\.md$", p)
    ]

    def exists(path):
        path = path.rstrip("/")
        return path in tracked_set or path in tracked_dirs

    problems = []
    for doc in docs:
        base = os.path.dirname(doc)
        in_code = False
        with open(doc, encoding="utf-8") as f:
            for number, line in enumerate(f, 1):
                if line.lstrip().startswith("```"):
                    in_code = not in_code
                    continue
                if in_code:
                    continue
                for token in TOKEN.findall(line):
                    is_path = token.startswith(PATH_PREFIXES)
                    if re.fullmatch(r"\.[A-Za-z]+", token) or not (FILE_LIKE.search(token) or is_path):
                        continue
                    candidates = [token, os.path.join(base, token), os.path.join(base, "Sources", token)]
                    if any(exists(c) for c in candidates):
                        continue
                    if "/" not in token and token in basenames:
                        continue
                    if "/" in token and any(p.endswith("/" + token) for p in tracked):
                        continue
                    problems.append(f"{doc}:{number}: `{token}` does not exist")

    if problems:
        print("Claude instruction files reference missing files:", *problems, sep="\n  ")
        print("Update the docs (or the reference) so they match the code.")
        return 1
    print(f"Checked {len(docs)} Claude instruction files: all file references resolve.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
