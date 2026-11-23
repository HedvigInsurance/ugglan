---
paths:
  - "Projects/*/Sources/{Views,Screens,View,Viewables,Navigation,Components}/**/*.swift"
  - "Projects/*/Sources/*.swift"
  - "Projects/hCoreUI/Sources/**/*.swift"
  - "Projects/AuthenticationUI/Sources/**/*.swift"
---

# hCoreUI design system

<!-- Moved out of Projects/hCoreUI/CLAUDE.md so it loads when editing views in any module, not only inside hCoreUI.
     Keep it to "what exists and which one to pick"; signatures are in the source. -->

Every public type has the `h` prefix; use them instead of raw SwiftUI (see the table in the root CLAUDE.md).
Configuration goes through environment modifiers, e.g. `.hFieldSize(.large)`, `.sectionContainerStyle(.opaque)`,
`.hButtonIsLoading(true)`.

## Components

**Layout**
- `hForm` — scrollable screen container: keyboard handling, title, bottom-attached views, content position
- `hSection` / `hRow` / `hRowDivider` — card sections and their rows (accessories, tap handlers, dividers)
- `.sectionContainerStyle(...)` — `.transparent`, `.opaque`, `.translucent`, `.black`, `.negative`, `.primary`;
  `.sectionContainerDecorations([.border, .shadow])` adds a border and/or shadow

**Buttons**
- `hButton` — size (large/medium/small) × type (primary/primaryAlt/secondary/secondaryAlt/ghost/alert) × content
- `hCloseButton`, `hContinueButton`, `hCancelButton`, `hSaveButton` — pre-configured, localized
- `ToolbarButtonView` — navigation-bar button with tooltip; set via `setToolbar` / `setToolbarLeading` /
  `setToolbarTrailing` / `setHomeNavigationBars`, which also resolve the tooltip direction

**Text**
- `hText(_:style:)` with `HFontTextStyle` (display1-3, heading1-3, body1-3, label, finePrint, tabBar, responsive
  displayXXLShort…displayXSLong); falls back to the environment style or `.body1`
- `MarkdownView`, `hAttributedTextView` — Markdown / attributed text

**Input**
- `hFloatingTextField` (masking, focus, errors, clear button), `hFloatingField` (read-only, tap to open a picker)
- `hCounterField`, `hDatePickerField`, `hTextView` (multi-line with counter), `DropdownView`, `ItemPickerScreen`
- `hRadioOption` + `hRadioOptionList` — current radio spec. **Use these for new code, not `hRadioField`.**
  Navigation variants swap the indicator for a chevron and selection for `onTap`. `hRadioOptionList` owns the card
  and dividers (`.vertical` / `.horizontal`; pass `spacing:` for separate cards)
- `hRadioIndicator` — radio glyph only; for checkboxes use `hRadioOptionSelectedView` or `CheckboxToggleStyle`
- `hFieldSize` environment value — small, medium (default), large, extraLarge

**Feedback & state**
- `ProcessingStateView`, `SuccessScreen`, `GenericErrorView`, `StateView` — loading/success/error/empty screens
- `InfoCard` — info/attention/campaign/error/neutral/escalation card with optional buttons
- `Toasts.shared` / `ToastBar` — top toasts (attention/info/neutral)
- `Shimmer`, `BlurredProgressOverlay`, `ActivityIndicator` — loading placeholders

**Presentation** (see `CLAUDE-architecture.md` → Navigation)
- `hNavigationStack` + `NavigationRouter`, `.routerDestination(for:)`
- `.detent(...)` — bottom sheets; options `.alwaysOpenOnTop`, `.withoutGrabber`, `.disableDismissOnScroll`
- `.modally(...)` — full-screen modal; `.withDismissButton()` — dismiss button (apply before `.embededInNavigation`)

**Visual & misc**
- `hPill` (colors green…grey/clear × intensity one/two/three), `hRoundedRectangle` (per-corner radius)
- `.hShadow(type:)`, `.withGradientBorder(shape:)`, `AccordionView`, `CardView` / `CardStack`, `AddonPillowView`
- `hPagerDots`, `ScrollableSegmentedView`, `MarqueeText`, `ListItem`
- Animations: `.expandAppearAnimation()`, `.slideUpAppearAnimation()`, `.slideUpFadeAppearAnimation()`, `.rotate(...)`
- Shared screens: `QuoteSummaryScreen`, `ContractOverviewScreen`, `ConfirmChangesScreen`, `EditContractScreen`,
  `UpdateAppScreen`, `UpdateOSScreen`
- Also: `InfoViewHolder`, `PriceField` / `PriceBreakdownView`, `FileView` / `FileSourcePickerView`,
  `DocumentPreview`, `WaveformView`, `AudioPlayer`, `DatePickerView`, `StatusCard`

## Tokens

**Colors** — `hColor` types adapt to light/dark and base/elevated levels:
- `hTextColor.{Opaque,Translucent}`: primary, negative, secondary, tertiary, disabled, white, black, accordion;
  `hTextColor.Color`: action, link
- `hFillColor.Opaque`: primary, secondary, disabled, negative, black, white; `.Translucent`: primary, secondary,
  tertiary, disabled
- `hSurfaceColor`, `hBackgroundColor` (primary, negative, clear), `hBorderColor` (primary, secondary)
- `hSignalColor.{Green,Amber,Red,Blue}`: element, fill, highlight, text — semantic status
- `hHighlightColor.<Group>`: fillOne/Two/Three — for pills and tags
- `hButtonColor`: Primary, PrimaryAlt, Secondary, SecondaryAlt, Ghost (resting/hover/disabled)

**Spacing** — `CGFloat` statics `.padding2` … `.padding96` (e.g. `.padding8`, `.padding16`, `.padding24`).
Use one of these rather than a literal.

**Corner radius** — `.cornerRadiusXXXS` (2), `XS` (6), `S` (8), `M` (10), `L` (12), `XL` (16), `XXL` (24), `XXXL` (32).

**Typography** — HedvigLetters-Standard for body/heading/label, HedvigLetters-Big for display. Dynamic Type scales via
a multiplier capped at 2.5×.

## Gotchas
- `hSection {}`'s `RowViewBuilder` supports at most 9 children; for dynamic content use `hSection(list) { ... }`.
- `hColor` is not a SwiftUI `Color`. Resolve with `.colorFor(scheme, level).color`, or pass it straight to the
  overloaded `.foregroundColor()`.
- `hForm` disables scroll bounce when the content fits; re-enable with `.hSetScrollBounce(to: true)`.
- Fields read `hFieldSize` (default `.medium`); set it explicitly when you need another size.
- `hRadioOption` decides whether to draw its own card from internal environment values only `hRadioOptionList` sets.
  Setting them by hand strips the background.
- Put a flush `hRadioOptionList` in a `.sectionContainerStyle(.transparent)` section, or you get a second card behind
  it. With non-zero `spacing` the options carry their own cards.
- `.detent()` is a custom UIKit presentation, not SwiftUI `.sheet()`. Keep using it.
