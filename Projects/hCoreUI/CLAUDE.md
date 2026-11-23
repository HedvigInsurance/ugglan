# hCoreUI

Hedvig's design system framework for the iOS app. Provides all reusable UI components, color tokens, typography,
spacing, and layout primitives used by every feature module. All public types follow the `h` prefix naming convention
(hButton, hForm, hSection, etc.).

## Architecture
- Components are organized by function: `hButton/`, `hForm/`, `hText/`, `hColor/` (full color token system),
  `Pill/`, `Views/`, `Router/` (navigation + presentation), etc.
- Heavy use of SwiftUI environment values for configuration (e.g., `.hFieldSize(.large)`,
  `.sectionContainerStyle(.opaque)`, `.hButtonIsLoading(true)`)
- Custom `hColor` protocol wraps SwiftUI `Color` to support light/dark mode and base/elevated interface levels
- Custom `@resultBuilder` (`RowViewBuilder`) is used for `hSection` to automatically assign row positions
  (top/middle/bottom)
- `Fonts/` loads custom Hedvig typefaces: HedvigLetters-Standard and HedvigLetters-Big
- Generated assets are in `Derived/` via Tuist resource generation (`hCoreUIAssets`)

The component catalog, design tokens and usage gotchas live in `.claude/rules/design-system.md`, which loads
automatically when editing view code in any module.

## Dependencies
- **hCore** -- The only module-level dependency (data models, utilities, localization via `L10n`)
- **External**: DynamicColor (hex color init), SnapKit (UIKit layout)

Note: Nearly every feature module in the app depends on hCoreUI.

## Gotchas
- Button types always trigger haptic feedback (`UIImpactFeedbackGenerator`) on tap -- this is built into `_hButton`.
- `NavigationRouter.push` only accepts routes that are `Hashable & TrackingViewNameProtocol`.
- `DefaultStyling.installCustom()` must be called at app launch to configure global UIKit appearances (navigation bar,
  tab bar, date picker tint, etc.).
- Toast notifications are singleton-managed via `Toasts.shared` and display on the app's key window. Duplicate toasts
  (same text) are suppressed.
