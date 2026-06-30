# AuthenticationCore

Auth domain layer: protocols, the `AuthenticationService` wrapper, shared state (`OTPState`, `SEBankIDState`), and the route type. UI-free; depends only on `hCore`.

## Key Files
- `Sources/Service/AuthenticationClient.swift` — `AuthenticationClient`, `AuthorizationCodeClient`, `AuthorizationCodeCreationOutput`, `ObserveStatusResponseType`.
- `Sources/Service/AuthenticationService.swift` — `AuthenticationService` (`@MainActor`, `@Inject var client: AuthenticationClient`). Exposes static `logAuthResourceStart`/`logAuthResourceStop` callbacks set by App at startup.
- `Sources/OTP/OTPState.swift` — Shared `ObservableObject` for the OTP flow; referenced by both the protocol and the UI views.
- `Sources/SEBankID/SEBankIDState.swift` — Thin model (`autoStartToken`).

## Dependencies
- `hCore`
- Octopus impl (`AuthenticationClientAuthLib`) lives in `Projects/App/Sources/Service/OctopusClientsImplementation/`.

## Consumers
- `AuthenticationUI` (views + navigation built on top)
- `App` (DI registration, Octopus impl, login flow)
- `Profile` (uses `OTPState` for the legal/email contact screen)

## Gotchas
- `OTPState` is a plain `ObservableObject` (not `@MainActor`), unlike most VMs in the project. It's intentionally shared via `@EnvironmentObject` across OTP screens.
- `AuthenticationService.logAuthResourceStart` / `logAuthResourceStop` are static and set externally by App's Datadog setup.
