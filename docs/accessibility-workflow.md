# Accessibility Check Workflow

## Overview

We have two automated workflows to ensure accessibility compliance:

1. **PR Accessibility Check** - Reviews code changes in pull requests
2. **Weekly Accessibility Audit** - Scans the entire codebase every week

## PR Accessibility Check

### How It Works

1. **Triggers**: Runs automatically on every pull request when `.swift` files are modified
2. **Analysis**: Compares changes from the base branch (usually `main`) to detect new accessibility issues
3. **Report**: Comments on the PR with findings and suggestions
4. **Artifacts**: Uploads a detailed accessibility report

## Weekly Accessibility Audit

### How It Works

1. **Schedule**: Runs every Monday at 9:00 AM UTC
2. **Scope**: Scans all Swift files in the codebase (except tests)
3. **Auto-Fix**: Automatically applies common accessibility fixes
4. **PR Creation**: Creates a pull request with the auto-fixes for review
5. **Issue Creation**: Creates a GitHub issue for remaining manual fixes (if needed)
6. **Auto-Close**: Closes issues automatically when all problems are resolved
7. **Manual Trigger**: Can be triggered manually from the Actions tab

### What Happens

**When issues are found:**
1. 🔍 Scans all Swift files
2. 🤖 Auto-fixes common issues (button traits, decorative icons)
3. 📝 Creates a PR with fixes labeled `accessibility` and `automated`
4. ⚠️ Creates an issue for remaining manual fixes (if any)

**When no issues are found:**
- ✅ Closes any open accessibility audit issues

### Auto-Fix Capabilities

The workflow automatically fixes:

✅ **Adds `.accessibilityAddTraits(.isButton)` to `.onTapGesture`**
- Makes tappable views behave properly for VoiceOver

✅ **Adds `.accessibilityHidden(true)` to decorative icons**
- Only for common patterns (chevrons, arrows, info icons, etc.)

⚠️ **Adds TODO comments for images needing manual labels**
- Flags images that require human judgment and L10n keys

### Manual Fixes Required

Some fixes require human review:
- Proper L10n keys for accessibility labels
- Determining if images are decorative vs informative
- Context-specific accessibility hints
- Complex gesture interactions

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

- **PR Check Workflow**: `.github/workflows/AccessibilityCheck.yml`
- **Weekly Audit Workflow**: `.github/workflows/WeeklyAccessibilityAudit.yml`
- **Accessibility Checker Script**: `scripts/check-accessibility.sh`
- **Auto-Fix Script**: `scripts/auto-fix-accessibility.sh`
- **Documentation**: `docs/accessibility-workflow.md` (this file)

## Manual Usage

### Run Check Locally

You can run the accessibility checker locally:

```bash
# Check specific files
./scripts/check-accessibility.sh "Projects/MyModule/Sources/MyView.swift"

# Check all Swift files in a directory
find Projects/MyModule -name "*.swift" | xargs ./scripts/check-accessibility.sh
```

### Run Auto-Fix Locally

You can run the auto-fix script locally before committing:

```bash
# Auto-fix specific files
./scripts/auto-fix-accessibility.sh "Projects/MyModule/Sources/MyView.swift"

# Auto-fix all Swift files in a directory
./scripts/auto-fix-accessibility.sh $(find Projects/MyModule -name "*.swift" -type f | grep -v Test)

# Auto-fix all Swift files in the project
./scripts/auto-fix-accessibility.sh $(find Projects -name "*.swift" -type f | grep -v Test)
```

**Then verify the fixes:**
```bash
# Re-run the checker to see remaining issues
./scripts/check-accessibility.sh $(find Projects -name "*.swift" -type f | grep -v Test)

# Review the changes
git diff

# Test with VoiceOver before committing
```

### Trigger Weekly Audit Manually

You can trigger the weekly audit manually from GitHub:

1. Go to **Actions** tab in GitHub
2. Select **Weekly Accessibility Audit** workflow
3. Click **Run workflow** button
4. Select the branch and click **Run workflow**

### Configure Schedule

To change the weekly audit schedule, edit `.github/workflows/WeeklyAccessibilityAudit.yml`:

```yaml
on:
  schedule:
    # Change the cron expression (currently Monday 9 AM UTC)
    - cron: '0 9 * * 1'
```

Common cron patterns:
- `0 9 * * 1` - Every Monday at 9 AM UTC
- `0 9 * * 5` - Every Friday at 9 AM UTC
- `0 0 1 * *` - First day of every month at midnight UTC

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
