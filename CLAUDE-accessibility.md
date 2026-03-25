# Accessibility Guidelines

## VoiceOver & Screen Reader Support

All interactive elements must be reachable and announced by VoiceOver.

- `.accessibilityLabel` — primary spoken description
- `.accessibilityHint` — additional context spoken after a pause
- `.accessibilityValue` — conveys dynamic/changing state (progress, selection)
- `.accessibilityElement(children: .combine)` — merges child elements into one VoiceOver element
- `UIAccessibility.post(notification: .layoutChanged, argument: view)` — shifts focus after layout changes
  - Use when part of the screen updates (e.g., a section expands/collapses, an inline error appears, or content reloads). Pass the element that should receive focus, or `nil` to reset to the first element.
- `UIAccessibility.post(notification: .screenChanged, argument: view)` — shifts focus after screen transitions
  - Use when the entire screen context changes (e.g., a modal is presented, a navigation push occurs, or an overlay takes over). This tells VoiceOver to re-read from the top of the new context.
- `UIAccessibility.post(notification: .announcement, argument: message)` — announces state changes
  - Use for transient feedback that doesn't change focus (e.g., "Item added to cart", "Upload complete", "Error: invalid input"). The message is spoken once and not repeated.
- Avoid relying on visuals alone to communicate meaning

### Common VoiceOver Patterns

```swift
// Grouping related elements into a single VoiceOver stop
HStack {
    Image(uiImage: icon)
    VStack {
        hText(title, style: .body)
        hText(subtitle, style: .footnote)
    }
}
.accessibilityElement(children: .combine)

// Announcing a result after an async operation
func onLoadComplete() {
    UIAccessibility.post(notification: .announcement, argument: L10n.General.loadComplete)
}

// Moving focus to a new inline error
func showValidationError() {
    UIAccessibility.post(notification: .layoutChanged, argument: errorLabel)
}
```

## Dynamic Type & Font Scaling

Text must scale with the system font setting.

- Use `.font(.body)` or `hText("...", style: .body)` — never `.font(.system(size: N))` without scaling
- `.minimumScaleFactor()` prevents text from being clipped in tight layouts while still scaling
- Support the largest accessibility text size without truncation or layout breakage
- Never use fixed font sizes
- Use `.dynamicTypeSize(...)` to constrain scaling range when needed

```swift
// Correct — scales with Dynamic Type
hText(L10n.General.title, style: .body)

// Correct — constrains scaling range for a compact layout
hText(L10n.General.subtitle, style: .footnote)
    .dynamicTypeSize(.xSmall ... .xxxLarge)

// Wrong — fixed size, will not scale
Text("Title")
    .font(.system(size: 16))

// Wrong — fixed frame clips large text sizes
Text("Label")
    .frame(height: 20)
```

## Color & Contrast

- **4.5:1** minimum contrast ratio for body text
- **3:1** minimum for large/bold text
- Don't rely on color alone to communicate status or information
- Use semantic colors (`.label`, `.secondaryLabel`) when possible
- Test in both Light and Dark Mode
- Test with Color Filters enabled
- Use Accessibility Inspector's contrast checker

## Touch Target Size

- **44pt × 44pt** minimum for all interactive elements
- Use `.contentShape(Rectangle())` to extend the tappable area beyond visual bounds
- Use padding or invisible hit areas around small visual elements

## Labels & Semantics

- Every actionable item must have a descriptive `.accessibilityLabel`
- `.accessibilityHint` where actions aren't obvious from the label alone
- `.accessibilityTraits` correctly applied (`.isButton`, `.isHeader`, etc.)
- `.accessibilityHidden(true)` on purely decorative elements (icons alongside text, backgrounds, dividers)
- All labels MUST use `L10n` localized strings, never hardcoded strings

## Navigation Order

- VoiceOver swipe order should match the visual hierarchy
- `.accessibilitySortPriority()` to tweak reading order where needed
- `UIAccessibility.post(...)` to manage focus after transitions
- Info cards should be read first even if visually positioned last (they contain context for the rest of the screen)
- Test swipe order using VoiceOver

## Testing Checklist

- Test all user flows with VoiceOver enabled
- Test with the largest accessibility text sizes
- Test in high contrast / dark mode
- Use Accessibility Inspector for missing labels, low contrast, and incorrect focus order
- Run `scripts/check-accessibility.sh` locally before PR
- Verify swipe order matches visual reading order on every screen
- Confirm all buttons and interactive elements announce their role (`.isButton`, `.isLink`)
- Check that loading/progress states are announced via `.announcement`
- Ensure no decorative images are exposed to VoiceOver (use `.accessibilityHidden(true)`)
- Verify dynamic content updates shift focus appropriately (`.layoutChanged` / `.screenChanged`)

---

## CI Enforcement

Two GitHub Actions workflows enforce accessibility:

- **AccessibilityCheck.yml** runs on every PR that touches `.swift` files. It runs `scripts/check-accessibility.sh` on the changed files and comments on the PR if issues are found.
- **WeeklyAccessibilityAudit.yml** runs every Friday at 11:00 AM UTC. It scans all Swift files in `Projects/` (excluding tests), runs both the checker and auto-fixer, creates a PR with auto-fixes, and files a GitHub issue for remaining manual fixes.

## Required Rules

The CI checker (`scripts/check-accessibility.sh`) skips test files (`*Test.swift`, `Tests/`) and strips `PreviewProvider` blocks before scanning. Five rules are enforced:

### Rule 1: `.onTapGesture` requires `.accessibilityAddTraits(.isButton)`

The checker looks for `.accessibilityAddTraits(.isButton)` within 10 lines after `.onTapGesture`.

```swift
// Correct
Text("Edit")
    .onTapGesture { viewModel.edit() }
    .accessibilityAddTraits(.isButton)

// Violation - missing trait
Text("Edit")
    .onTapGesture { viewModel.edit() }
```

### Rule 2: Icon-only `Button` requires `.accessibilityLabel()`

Buttons containing `Image(` but no `Text(` must have `.accessibilityLabel()` within 20 lines. Buttons with a text title like `Button("Save") { ... }` are excluded.

```swift
// Correct
Button { dismiss() } label: {
    Image(uiImage: hCoreUIAssets.close.image)
}
.accessibilityLabel(L10n.closeButton)

// Violation - icon-only button without label
Button { dismiss() } label: {
    Image(uiImage: hCoreUIAssets.close.image)
}
```

### Rule 3: `Image`/`KFImage` requires accessibility handling

`Image(` and `KFImage(` at the start of lines (excluding `UIImage(`) must have `.accessibilityLabel()` or `.accessibilityHidden(true)` within 15 lines.

```swift
// Decorative image - hide from VoiceOver
Image(uiImage: hCoreUIAssets.infoIconFilled.image)
    .accessibilityHidden(true)

// Informative image - provide label
Image(uiImage: hCoreUIAssets.warningTriangle.image)
    .accessibilityLabel(L10n.warningIcon)
```

### Rule 4: Custom gestures require accessibility alternatives

`LongPressGesture`, `DragGesture`, and `.gesture(` must have `.accessibilityAction()` or `.accessibilityAdjustableAction()` within 25 lines before or 60 lines after.

```swift
// Correct
Circle()
    .gesture(DragGesture().onChanged { ... })
    .accessibilityAction(.default) { viewModel.activate() }
```

### Rule 5: `Toggle`/`Picker` requires `.accessibilityLabel()`

`Toggle(` and `Picker(` (not `DatePicker`) must have `.accessibilityLabel()` within 5 lines.

```swift
// Correct
Toggle(isOn: $isEnabled) { Text(L10n.settingLabel) }
    .accessibilityLabel(L10n.settingLabel)
```

## Auto-fix

The auto-fixer (`scripts/auto-fix-accessibility.sh`) currently handles one rule automatically:

- Adds `.accessibilityAddTraits(.isButton)` after `.onTapGesture` closures (both single-line and multi-line)
- Uses Python for proper brace matching and preserves indentation
- Skips files containing `PreviewProvider`
- Creates backups before modifying files

All other rules require manual fixes.

## Best Practices

- **Group related elements**: Use `.accessibilityElement(children: .combine)` to merge child elements into a single accessible element
- **Dynamic state**: Use `.accessibilityValue()` to convey changing state (e.g., progress, selection)
- **Localized labels**: Always use `L10n` strings for accessibility labels, never hardcoded strings
- **Context-aware labels**: Build descriptive labels that include context (see pattern example below)

### Pattern Example: Context-Aware Labels

Build accessibility text that combines a section title with the specific status detail:

```swift
func accessibilityText(segment: ItemStatus) -> String? {
    let sectionTitle = L10n.StatusSection.title
    switch status {
    case .submitted:
        if segment == .submitted {
            return sectionTitle + " " + L10n.StatusSection.Detail.submitted
        }
    case .inProgress:
        switch segment {
        case .submitted:
            return sectionTitle + " " + L10n.StatusSection.inProgress + " "
                + L10n.StatusSection.Detail.submitted
        // ...
        }
    }
}

// Applied to each segment in the view
.accessibilityLabel(accessibilityText(segment: segment) ?? "")
```

## Running Locally

Check specific files:
```bash
scripts/check-accessibility.sh path/to/File1.swift path/to/File2.swift
```

Auto-fix specific files:
```bash
scripts/auto-fix-accessibility.sh path/to/File1.swift path/to/File2.swift
```

Scan all project files:
```bash
scripts/auto-fix-accessibility.sh  # no arguments scans Projects/
```
