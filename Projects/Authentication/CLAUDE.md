# Authentication

Handles user login, logout, and auth token exchange. Supports two login methods: Swedish BankID (QR code flow) and OTP (email-based one-time password). Also provides token exchange for code and refresh token flows.

## Architecture
- Pattern: ViewModel (`@MainActor class: ObservableObject`). `AuthenticationService` uses `@Inject var client: AuthenticationClient`.
- Key services: `AuthenticationClient` (protocol), `AuthenticationService` (wrapper with logging)
- Data flow: `BankIDViewModel` drives the BankID QR flow, polling for status updates via a callback. `OTPEntryViewModel` and `OTPCodeEntryView` handle the email OTP flow using `OTPState` as shared state via `@EnvironmentObject`. `AuthenticationService` wraps all client calls with logging.

## Key Files
- BankID login: `BankIDLoginQRView` in `Sources/SEBankID/BankIDLoginQRView.swift` (also defines `AuthenticationRouterType` enum)
- BankID state: `SEBankIDState` in `Sources/SEBankID/SEBankIDState.swift`
- OTP entry: `OTPEntryView` in `Sources/OTP/OTPEntryView.swift`
- OTP code: `OTPCodeEntryView` in `Sources/OTP/OTPCodeEntryView.swift`
- OTP state: `OTPState` in `Sources/OTP/OTPState.swift`
- OTP helpers: `OTPResendCode`, `OTPCodeDisplay`, `OTPCodeLoadingOverlay`, `OpenEmailClientButton` in `Sources/OTP/`
- Error view: `LoginErrorView` in `Sources/LoginErrorView.swift`
- Service protocol: `AuthenticationClient` in `Sources/Service/AuthenticationClient.swift`
- Service implementation: `AuthenticationService` in `Sources/Service/AuthenticationService.swift`

## Dependencies
- Imports: hCore, hCoreUI
- Depended on by: Profile, App

## Navigation
- `AuthenticationRouterType` enum defines routes: `.emailLogin` (OTP entry), `.otpCodeEntry` (code verification), `.error(message:)` (error screen).
- `BankIDLoginQRView` is the primary entry point for Swedish users. It pushes to email login or error via the router.
- The OTP flow uses `OTPState` as a shared `@EnvironmentObject` across entry and code screens.
- Login success triggers `ApplicationState.preserveState(.loggedIn)` and `ApplicationState.state = .loggedIn`, then dismisses the router.
- This module does not define its own `RouterHost`; it expects to be hosted by the App module's authentication navigation.

## Gotchas
- `AuthenticationService` has static callbacks (`logAuthResourceStart`, `logAuthResourceStop`) for external logging hooks, which are set by the App at startup.
- `BankIDLoginQRView` includes a hidden demo mode trigger via a 3-second long press on the QR code area.
- `OTPState` is a plain `ObservableObject` (not `@MainActor`), while most of the codebase uses `@MainActor`. It is passed around as `@EnvironmentObject`.
- `SEBankIDState` is a minimal struct with just an optional `autoStartToken`; the real state lives in `BankIDViewModel`.
- The module has a `.testing` target in Project.swift, indicating it provides test helpers for other modules.
