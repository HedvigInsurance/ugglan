#!/bin/bash
# PostToolUse hook (Write|Edit): runs the CI accessibility checker on an edited Swift source file and feeds any
# findings back to Claude. Exit 2 + stderr shows the report to Claude; the edit itself is never blocked.

file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
repo="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"

# Only feature/design-system sources — the checker skips tests itself, and generated code isn't ours to fix.
case "$file" in
    "$repo"/Projects/*/Sources/*.swift) ;;
    *) exit 0 ;;
esac
case "$file" in
    */Derived/*) exit 0 ;;
esac
[ -f "$file" ] || exit 0

# The checker writes accessibility-report.md into the working directory, so run it from a scratch dir.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
if output=$(cd "$tmp" && "$repo/scripts/accessibility/check-accessibility.sh" "$file" 2>&1); then
    exit 0
fi

{
    echo "Accessibility check (same rules as the AccessibilityCheck CI job) flagged ${file#"$repo"/}:"
    grep -E '^(⚠️|💡|🖼️)|Line [0-9]+' <<<"$output" | sed 's/\x1b\[[0-9;]*m//g'
    echo "Fix these, or explain why they don't apply. See .claude/rules/accessibility.md."
} >&2
exit 2
