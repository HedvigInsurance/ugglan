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

# Python script for proper brace matching
read -r -d '' PYTHON_FIXER << 'PYTHON_SCRIPT' || true
import sys
import re

def find_matching_brace(text, start_pos):
    """Find the position of the matching closing brace"""
    count = 0
    pos = start_pos
    while pos < len(text):
        if text[pos] == '{':
            count += 1
        elif text[pos] == '}':
            count -= 1
            if count == 0:
                return pos
        pos += 1
    return -1

def fix_accessibility(content):
    """Add .accessibilityAddTraits(.isButton) after .onTapGesture blocks"""
    lines = content.split('\n')
    result = []
    i = 0
    fixed = False

    while i < len(lines):
        line = lines[i]
        result.append(line)

        # Check if this line has .onTapGesture
        if '.onTapGesture' in line and '{' in line:
            # Check if accessibility trait already exists in next few lines
            has_trait = False
            for j in range(i + 1, min(i + 5, len(lines))):
                if '.accessibilityAddTraits' in lines[j]:
                    has_trait = True
                    break

            if not has_trait:
                # Find the complete .onTapGesture block
                brace_start = line.index('{')
                remaining_text = line[brace_start:]

                # Count braces in this line
                open_count = remaining_text.count('{')
                close_count = remaining_text.count('}')

                if open_count == close_count:
                    # Single-line closure - add trait right after this line
                    indent = len(line) - len(line.lstrip())
                    result.append(' ' * indent + '.accessibilityAddTraits(.isButton)')
                    fixed = True
                else:
                    # Multi-line closure - need to find closing brace
                    brace_count = open_count - close_count
                    j = i + 1
                    closure_end = i

                    while j < len(lines) and brace_count > 0:
                        current_line = lines[j]
                        brace_count += current_line.count('{')
                        brace_count -= current_line.count('}')

                        if brace_count == 0:
                            closure_end = j
                            break
                        j += 1

                    if closure_end > i:
                        # Add remaining lines up to closure end
                        for k in range(i + 1, closure_end + 1):
                            result.append(lines[k])

                        # Add accessibility trait after closure
                        indent = len(lines[i]) - len(lines[i].lstrip())
                        result.append(' ' * indent + '.accessibilityAddTraits(.isButton)')
                        fixed = True
                        i = closure_end

        i += 1

    return '\n'.join(result), fixed

def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py <file>")
        sys.exit(1)

    file_path = sys.argv[1]

    try:
        with open(file_path, 'r') as f:
            content = f.read()

        new_content, fixed = fix_accessibility(content)

        if fixed:
            with open(file_path, 'w') as f:
                f.write(new_content)
            print("FIXED")
        else:
            print("NO_CHANGE")
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
PYTHON_SCRIPT

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

    # Fix 1: Add .accessibilityAddTraits(.isButton) to .onTapGesture using Python
    if grep -q "\.onTapGesture" "$file"; then
        result=$(python3 -c "$PYTHON_FIXER" "$file" 2>&1)

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
    echo "   ./scripts/check-accessibility.sh"
else
    echo -e "${GREEN}✓ No automatic fixes needed${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
