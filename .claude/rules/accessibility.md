---
paths:
  - "Projects/*/Sources/{Views,Screens,View,Viewables,Navigation,Components}/**/*.swift"
  - "Projects/*/Sources/*.swift"
  - "Projects/hCoreUI/Sources/**/*.swift"
  - "Projects/AuthenticationUI/Sources/**/*.swift"
---

# Accessibility

<!-- General VoiceOver / Dynamic Type / contrast guidance was removed: Claude knows it. Keep this to what is specific
     to this repo: the CI rules, the scripts and our conventions. -->

## Conventions
- Accessibility labels, hints and announcements use `L10n` strings, never literals.
- Text goes through `hText(_, style:)` / `HFontTextStyle`, which scales with Dynamic Type (capped at 2.5×). No
  `.font(.system(size:))` and no fixed heights on text containers.
- Use `hTextColor` / `hSignalColor` tokens instead of raw colors, and never rely on color alone for status.
- Tap targets are at least 44×44pt; extend small ones with `.contentShape(Rectangle())` or padding.
- Group a row's icon, title and subtitle into one VoiceOver element with `.accessibilityElement(children: .combine)`.
- Info cards (`InfoCard`) give context for the rest of the screen, so VoiceOver should reach them first even when they
  sit at the bottom: use `.accessibilitySortPriority(_:)`.
- After async results, post `.announcement`; after inline changes (an error appears, a section expands) post
  `.layoutChanged` with the element that should get focus; after a full context change post `.screenChanged`.
- For segmented status views, build one label that combines the section title with the segment's status (see
  `ClaimStatusBar` in Claims for the pattern).

## CI rules

`scripts/accessibility/check-accessibility.sh` enforces five rules. It runs on every PR that touches Swift
(`AccessibilityCheck.yml`), every Friday on all of `Projects/` (`WeeklyAccessibilityAudit.yml`, which also opens an
auto-fix PR and an issue for the rest), and after each edit Claude makes to a file in `Projects/*/Sources/`
(`.claude/hooks/accessibility-check.sh`). It skips test files and anything after the first `PreviewProvider`.

1. **`.onTapGesture` needs `.accessibilityAddTraits`** somewhere in the same modifier chain
   (`scripts/accessibility/accessibility-tap-gesture.py` walks it). If the tap is conditional, gate the trait the same
   way:
   ```swift
   mainView
       .onTapGesture { onSelected?() }
       .accessibilityAddTraits(onSelected != nil ? .isButton : [])
   ```
2. **Icon-only `Button`** (contains `Image(` but no `Text(`) needs `.accessibilityLabel()` within 20 lines.
   `Button("Title") { }` is exempt.
3. **`Image(` / `KFImage(` at the start of a line** needs `.accessibilityLabel()` or `.accessibilityHidden(true)`
   within 15 lines. Decorative images (icons next to text, backgrounds) are hidden; informative ones get a label.
4. **`LongPressGesture`, `DragGesture`, `.gesture(`** need `.accessibilityAction()` or
   `.accessibilityAdjustableAction()` within 25 lines before or 60 after.
5. **`Toggle(` / `Picker(`** (not `DatePicker`) need `.accessibilityLabel()` within 5 lines.

The rules match text, not types, so a finding can be a false positive (e.g. the label is applied by a parent). Fix it
if it's real; otherwise say why it doesn't apply.

## Scripts

```bash
scripts/accessibility/check-accessibility.sh path/to/File.swift ...      # check (writes accessibility-report.md)
scripts/accessibility/auto-fix-accessibility.sh path/to/File.swift ...   # fix; no arguments scans all of Projects/
```

The auto-fixer only handles rule 1: it adds `.accessibilityAddTraits(.isButton)` when nothing in the chain sets traits
and the tap is unconditional. Conditional taps are reported for a manual fix. It skips previews and backs files up
before changing them.

The `@accessibility-agent` subagent goes beyond these mechanical checks (labels, reading order, focus handling). Use
it when building or substantially changing a screen.
