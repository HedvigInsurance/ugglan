# Market

Language selection for the app: `LanguagePickerView`, a radio-field list of the available `Localization.Locale`
values with save/cancel callbacks.

## Dependencies
- hCore, hCoreUI
- Depended on by: App (login screen), Profile

## Gotchas
- Targets are `framework` + `frameworkResources` only; there are no tests.
- The view only updates the locale; callers persist the change (e.g. `ProfileStore.updateLanguage()`).
