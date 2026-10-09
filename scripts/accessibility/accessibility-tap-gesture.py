#!/usr/bin/env python3
"""Shared `.onTapGesture` accessibility scanner.

check-accessibility.sh and auto-fix-accessibility.sh both call this, so the two
can never disagree about what counts as "already handled". They used to each
carry their own literal search for the string `accessibilityAddTraits(.isButton)`,
which missed every conditional form — `.accessibilityAddTraits(onSelected != nil ? .isButton : [])`
and friends — and made the auto-fixer stack a second, unconditional `.isButton`
on top of a view that had already got it right.

Modes:
  --check <file>   one `line<TAB>kind<TAB>message` per site needing attention
  --fix   <file>   insert the trait where it is provably safe; print FIXED or NO_CHANGE
"""

import re
import sys

TRAIT_MODIFIER = "accessibilityAddTraits"
TRAIT_LINE = ".accessibilityAddTraits(.isButton)"

# A tap body that branches may not act on every tap, so an unconditional
# `.isButton` would lie to VoiceOver. Those sites get reported, never rewritten.
CONDITIONAL_BODY = re.compile(r"\b(?:if|guard|switch)\b|\?\?|\?\.|\?\(")

PREVIEW_MACRO = re.compile(r"^\s*#Preview\b")


def preview_ranges(lines):
    """Line indices (inclusive) covered by preview code, which ships to nobody."""
    ranges = []
    for i, line in enumerate(lines):
        if "PreviewProvider" in line:
            # Previews live at the bottom of a file by convention.
            ranges.append((i, len(lines) - 1))
            break
        if PREVIEW_MACRO.match(line):
            ranges.append((i, block_end(lines, i)))
    return ranges


def block_end(lines, start):
    """Last line of the brace block opened on or after `start`."""
    depth = 0
    seen_brace = False
    for i in range(start, len(lines)):
        depth += lines[i].count("{") - lines[i].count("}")
        seen_brace = seen_brace or "{" in lines[i]
        if seen_brace and depth <= 0:
            return i
    return len(lines) - 1


def in_preview(index, ranges):
    return any(start <= index <= end for start, end in ranges)


def closure_end(lines, start):
    """Last line of the `.onTapGesture` trailing closure, or `start` if there is none."""
    line = lines[start]
    tail = line[line.index(".onTapGesture"):]
    if "{" not in tail:
        return start
    depth = tail.count("{") - tail.count("}")
    i = start
    while depth > 0 and i + 1 < len(lines):
        i += 1
        depth += lines[i].count("{") - lines[i].count("}")
    return i


def chain_after(lines, start):
    """The modifier chain following `start`, multi-line arguments included."""
    collected = []
    depth = 0
    i = start + 1
    while i < len(lines):
        stripped = lines[i].strip()
        if depth == 0 and not stripped.startswith("."):
            break
        collected.append(lines[i])
        depth += lines[i].count("(") - lines[i].count(")")
        depth += lines[i].count("{") - lines[i].count("}")
        i += 1
    return collected


def chain_before(lines, start):
    """Contiguous single-line modifiers above `start`."""
    collected = []
    i = start - 1
    while i >= 0 and lines[i].strip().startswith("."):
        collected.append(lines[i])
        i -= 1
    return collected


def tap_sites(lines):
    """Every `.onTapGesture` outside preview code, classified."""
    previews = preview_ranges(lines)
    sites = []
    for i, line in enumerate(lines):
        if ".onTapGesture" not in line or in_preview(i, previews):
            continue
        end = closure_end(lines, i)
        chain = "\n".join(chain_before(lines, i) + chain_after(lines, end))
        body = "\n".join(lines[i:end + 1])
        if TRAIT_MODIFIER in chain:
            kind = "ok"
        elif CONDITIONAL_BODY.search(body):
            kind = "manual"
        else:
            kind = "auto"
        sites.append({"line": i, "end": end, "kind": kind})
    return sites


def check(lines):
    findings = []
    for site in tap_sites(lines):
        if site["kind"] == "auto":
            findings.append(
                (site["line"] + 1, "auto", "`.onTapGesture` without `.accessibilityAddTraits(.isButton)`")
            )
        elif site["kind"] == "manual":
            findings.append(
                (
                    site["line"] + 1,
                    "manual",
                    "`.onTapGesture` acts conditionally and has no `.accessibilityAddTraits` — "
                    "add the trait under the same condition as the tap",
                )
            )
    return findings


def fix(lines):
    """Insert the trait after each auto-fixable closure, bottom-up to keep indices valid."""
    sites = [site for site in tap_sites(lines) if site["kind"] == "auto"]
    if not sites:
        return lines, False
    patched = list(lines)
    for site in reversed(sites):
        source = lines[site["line"]]
        indent = " " * (len(source) - len(source.lstrip()))
        patched.insert(site["end"] + 1, indent + TRAIT_LINE)
    return patched, True


def main():
    if len(sys.argv) != 3 or sys.argv[1] not in ("--check", "--fix"):
        print("usage: accessibility-tap-gesture.py --check|--fix <file>", file=sys.stderr)
        return 2

    mode, path = sys.argv[1], sys.argv[2]
    try:
        with open(path, "r") as handle:
            content = handle.read()
    except OSError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1

    lines = content.split("\n")

    if mode == "--check":
        for line_no, kind, message in check(lines):
            print(f"{line_no}\t{kind}\t{message}")
        return 0

    patched, changed = fix(lines)
    if not changed:
        print("NO_CHANGE")
        return 0
    try:
        with open(path, "w") as handle:
            handle.write("\n".join(patched))
    except OSError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print("FIXED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
