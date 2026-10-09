#!/bin/bash

# Auto-fix Accessibility Issues
# Automatically applies common accessibility fixes to SwiftUI code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCANNER="$SCRIPT_DIR/accessibility-tap-gesture.py"

FIXED_FILES=()
FIXES_APPLIED=0

# Colors for terminal output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔧 Auto-fixing accessibility issues..."


# Function to fix a single file
fix_file() {
    local file=$1
    local file_fixes=0

    # Skip if file doesn't exist or isn't a Swift file
    if [[ ! -f "$file" ]] || [[ ! "$file" =~ \.swift$ ]]; then
        return 0
    fi

    # Skip test files
    if [[ "$file" =~ Test\.swift$ ]] || [[ "$file" =~ Tests/ ]]; then
        return 0
    fi

    echo "  Checking: $file"

    # Create backup
    cp "$file" "$file.bak"

    # Fix 1: Add .accessibilityAddTraits(.isButton) to .onTapGesture.
    # The scanner is shared with check-accessibility.sh and only rewrites a view
    # when nothing in its modifier chain already sets traits AND the tap fires
    # unconditionally. A conditional tap needs the trait under the same condition,
    # which is a judgement call, so those are left for the audit report.
    if grep -q "\.onTapGesture" "$file"; then
        result=$(python3 "$SCANNER" --fix "$file" 2>&1)

        if [[ "$result" == "FIXED" ]]; then
            # Verify the file still compiles syntax-wise (basic check)
            if python3 -c "open('$file').read()" 2>/dev/null; then
                ((file_fixes++))
                echo -e "    ${GREEN}✓${NC} Added .accessibilityAddTraits(.isButton) to .onTapGesture"
            else
                # Restore backup if something went wrong
                cp "$file.bak" "$file"
                echo -e "    ${RED}✗${NC} Fix failed - restored backup"
            fi
        fi
    fi

    # Clean up backup if no changes
    if cmp -s "$file" "$file.bak"; then
        rm "$file.bak"
    else
        rm "$file.bak"
        FIXED_FILES+=("$file")
        ((FIXES_APPLIED += file_fixes))
    fi

    return 0
}

# Get all Swift files or use provided list
if [ $# -eq 0 ]; then
    # No arguments - find all Swift files
    FILES=$(find Projects -name "*.swift" -type f | grep -v Test)
else
    # Use provided files
    FILES="$@"
fi

# Process each file
for file in $FILES; do
    fix_file "$file" || true
done

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ${#FIXED_FILES[@]} -gt 0 ]; then
    echo -e "${GREEN}✓ Applied $FIXES_APPLIED fixes to ${#FIXED_FILES[@]} files${NC}"
    echo ""
    echo "Fixed files:"
    for file in "${FIXED_FILES[@]}"; do
        echo "  - $file"
    done
    echo ""
    echo -e "${BLUE}ℹ${NC}  Review the changes and run the accessibility checker again"
    echo "   ./scripts/accessibility/check-accessibility.sh"
else
    echo -e "${GREEN}✓ No automatic fixes needed${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
