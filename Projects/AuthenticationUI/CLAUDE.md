# AuthenticationUI

SwiftUI views for the BankID and OTP login flows. Sits on top of `AuthenticationCore`.

## Key Files
- `Sources/SEBankID/BankIDLoginQRView.swift` — Swedish BankID QR login (primary login entry). Hidden demo-mode trigger via 3-second long press on the QR area.
- `Sources/OTP/OTPEntryView.swift` — Email entry screen for OTP login.
- `Sources/OTP/OTPCodeEntryView.swift` — Code verification screen.
- `Sources/OTP/OTPResendCode.swift`, `OTPCodeDisplay.swift`, `OTPCodeLoadingOverlay.swift`, `OpenEmailClientButton.swift` — OTP helper views.
- `Sources/Views/LoginErrorView.swift` — Generic auth error screen used by router.
- `Sources/Navigation/AuthenticationRouterType.swift` — `AuthenticationRouterType` enum + its `TrackingViewNameProtocol` conformance. Used by `App` (`LoginNavigation`, `NotLoggedInView`) for routing.

## Dependencies
- `AuthenticationCore`, `hCore`, `hCoreUI`

## Consumers
- `App` (`LoginNavigation` composes these views into the login flow)
- `Profile` (uses `OpenEmailClientButton` on the legal/contact screen)
