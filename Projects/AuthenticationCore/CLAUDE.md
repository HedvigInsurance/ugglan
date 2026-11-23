# AuthenticationCore

UI-free auth layer: `AuthenticationClient` / `AuthorizationCodeClient` protocols, the `AuthenticationService`
wrapper, and shared flow state (`OTPState`, `SEBankIDState`).

## Dependencies
- hCore. Octopus impl: `AuthenticationClientAuthLib` in App.
- Depended on by: AuthenticationUI, App, Profile (`OTPState` for the legal/contact screen)

## Gotchas
- `OTPState` is `@Observable` but not `@MainActor`, unlike most state in the project. It is shared across the OTP
  screens via `@Environment`.
- `AuthenticationService.logAuthResourceStart` / `logAuthResourceStop` are static closures that App's Datadog setup
  assigns at startup (`AppDelegate+Tracking`).
