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

    # Check 1: onTapGesture without accessibility traits
    if grep -n "\.onTapGesture" "$file" | grep -v "accessibilityAddTraits" > /dev/null 2>&1; then
        local lines=$(grep -n "\.onTapGesture" "$file" | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
        if [[ -n "$lines" ]]; then
            # Check if accessibility traits are added within next 5 lines
            for line_num in ${lines//,/ }; do
                local end_line=$((line_num + 5))
                if ! sed -n "${line_num},${end_line}p" "$file" | grep -q "accessibilityAddTraits"; then
                    issues+=("⚠️  Line $line_num: \`.onTapGesture\` without \`.accessibilityAddTraits(.isButton)\`")
                    ((file_issues++))
                fi
            done
        fi
    fi

    # Check 2: Warn only for "icon-only" Buttons (Image without Text/label)
    if grep -n "Button.*{" "$file" > /dev/null 2>&1; then
        local lines=$(grep -n "Button.*{" "$file" | cut -d: -f1)
        for line_num in $lines; do
            local end_line=$((line_num + 20))
            local block=$(sed -n "${line_num},${end_line}p" "$file")

            # Skip plain Button("Title") { ... }
            local button_line=$(sed -n "${line_num}p" "$file")
            if [[ "$button_line" =~ Button\([[:space:]]*\".*\"[[:space:]]*\) ]]; then
                continue
            fi

            # If there's already an accessibilityLabel nearby, OK
            if echo "$block" | grep -q "accessibilityLabel"; then
                continue
            fi

            # Warn only if Image is used but no Text is present (likely icon-only button)
            if echo "$block" | grep -q "Image(" && ! echo "$block" | grep -q "Text("; then
                issues+=("💡 Line $line_num: Icon-only \`Button\` should add \`.accessibilityLabel()\` (or include a \`Text\` label)")
                ((file_issues++))
            fi
        done
    fi

    # Check 3: Image without accessibility handling
    if grep -n "Image(" "$file" | grep -v "accessibilityLabel\|accessibilityHidden" > /dev/null 2>&1; then
        local lines=$(grep -n "Image(" "$file" | cut -d: -f1)
        for line_num in $lines; do
            local end_line=$((line_num + 5))
            if ! sed -n "${line_num},${end_line}p" "$file" | grep -q "accessibilityLabel\|accessibilityHidden"; then
                issues+=("🖼️  Line $line_num: \`Image\` without \`.accessibilityLabel()\` or \`.accessibilityHidden(true)\`")
                ((file_issues++))
            fi
        done
    fi

    # Check 4: hFloatingTextField without accessibility hint (for dropdowns/special fields)
    if grep -q "hFloatingField\|DropdownView" "$file"; then
        if ! grep -q "accessibilityHint" "$file"; then
            issues+=("💡 File may contain dropdowns without accessibility hints")
        fi
    fi

    # Check 5: Custom gestures (LongPressGesture, DragGesture) without accessibility
    if grep -n "LongPressGesture\|DragGesture\|\.gesture(" "$file" | grep -v "accessibilityAction" > /dev/null 2>&1; then
        local lines=$(grep -n "LongPressGesture\|DragGesture\|\.gesture(" "$file" | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
        if [[ -n "$lines" ]]; then
            issues+=("⚠️  Lines $lines: Custom gestures should include \`.accessibilityAction()\`")
            ((file_issues++))
        fi
    fi

    # Check 6: ForEach rows that look like complex, interactive items should consider accessibility grouping
    # Heuristics:
    # - Skip preview files (PreviewProvider)
    # - Look locally around each ForEach block (next ~40 lines)
    # - Only warn if the row contains layout stacks AND an interactive element
    if grep -q "ForEach.*{" "$file"; then
        # Skip previews
        if ! grep -q "PreviewProvider" "$file"; then
            local lines=$(grep -n "ForEach.*{" "$file" | cut -d: -f1)
            for line_num in $lines; do
                local end_line=$((line_num + 40))
                local block=$(sed -n "${line_num},${end_line}p" "$file")

                # Must look like a row layout
                if echo "$block" | grep -q "HStack\|VStack"; then
                    # Must be interactive to matter
                    if echo "$block" | grep -q "Button\|\.onTapGesture\|NavigationLink"; then
                        # If no combine nearby, suggest it
                        if ! echo "$block" | grep -q "accessibilityElement([^)]*children:[[:space:]]*\.combine"; then
                            issues+=("💡 Line $line_num: Complex ForEach row may benefit from \`.accessibilityElement(children: .combine)\`")
                        fi
                    fi
                fi
            done
        fi
    fi

    # Check 7: Progress indicators without labels
    if grep -n "ProgressView\|\.progress\|CircularProgress" "$file" | grep -v "accessibilityLabel\|accessibilityValue" > /dev/null 2>&1; then
        local lines=$(grep -n "ProgressView\|\.progress\|CircularProgress" "$file" | cut -d: -f1 | head -3 | tr '\n' ',' | sed 's/,$//')
        if [[ -n "$lines" ]]; then
            issues+=("⚠️  Lines $lines: Progress indicators need \`.accessibilityLabel()\` and \`.accessibilityValue()\`")
            ((file_issues++))
        fi
    fi

    # Check 8: Toggle/Picker without accessibility labels
    if grep -n "Toggle(\|Picker(" "$file" | grep -v "accessibilityLabel" > /dev/null 2>&1; then
        local lines=$(grep -n "Toggle(\|Picker(" "$file" | cut -d: -f1)
        for line_num in $lines; do
            local end_line=$((line_num + 5))
            if ! sed -n "${line_num},${end_line}p" "$file" | grep -q "accessibilityLabel"; then
                issues+=("💡 Line $line_num: \`Toggle\`/\`Picker\` may need explicit \`.accessibilityLabel()\`")
            fi
        done
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
if [[ -z "$CHANGED_FILES" ]]; then
    echo "No files to check"
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
- [ ] Custom gestures use \`.accessibilityAction()\`
- [ ] Progress indicators have labels and values
- [ ] Complex views use \`.accessibilityElement(children: .combine)\`
- [ ] Dropdowns and pickers have \`.accessibilityHint()\`

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
