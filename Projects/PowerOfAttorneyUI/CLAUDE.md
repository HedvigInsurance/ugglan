# PowerOfAttorneyUI

Lets the member see the powers of attorney they have granted and the ones granted to them, and grant a new one to a co-insured by signing with
BankID, then sharing the resulting link via the system share sheet. Built on PowerOfAttorneyCore.

## Architecture
- **Pattern**: Per-screen `@MainActor @Observable` ViewModels, no store.
- **Signing flow (flow 1)**: the member picks a co-insured (or enters a personal number and looks it up), signs with
  BankID and shares the link. There's no level dropdown: with a co-insured selected, pressing add opens a level picker
  detent (`Full` / `CoInsured` on the wire) and continues with the picked level; an entered personal number always
  gets `.full`.
- **Login with the link (flow 2, lives outside this module)**:
  - `DeepLink.powerOfAttorney` (`/poa?id=`) is handled by App's `PowerOfAttorneyLinkCoordinator`, not by
    `DeepLinkHandler`, which only runs logged in. Behind the `enable_power_of_attorney` flag.
  - Logged out, it opens `BankIDLoginQRView(powerOfAttorneyId:)` in a login sheet of its own
    (`NotLoggedViewModel.powerOfAttorneyLogin`). Logged in, it shows an alert, and on confirm logs out and then opens
    that login.
  - `AuthenticationClient.startSeBankId(powerOfAttorneyId:)` starts it with `POST /member-login`, polls and exchanges
    the code like a normal login, then fetches `GET /power-of-attorney/current` (failing the login if it can't) and
    keeps it in the keychain. Every code exchange clears what an earlier login stored; logout clears it too.
  - `MainNavigationViewModel` reads it as an `ActingPowerOfAttorney` (hCore) and sets `\.actingPowerOfAttorney`.
    With full access it shows the whole logged-in app. With any other level `LoggedInNavigation` shows only the Home
    and Insurances tabs, limited by `\.hasLimitedAccess`: home keeps First Vet, inbox, make a claim, claims and a
    log out button; insurances hide cross-sells, addon offers and every editing action in the contract details.
  - `LoggedInNavigationViewModel.actingPowerOfAttorney` makes `DeepLinkHandler` (`ActingPowerOfAttorney.allows`) and
    `PushNotificationHandler` (`PushNotificationType.isAllowedWithLimitedAccess`) drop what those two tabs can't
    show.
  - Hiding things on the client is only for the user experience; the backend has to enforce the level.

## Key Files
- **Entry point**: `Views/PowerOfAttorneyListScreen.swift` — `PowerOfAttorneyListScreen` (public, pushed from
  Profile when `isPowerOfAttorneyEnabled` and not acting with a power of attorney)
- **Add flow**: `Navigation/PowerOfAttorneyNavigation.swift` — `PowerOfAttorneyNavigation` (presented as a large
  `.detent` from the list), `PowerOfAttorneyRouterType`, `PowerOfAttorneySuccessRouterType`
- **Screens**: `Views/PowerOfAttorneySelectCoInsuredScreen.swift` (co-insured list, or a personal number field +
  lookup; level picker detent for co-insured), `Views/PowerOfAttorneySigningScreen.swift` (BankID QR / open BankID / polling, using
  hCoreUI's `BankIDQRCodeView` and `BankIDApp`), `Views/PowerOfAttorneySuccessScreen.swift`
- **Models**: `Models/PowerOfAttorneyLevel+DisplayName.swift`

## Dependencies
- hCore, hCoreUI, PowerOfAttorneyCore (ContractsCore and EditStakeholdersCore only for preview demo clients)
- Depended on by: Profile

## Gotchas
- Revoke: given rows have a trash icon `Button` in a red circle (labelled "Revoke") with a confirmation alert. Only
  granted powers of attorney can be revoked, not received ones. When the row has a share link it is the share button,
  so the revoke button is hidden from VoiceOver and revoking goes through the row's "Revoke" accessibility action.
- Received powers of attorney: tapping a row posts its `/poa?id=` url as `.openDeepLink`, so it goes through the same
  login flow as a shared link (log out confirmation, then BankID). The row shows the granting member's id, since the
  endpoint doesn't return their name.
- Sharing: tapping a row opens hCoreUI's share popover (`ShareSheetPopoverPresenter` +
  `.shareSheetPopoverAnchor`), anchored to the row, also on iPhone. SwiftUI's
  `ShareLink` always presents from the bottom on iPhone.
- User-facing strings are hardcoded with `// TODO: Localize via Lokalise` until keys exist.
- No test target yet.
