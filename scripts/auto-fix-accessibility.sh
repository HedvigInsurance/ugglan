#!/bin/bash

# Auto-fix Accessibility Issues
# Automatically applies common accessibility fixes to SwiftUI code

set -e

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

    # Skip PreviewProvider blocks
    if grep -q "PreviewProvider" "$file"; then
        return 0
    fi

    echo "  Checking: $file"

    # Create backup
    cp "$file" "$file.bak"

    # Fix 1: Add .accessibilityAddTraits(.isButton) to .onTapGesture
    # Pattern: Find .onTapGesture followed by closing braces, add trait before the gesture
    if grep -q "\.onTapGesture" "$file"; then
        # Use perl for multi-line matching and replacement
        perl -i -0pe 's/(\n\s+)(\.onTapGesture\s*\{[^}]*\})(?!\s*\.accessibilityAddTraits)/$1$2\n$1.accessibilityAddTraits(.isButton)/g' "$file"

        if ! cmp -s "$file" "$file.bak"; then
            ((file_fixes++))
            echo -e "    ${GREEN}✓${NC} Added .accessibilityAddTraits(.isButton) to .onTapGesture"
        fi
    fi

    # Fix 2: Add .accessibilityHidden(true) to decorative images in common patterns
    # This is conservative - only fixes obvious decorative icons
    if grep -qE "hCoreUIAssets\.(minus|chevron|info|arrow|close)" "$file"; then
        # Match common decorative icon patterns and add accessibilityHidden if not already present
        perl -i -0pe 's/(Image\(\s*uiImage:\s*hCoreUIAssets\.(minus|chevron|info|arrow|close)[^)]*\)(?:\s*\.[^\n]*)*?)(?=\s*\n)(?!.*accessibilityHidden)/$1\n                .accessibilityHidden(true)/g' "$file"

        if ! cmp -s "$file" "$file.bak"; then
            ((file_fixes++))
            echo -e "    ${GREEN}✓${NC} Added .accessibilityHidden(true) to decorative icons"
        fi
    fi

    # Fix 3: Add TODO comments for images that need labels
    # Find Images without accessibility modifiers and add TODO comment
    if grep -nE "^\s*(KF)?Image\(" "$file" | grep -v "accessibilityLabel\|accessibilityHidden" > /dev/null 2>&1; then
        # Add TODO comment above images that need attention
        perl -i -pe 's/^(\s+)(KF?Image\()(?!.*\/\/.*TODO.*accessibility)/$1\/\/ TODO: Add .accessibilityLabel() or .accessibilityHidden(true)\n$1$2/g' "$file"

        if ! cmp -s "$file" "$file.bak"; then
            ((file_fixes++))
            echo -e "    ${YELLOW}⚠${NC}  Added TODO comments for images needing accessibility"
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
    echo "   ./scripts/check-accessibility.sh"
else
    echo -e "${GREEN}✓ No automatic fixes needed${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
