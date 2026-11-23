# AuthenticationUI

SwiftUI screens for login: Swedish BankID QR login (`BankIDLoginQRView`, the primary entry), the OTP email/code
screens, and `LoginErrorView`. Built on AuthenticationCore.

## Entry points
- App's `LoginNavigation` composes these screens and routes with `AuthenticationRouterType`, which is defined here.

## Dependencies
- hCore, hCoreUI, AuthenticationCore
- Depended on by: App, Profile (`OpenEmailClientButton` on the legal/contact screen)

## Gotchas
- `BankIDLoginQRView` has a hidden demo-mode trigger: a 3-second long press on the QR area.
