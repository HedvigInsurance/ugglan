# Accessibility Check Workflow

## Overview

The Accessibility Check workflow automatically reviews Swift/SwiftUI code changes in pull requests to identify potential accessibility issues.

## How It Works

1. **Triggers**: Runs automatically on every pull request when `.swift` files are modified
2. **Analysis**: Compares changes from the base branch (usually `main`) to detect new accessibility issues
3. **Report**: Comments on the PR with findings and suggestions
4. **Artifacts**: Uploads a detailed accessibility report

## What It Checks

### ⚠️ High Priority Issues
- Interactive elements (`.onTapGesture`) without `.accessibilityAddTraits(.isButton)`
- Images without `.accessibilityLabel()` or `.accessibilityHidden(true)`
- Progress indicators without labels and values
- Custom gestures without `.accessibilityAction()`

### 💡 Suggestions
- Custom buttons that may need explicit accessibility labels
- Dropdowns/pickers without hints
- Complex list items that could benefit from grouping
- Toggle/Picker components without labels

## Usage

### The workflow runs automatically, but you can:

1. **Review the comment** on your PR after pushing changes
2. **Check the artifacts** for the full report
3. **Apply suggested fixes** using existing `L10n` keys

### Example Fixes

#### Fix: onTapGesture without traits
```swift
// ❌ Before
.onTapGesture {
    doSomething()
}

// ✅ After
.onTapGesture {
    doSomething()
}
.accessibilityAddTraits(.isButton)
.accessibilityLabel(L10n.myAction)
```

#### Fix: Image without accessibility
```swift
// ❌ Before
Image("icon")
    .resizable()

// ✅ After - Decorative
Image("icon")
    .resizable()
    .accessibilityHidden(true)

// ✅ After - Informative
Image("icon")
    .resizable()
    .accessibilityLabel(L10n.iconDescription)
```

#### Fix: Progress indicator
```swift
// ❌ Before
ProgressView()

// ✅ After
ProgressView()
    .accessibilityLabel(L10n.embarkLoading)
    .accessibilityValue("\(progress)%")
```

## Best Practices

### Always Use Existing L10n Keys
✅ `.accessibilityLabel(L10n.voiceoverAction)`
❌ `.accessibilityLabel("Tap here")`

### Group Complex Elements
```swift
HStack {
    Image("checkmark")
    Text("Completed")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Completed")
```

### Add Hints for Actions
```swift
.accessibilityHint(L10n.voiceoverPressTo + " " + L10n.voiceoverChangeValue)
```

### Hide Decorative Elements
```swift
.accessibilityHidden(true) // For purely visual elements
```

## Files

- **Workflow**: `.github/workflows/AccessibilityCheck.yml`
- **Script**: `scripts/check-accessibility.sh`
- **Documentation**: `docs/accessibility-workflow.md` (this file)

## Manual Usage

You can run the check locally:

```bash
# Check specific files
./scripts/check-accessibility.sh "Projects/MyModule/Sources/MyView.swift"

# Check all Swift files in a directory
find Projects/MyModule -name "*.swift" | xargs ./scripts/check-accessibility.sh
```

## Limitations

- This is a pattern-based checker, not a full accessibility audit
- Some warnings may be false positives
- Complex accessibility implementations may not be detected
- External components (hCoreUI, etc.) are not checked

## Resources

- [Apple Accessibility Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [SwiftUI Accessibility](https://developer.apple.com/documentation/swiftui/view-accessibility)
- [VoiceOver Testing](https://developer.apple.com/library/archive/technotes/TestingAccessibilityOfiOSApps/TestAccessibilityiniOSSimulatorwithAccessibilityInspector/TestAccessibilityiniOSSimulatorwithAccessibilityInspector.html)

## Contributing

Found an issue or have suggestions? The workflow checks for common patterns but may need updates as new accessibility requirements emerge.

To add new checks:
1. Edit `scripts/check-accessibility.sh`
2. Add pattern matching for the new issue
3. Test locally before committing
4. Update this documentation

---

**Note**: Always test accessibility with actual VoiceOver, not just the Accessibility Inspector. Real user testing is the best validation!
