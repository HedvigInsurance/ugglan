# Market

Provides locale/language selection for the app. Contains a language picker UI and a store that updates the current locale.

## Key Files
- `Sources/MarketStore.swift` — PresentableStore that handles `selectLanguage` action to update `Localization.Locale`
- `Sources/LanguagePickerView.swift` — SwiftUI radio-field list of all available locales with save/cancel

## Dependencies
- hCore, hCoreUI

## Gotchas
- Uses **PresentableStore** (legacy pattern) via `MarketStore`
- `MarketState` is empty; the store only produces side effects (broadcasting locale via `Localization.Locale.currentLocale`)
- Has `frameworkResources` target but no `example` or `tests` targets defined
