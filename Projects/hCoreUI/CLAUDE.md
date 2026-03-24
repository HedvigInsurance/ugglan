# hCoreUI

Hedvig's design system framework for the iOS app. Provides all reusable UI components, color tokens, typography, spacing, and layout primitives used by every feature module. All public types follow the `h` prefix naming convention (hButton, hForm, hSection, etc.).

## Architecture
- Components are organized by function: `hButton/`, `hForm/`, `hText/`, `hColor/`, `Pill/`, `Views/`, `Router/`, etc.
- Heavy use of SwiftUI environment values for configuration (e.g., `.hFieldSize(.large)`, `.sectionContainerStyle(.opaque)`, `.hButtonIsLoading(true)`)
- Custom `hColor` protocol wraps SwiftUI `Color` to support light/dark mode and base/elevated interface levels
- Custom `@resultBuilder` (`RowViewBuilder`) is used for `hSection` to automatically assign row positions (top/middle/bottom)
- `Fonts/` loads custom Hedvig typefaces: HedvigLetters-Standard and HedvigLetters-Big
- Generated assets are in `Derived/` via Tuist resource generation (`hCoreUIAssets`)

## Component Catalog

### Layout
- **hForm** -- Scrollable form container with keyboard handling, title, bottom-attached views, and content positioning (top/center/bottom/compact)
- **hSection** -- Card-like container with rounded corners and background; uses `RowViewBuilder` to auto-position children; supports headers with info buttons
- **hRow** -- Row within an hSection; supports accessories (chevron, checkmark, custom), tap handlers, dividers, and padding modifiers
- **hRowDivider** -- Thin horizontal divider line between rows, respects horizontal padding settings
- **hSectionContainerStyle** -- Environment modifier controlling section background: `.transparent`, `.opaque`, `.black`, `.negative`

### Buttons & Actions
- **hButton** -- Primary button component; takes `hButtonSize` (large/medium/small), `hButtonConfigurationType` (primary/primaryAlt/secondary/secondaryAlt/ghost/alert), and `hButtonContent` (title + optional image)
- **hCloseButton** -- Pre-configured large ghost button with localized "Close" text
- **hContinueButton** -- Pre-configured large primary button with localized "Continue" text
- **hCancelButton** -- Pre-configured cancel button
- **hSaveButton** -- Pre-configured save button
- **ToolbarButtonView** -- Toolbar-positioned button for navigation bars, with tooltip support

### Text & Typography
- **hText** -- Styled text view; applies the Hedvig font for the given `HFontTextStyle`; falls back to environment default style or `.body1`
- **hFontModifier** -- ViewModifier that applies Hedvig custom font at the correct size with dynamic type multiplier
- **HFontTextStyle** -- Enum defining all type styles: display1-3, heading1-3, body1-3, label, finePrint, tabBar, and responsive display sizes (displayXXLShort through displayXSLong)
- **MarkdownTextView** -- Renders attributed/Markdown text content
- **hAttributedTextView** -- UIViewRepresentable for rendering attributed strings

### Input Fields
- **hFloatingTextField** -- Floating-label text field with masking, focus state management, error display, and clear button
- **hFloatingField** -- Floating-label read-only field that triggers an action on tap (used for picker-backed fields)
- **hTextField** -- Simpler text field without floating label; supports masking, divider, and error messages
- **hCounterField** -- Numeric stepper field with plus/minus buttons, floating label, and min/max bounds
- **hDatePickerField** -- Tappable field that opens a date picker in a detent sheet
- **hTextView** -- Multi-line text area with character count, opens a full-screen editing popup
- **hRadioField** -- Radio selection field with animated background; supports custom left views or ItemModel-based content
- **hRadioOptionSelectedView** -- Circle or checkbox indicator for radio/checkbox selection state
- **CheckboxToggleStyle** -- Custom ToggleStyle that renders a checkbox inside an hRow
- **DropdownView** -- Tappable field with a chevron-down trailing icon for dropdown selection
- **ItemPickerScreen** -- Full-screen list picker for selecting items from a collection; supports search, manual input, and info cards
- **hFieldBackground** -- Shared field background modifier with animated highlight on interaction and amber flash on error
- **hFieldSize** -- Environment value controlling field sizing: small, medium, large, extraLarge, capsuleShape

### Feedback & State
- **ProcessingStateView** -- Animated loading/success/error state view with progress bar animation
- **SuccessScreen** -- Success state with icon, title, subtitle, and configurable bottom actions
- **GenericErrorView** -- Error state with warning icon, retry button, and dismiss option
- **StateView** -- Shared backing view for success/error/information/bankId/empty states with configurable buttons
- **ToastBar / Toasts** -- Notification toast system; slides in from top with swipe-to-dismiss; supports attention/info/neutral types
- **InfoCard** -- Colored notification card (info/attention/campaign/error/neutral/escalation) with optional action buttons
- **ShimmerModifier** -- Loading placeholder shimmer animation overlay
- **BlurredProgressView** -- Progress indicator with blur background
- **ActivityIndicator / ActivityView** -- UIKit activity indicator wrappers for SwiftUI

### Navigation & Presentation
- **Router** -- Observable navigation controller wrapping UINavigationController; supports push, pop, popToRoot, dismiss
- **RouterHost** -- SwiftUI view that creates and manages a Router-driven navigation stack
- **DetentRouter** -- Sheet presentation system via `.detent()` modifier; supports height-based detents and centered modal style
- **DetentPresentationOption** -- Options: `.alwaysOpenOnTop`, `.withoutGrabber`, `.disableDismissOnScroll`
- **ModallyRouter** -- Additional modal presentation support
- **hHostingController** -- Custom UIHostingController with lifecycle hooks (onDeinit, onDismiss, onViewWillAppear, etc.)
- **View+dismissButton** -- Adds a dismiss button to views presented modally

### Shapes & Visual
- **hRoundedRectangle** -- Custom rounded rectangle supporting per-corner radius (wraps UIBezierPath for selective corners)
- **hShadow** -- Shadow modifier with presets: `.default`, `.light`, `.custom(...)`
- **GradientAnimatedBorder** -- Animated gradient border effect
- **ColorAnimationView** -- Animated color transition view
- **CardView / CardStack** -- Card-based layout components
- **Accordion** -- Expandable/collapsible section used in peril displays

### Pager & Lists
- **hPagerDots** -- Page indicator dots for paged content
- **ScrollableSegmentedView** -- Horizontally scrollable segmented control
- **MarqueeText** -- Auto-scrolling text for overflowing content
- **ListItem** -- Generic list item component

### Pills & Tags
- **hPill** -- Colored label pill/badge with configurable color (green/yellow/blue/teal/purple/pink/amber/red/grey/clear), intensity level (one/two/three), border, and size
- **PillColor** -- Enum mapping pill semantic colors to highlight color tokens
- **Spacing** -- Simple spacer view with explicit height or width

### Animations
- **ExpandAppearAnimationModifier** -- Fade-in with spring animation on appear (`.expandAppearAnimation()`)
- **SlideUpAppear** -- Slide-up entrance animation
- **SlideUpFadeAppear** -- Combined slide-up and fade entrance
- **Rotate** -- Continuous rotation animation

### Other
- **InfoViewHolder** -- Info button that presents a detail sheet with title and description
- **PriceField / PriceBreakdownView** -- Price display components with breakdown support
- **FileView / FileSourcePickerView** -- File display and source picker for document uploads
- **DocumentPreview** -- Document preview using QuickLook
- **WaveformView** -- Audio waveform visualization
- **AudioPlayer / TrackPlayer** -- Audio playback components
- **QuoteSummaryScreen / ContractOverviewScreen** -- Insurance quote and contract summary views
- **GeneralDatePicker** -- General-purpose date picker view
- **ConfirmChangesScreen / EditContractScreen** -- Contract modification screens
- **UpdateAppScreen / UpdateOSScreen** -- Force-update prompt screens
- **StatusCard** -- Status display card
- **SVGImageProcessor** -- Processes SVG images for display

## Design Tokens

### Colors
The color system uses the `hColor` protocol. Colors adapt to light/dark mode and base/elevated interface levels.

**Text colors** (`hTextColor`):
- `Opaque`: primary, negative, secondary, tertiary, disabled, white, black, accordion
- `Translucent`: primary, negative, secondary, tertiary, disabled, black, white, accordion
- `Color`: action (red), link (blue)

**Fill colors** (`hFillColor`):
- `Opaque`: primary, secondary, disabled, negative, black, white
- `Translucent`: primary, secondary, tertiary, disabled

**Surface colors** (`hSurfaceColor`):
- `Opaque`: primary
- `Translucent`: primary, secondary

**Background colors** (`hBackgroundColor`):
- primary, negative, clear

**Border colors** (`hBorderColor`):
- primary, secondary

**Signal colors** (`hSignalColor`) -- semantic status colors:
- `Green`: element, fill, highlight, text
- `Amber`: element, fill, highlight, text
- `Red`: element, fill, highlight, text
- `Blue`: element, fill, highlight, text

**Highlight colors** (`hHighlightColor`) -- for pills and tags:
- Groups: Green, Yellow, Blue, Teal, Purple, Pink, Amber, Red
- Each group has: fillOne, fillTwo, fillThree

**Base grayscale** (`hGrayscaleOpaqueColor`):
- white, greyScale25 through greyScale1000, black

**Button colors** (`hButtonColor` protocol):
- Primary, PrimaryAlt, Secondary, SecondaryAlt, Ghost -- each with resting, hover, disabled states

### Spacing
Defined as `CGFloat` static extensions (used as `.padding16`, etc.):
- `.padding2`, `.padding3`, `.padding4`, `.padding6`, `.padding8`, `.padding10`, `.padding12`, `.padding14`, `.padding16`, `.padding18`, `.padding19`, `.padding21`, `.padding24`, `.padding32`, `.padding40`, `.padding45`, `.padding48`, `.padding56`, `.padding60`, `.padding64`, `.padding72`, `.padding80`, `.padding88`, `.padding96`

### Corner Radius
Defined as `CGFloat` static extensions:
- `.cornerRadiusXXXS` (2), `.cornerRadiusXS` (6), `.cornerRadiusS` (8), `.cornerRadiusM` (10), `.cornerRadiusL` (12), `.cornerRadiusXL` (16), `.cornerRadiusXXL` (24)

### Typography
Two custom font families loaded from `.otf` files:
- **HedvigLetters-Standard** -- used for body, heading, label, finePrint, tabBar
- **HedvigLetters-Big** -- used for all display sizes (displayXXL through displayXS)

Text styles and their font sizes:
- `display1` (54), `display2` (68), `display3` (84)
- `heading1` (18), `heading2` (24), `heading3` (32)
- `body1` (18), `body2` (24), `body3` (32)
- `label` (14), `finePrint` (12), `tabBar` (10)
- Responsive display sizes: `displayXXLShort` (92) through `displayXSLong` (28)

Dynamic Type is supported via a multiplier system (capped at 2.5x).

## Key Files

**Entry points and configuration:**
- `Sources/Styling/DefaultStyling.swift` -- Global UIKit appearance setup (navigation bar, tab bar, segmented control)
- `Sources/Fonts/Fonts.swift` -- Custom font loading and font resolution

**Core components:**
- `Sources/hForm/hForm.swift` -- Form container
- `Sources/hForm/hSection.swift` -- Section container + RowViewBuilder
- `Sources/hForm/hRow.swift` -- Row component + accessories
- `Sources/hButton/hButton.swift` -- Button component + environment keys
- `Sources/hText/hText.swift` -- Text component + HFontTextStyle enum
- `Sources/hColor/hColor.swift` -- Full color token system (2000+ lines)

**Input fields:**
- `Sources/hForm/hFloatingTextField.swift` -- Primary text input
- `Sources/hForm/hFloatingField.swift` -- Tappable floating field
- `Sources/hForm/hRadioFields/hRadioField.swift` -- Radio selection
- `Sources/hForm/hCounterField.swift` -- Counter input
- `Sources/hForm/hDatePickerField.swift` -- Date picker field

**Navigation:**
- `Sources/Router/Router.swift` -- Navigation router + RouterHost
- `Sources/Router/DetentRouter.swift` -- Sheet/detent presentation

**State and feedback:**
- `Sources/Views/ProcessingStateView.swift` -- Loading/success/error states
- `Sources/Views/StateView.swift` -- Shared state view backing
- `Sources/Toasts.swift` -- Toast notification system

## Dependencies
- **hCore** -- The only module-level dependency (data models, utilities, localization via `L10n`)
- **External**: SwiftUIIntrospect (for UIKit bridging), DynamicColor (for hex color init), SnapKit (for toast layout)

Note: Nearly every feature module in the app depends on hCoreUI.

## Gotchas
- `RowViewBuilder` is a custom `@resultBuilder` that only supports up to 9 children in a single `hSection {}` block. For dynamic lists, use `hSection(list) { element in ... }` instead.
- `hColor` is not a SwiftUI `Color` -- it is a custom protocol. Use `.colorFor(scheme, level)` to resolve to `hColorBase`, then `.color` to get the SwiftUI `Color`. The `foregroundColor()` extension on `View` is overloaded to accept `hColor` types directly.
- Button types always trigger haptic feedback (`UIImpactFeedbackGenerator`) on tap -- this is built into `_hButton`.
- `hForm` disables scroll bounce by default when content fits within the view height. Override with `.hSetScrollBounce(to: true)`.
- Field components (hFloatingTextField, hRadioField, etc.) rely on the `hFieldSize` environment value defaulting to `.medium`. Always set it explicitly if you need a different size.
- The `Router` is UIKit-based (wraps `UINavigationController`); route destinations must conform to `Hashable & TrackingViewNameProtocol`. Register route builders via `router.builders[key]` before pushing.
- `DefaultStyling.installCustom()` must be called at app launch to configure global UIKit appearances (navigation bar, tab bar, date picker tint, etc.).
- Toast notifications are singleton-managed via `Toasts.shared` and display on the app's key window. Duplicate toasts (same text) are suppressed.
- The `.detent()` modifier uses a custom UIKit presentation controller, not the native SwiftUI `.sheet()`. It supports height-based sizing and centered modal display.
