# ExampleUtil

Shared setup utility for Example app targets. Provides a `UIApplication.setup()` extension that configures the default locale for development and preview use.

## Key Files
- `Sources/Setup.swift` — Single file; extends `UIApplication` with `setup()` to set locale to `.en_SE`

## Dependencies
- hCore, CoreDependencies

## Gotchas
- No `Project.swift` exists in this module; it is likely defined as an implicit target by the Tuist project generation helpers
- Minimal module; only one source file with one method
- Used by Example targets of other modules (e.g., Testing/Example imports ExampleUtil)
