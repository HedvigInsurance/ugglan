#!/bin/bash

# Accessibility Checker for SwiftUI Files
# Checks for common accessibility issues in Swift/SwiftUI code

set -e

CHANGED_FILES=${1:-}
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

# Function to check a single file
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
        # Drop everything from the first line containing PreviewProvider to EOF
        awk 'BEGIN{skip=0} /PreviewProvider/{skip=1} !skip{print}' "$file" > "$tmp_scan_file"
        scan_file="$tmp_scan_file"
    fi

    # Check 1: onTapGesture without accessibility traits
    # Also recognizes custom modifiers ending with "Accessibility"
    # Skip if the view has .accessibilityAction or .accessibilityHidden nearby (parent container accessibility)
    if grep -n "\.onTapGesture" "$scan_file" | grep -v "accessibilityAddTraits\|Accessibility(\|accessibilityAction" > /dev/null 2>&1; then
        local lines
        lines=$(grep -n "\.onTapGesture" "$scan_file" | cut -d: -f1)
        for line_num in $lines; do
            local start_line=$((line_num > 10 ? line_num - 10 : 1))
            local end_line=$((line_num + 100))
            if ! sed -n "${start_line},${end_line}p" "$scan_file" | grep -q "accessibilityAddTraits\|Accessibility(\|accessibilityAction\|accessibilityHidden"; then
                issues+=("⚠️  Line $line_num: \`.onTapGesture\` without \`.accessibilityAddTraits(.isButton)\`")
                ((file_issues++))
            fi
        done
    fi

    # Check 2: Icon-only Buttons (Image without Text/label)
    if grep -n "Button.*{" "$scan_file" > /dev/null 2>&1; then
        local lines
        lines=$(grep -n "Button.*{" "$scan_file" | cut -d: -f1)
        for line_num in $lines; do
            local end_line=$((line_num + 20))
            local block
            block=$(sed -n "${line_num},${end_line}p" "$scan_file")

            # Skip plain Button("Title") { ... }
            local button_line
            button_line=$(sed -n "${line_num}p" "$scan_file")
            if [[ "$button_line" =~ Button\([[:space:]]*\".*\"[[:space:]]*\) ]]; then
                continue
            fi

            # If there's already an accessibilityLabel nearby, OK
            if echo "$block" | grep -q "accessibilityLabel"; then
                continue
            fi

            # Warn only if Image is used but no Text is present
            if echo "$block" | grep -q "Image(" && ! echo "$block" | grep -q "Text("; then
                issues+=("💡 Line $line_num: Icon-only \`Button\` should add \`.accessibilityLabel()\`")
                ((file_issues++))
            fi
        done
    fi

    # Check 3: Image without accessibility handling
    # Exclude UIImage (UIKit), method calls containing "Image", and SwiftUI.Image
    # Only check actual SwiftUI Image(...) and KFImage(...) view initializers
    if grep -nE "^[[:space:]]*(KF)?Image\(" "$scan_file" | grep -v "accessibilityLabel\|accessibilityHidden\|UIImage(" > /dev/null 2>&1; then
        local lines
        lines=$(grep -nE "^[[:space:]]*(KF)?Image\(" "$scan_file" | grep -v "UIImage(" | cut -d: -f1)
        for line_num in $lines; do
            local end_line=$((line_num + 15))
            if ! sed -n "${line_num},${end_line}p" "$scan_file" | grep -q "accessibilityLabel\|accessibilityHidden"; then
                issues+=("🖼️  Line $line_num: \`Image\` without \`.accessibilityLabel()\` or \`.accessibilityHidden(true)\`")
                ((file_issues++))
            fi
        done
    fi

    # Check 4: Custom gestures (LongPressGesture, DragGesture) without accessibility
    # Skip if the view has accessibility actions nearby (parent container accessibility)
    if grep -n "LongPressGesture\|DragGesture\|\.gesture(" "$scan_file" > /dev/null 2>&1; then
        local lines
        lines=$(grep -n "LongPressGesture\|DragGesture\|\.gesture(" "$scan_file" | cut -d: -f1)
        for line_num in $lines; do
            local start_line=$((line_num > 25 ? line_num - 25 : 1))
            local end_line=$((line_num + 60))
            if ! sed -n "${start_line},${end_line}p" "$scan_file" | grep -q "accessibilityAction\|accessibilityAdjustableAction"; then
                issues+=("⚠️  Line $line_num: Custom gestures should include \`.accessibilityAction()\` or \`.accessibilityAdjustableAction()\`")
                ((file_issues++))
            fi
        done
    fi

    # Check 5: Toggle/Picker without accessibility labels
    # Match SwiftUI Picker/Toggle only (exclude DatePicker which has built-in accessibility)
    if grep -nE "^[[:space:]]+(Picker|Toggle)\(" "$scan_file" | grep -v "DatePicker" > /dev/null 2>&1; then
        local lines
        lines=$(grep -nE "^[[:space:]]+(Picker|Toggle)\(" "$scan_file" | grep -v "DatePicker" | cut -d: -f1)
        for line_num in $lines; do
            local end_line=$((line_num + 5))
            if ! sed -n "${line_num},${end_line}p" "$scan_file" | grep -q "accessibilityLabel"; then
                issues+=("💡 Line $line_num: \`Toggle\`/\`Picker\` may need explicit \`.accessibilityLabel()\`")
            fi
        done
    fi

    # Cleanup temp scan file if created
    if [[ -n "$tmp_scan_file" ]] && [[ -f "$tmp_scan_file" ]]; then
        rm -f "$tmp_scan_file"
    fi

    # Report issues for this file
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

# Check all changed files
if [[ -z "${CHANGED_FILES// }" ]]; then
    cat >> "$REPORT_FILE" << EOF

---

### ✅ Nothing to Check

No Swift files were detected in this PR (based on the changed-files output), so the accessibility scan did not run.

---
*Generated by Accessibility Check Workflow*
EOF
    echo -e "${GREEN}✅ No Swift files to check.${NC}"
    cat "$REPORT_FILE"
    exit 0
fi

for file in $CHANGED_FILES; do
    check_file "$file" || true
done

# Add summary to report
if [[ $ISSUES_FOUND -gt 0 ]]; then
    cat >> "$REPORT_FILE" << EOF

---

### 📋 Summary

Found **$ISSUES_FOUND potential accessibility issues** in the changed files.

#### ✅ Best Practices Checklist:

- [ ] Interactive elements have \`.accessibilityLabel()\`
- [ ] Tappable views have \`.accessibilityAddTraits(.isButton)\`
- [ ] Images have \`.accessibilityLabel()\` or \`.accessibilityHidden(true)\`
- [ ] Custom gestures use \`.accessibilityAction()\` or \`.accessibilityAdjustableAction()\`

---
*Generated by Accessibility Check Workflow*
EOF
    echo -e "${YELLOW}⚠️  Found $ISSUES_FOUND potential accessibility issues${NC}"
    cat "$REPORT_FILE"
    exit 1
else
    cat >> "$REPORT_FILE" << EOF

---

### ✅ No Issues Found

All checked files appear to follow accessibility best practices!

---
*Generated by Accessibility Check Workflow*
EOF
    echo -e "${GREEN}✅ No accessibility issues found!${NC}"
    cat "$REPORT_FILE"
    exit 0
fi
