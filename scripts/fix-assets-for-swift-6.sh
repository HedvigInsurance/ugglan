#!/usr/bin/env bash
file="Projects/hCoreUI/Sources/Derived/Assets.swift"         # File where you want to insert the new line
search_text="public enum hCoreUIAssets"             # Line number at which to insert the new line
replace_text="@MainActor \npublic enum hCoreUIAssets"  # Text to insert
sleep 1
if grep -q "@MainActor" "$file"; then
    echo "Already @MainActor"
else
    if [ ! -f "$file" ]; then
        echo "File not found!"
        exit 1
    fi
sed -i '' "s/${search_text}/${replace_text}/g" "$file"
fi
