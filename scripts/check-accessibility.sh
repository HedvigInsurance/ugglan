#!/bin/bash

# Accessibility Checker for SwiftUI Files
# Checks for common accessibility issues in Swift/SwiftUI code

set -e

CHANGED_FILES=$1
REPORT_FILE="accessibility-report.md"
ISSUES_FOUND=0

# Initialize report
cat > "$REPORT_FILE" << EOF
## 🔍 Accessibility Check Report

This automated check reviews SwiftUI code for common accessibility issues.

EOF

# Colors for terminal output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🔍 Checking accessibility in changed Swift files..."

check_file() {
    local file=$1
    local file_issues=0

    # Skip if file doesn't exist or isn't a Swift file
    if [[ ! -f "$file" ]] || [[ ! "$file" =~ \.swift$ ]]; then
        return 0
    fi

    # Skip test files
    if [[ "$file" =~ Test\.swift$ ]] || [[ "$file" =~ Tests/ ]]; then
        return 0
    fi

    echo "  Checking: $file"

    local issues=()

    # Strip PreviewProvider blocks to avoid false positives
    local scan_file="$file"
    local tmp_scan_file=""

    if grep -q "PreviewProvider" "$file"; then
        tmp_scan_file="$(mktemp)"
        awk 'BEGIN{skip=0} /PreviewProvider/{skip=1} !skip{print}' "$file" > "$tmp_scan_file"
        scan_file="$tmp_scan_file"
    fi

    # Check 1: onTapGesture without accessibility traits
    if grep -n "\.onTapGesture" "$scan_file" | grep -v "accessibilityAddTraits" > /dev/null 2>&1; then
        local lines=$(grep -n "\.onTapGesture" "$scan_file" | cut -d: -f1)
        for line_num in $lines; do
            local end_line=$((line_num + 5))
            if ! sed -n "${line_num},${end_line}p" "$scan_file" | grep -q "accessibilityAddTraits"; then
                issues+=("⚠️  Line $line_num: \`.onTapGesture\` without \`.accessibilityAddTraits(.isButton)\`")
                ((file_issues++))
            fi
        done
    fi

    # Check 2: Icon-only Buttons
    if grep -n "Button.*{" "$scan_file" > /dev/null 2>&1; then
        local lines=$(grep -n "Button.*{" "$scan_file" | cut -d: -f1)
        for line_num in $lines; do
            local end_line=$((line_num + 20))
            local block=$(sed -n "${line_num},${end_line}p" "$scan_file")

            local button_line=$(sed -n "${line_num}p" "$scan_file")
            if [[ "$button_line" =~ Button\([[:space:]]*\".*\"[[:space:]]*\) ]]; then
                continue
            fi

            if echo "$block" | grep -q "accessibilityLabel"; then
                continue
            fi

            if echo "$block" | grep -q "Image(" && ! echo "$block" | grep -q "Text("; then
                issues+=("💡 Line $line_num: Icon-only \`Button\` should add \`.accessibilityLabel()\`")
                ((file_issues++))
            fi
        done
    fi

    # Check 3: Image without accessibility handling
    if grep -n "Image(" "$scan_file" | grep -v "accessibilityLabel\|accessibilityHidden" > /dev/null 2>&1; then
        local lines=$(grep -n "Image(" "$scan_file" | cut -d: -f1)
        for line_num in $lines; do
            local end_line=$((line_num + 5))
            if ! sed -n "${line_num},${end_line}p" "$scan_file" | grep -q "accessibilityLabel\|accessibilityHidden"; then
                issues+=("🖼️  Line $line_num: \`Image\` without \`.accessibilityLabel()\` or \`.accessibilityHidden(true)\`")
                ((file_issues++))
            fi
        done
    fi

    # Check 4: Dropdowns without accessibility hint
    if grep -q "hFloatingField\|DropdownView" "$scan_file"; then
        if ! grep -q "accessibilityHint" "$scan_file"; then
            issues+=("💡 File may contain dropdowns without accessibility hints")
        fi
    fi

    # Check 5: Custom gestures without accessibilityAction
    if grep -n "LongPressGesture\|DragGesture\|\.gesture(" "$scan_file" | grep -v "accessibilityAction" > /dev/null 2>&1; then
        local lines=$(grep -n "LongPressGesture\|DragGesture\|\.gesture(" "$scan_file" | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
        if [[ -n "$lines" ]]; then
            issues+=("⚠️  Lines $lines: Custom gestures should include \`.accessibilityAction()\`")
            ((file_issues++))
        fi
    fi

    # Check 6 REMOVED (ForEach + combine heuristic was too noisy)

    # Check 7: Progress indicators without labels
    if grep -n "ProgressView\|\.progress\|CircularProgress" "$scan_file" | grep -v "accessibilityLabel\|accessibilityValue" > /dev/null 2>&1; then
        local lines=$(grep -n "ProgressView\|\.progress\|CircularProgress" "$scan_file" | cut -d: -f1 | head -3 | tr '\n' ',' | sed 's/,$//')
        if [[ -n "$lines" ]]; then
            issues+=("⚠️  Lines $lines: Progress indicators need \`.accessibilityLabel()\` and \`.accessibilityValue()\`")
            ((file_issues++))
        fi
    fi

    # Check 8: Toggle/Picker without accessibility labels
    if grep -n "Toggle(\|Picker(" "$scan_file" | grep -v "accessibilityLabel" > /dev/null 2>&1; then
        local lines=$(grep -n "Toggle(\|Picker(" "$scan_file" | cut -d: -f1)
        for line_num in $lines; do
            local end_line=$((line_num + 5))
            if ! sed -n "${line_num},${end_line}p" "$scan_file" | grep -q "accessibilityLabel"; then
                issues+=("💡 Line $line_num: \`Toggle\`/\`Picker\` may need explicit \`.accessibilityLabel()\`")
            fi
        done
    fi

    # Cleanup
    if [[ -n "$tmp_scan_file" ]] && [[ -f "$tmp_scan_file" ]]; then
        rm -f "$tmp_scan_file"
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        echo >> "$REPORT_FILE"
        echo "### 📄 \`$file\`" >> "$REPORT_FILE"
        echo >> "$REPORT_FILE"
        for issue in "${issues[@]}"; do
            echo "- $issue" >> "$REPORT_FILE"
        done
        ((ISSUES_FOUND += file_issues))
    fi

    return $file_issues
}

if [[ -z "$CHANGED_FILES" ]]; then
    echo "No files to check"
    exit 0
fi

for file in $CHANGED_FILES; do
