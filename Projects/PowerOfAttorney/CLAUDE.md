# PowerOfAttorney

Lets the member see the powers of attorney they have granted and grant a new one to a co-insured by signing with
BankID, then sharing the resulting link via the system share sheet.

## Architecture
- **Pattern**: Per-screen `@MainActor @Observable` ViewModels, no store.
- **Key services**:
  - `PowerOfAttorneyClient` -- protocol: `getPowerOfAttorneys()`, `getCoInsured()`, `getUser(personalNumber:)`,
    `startSigning(for:level:)`, `observeSigningStatus(pollUrl:)`.
  - `NetworkClient+PowerOfAttorneyClient` (in App's `OctopusClientsImplementation/`) -- plain HTTPS against
    `Environment.current.authUrl`, not GraphQL. Co-insured come from `FetchContractsClient`; `getUser(personalNumber:)`
    reuses the co-insured personal number lookup (`EditStakeholdersClient.fetchPersonalInformation`).
  - `PowerOfAttorneyService` -- `@Inject`-based wrapper that adds `@Log` logging.
  - `PowerOfAttorneyClientDemo` -- demo implementation.
- **Signing flow (flow 1)**: the member picks a co-insured and a level (`Full` / `CoInsured` on the wire).
  `POST /power-of-attorney {personalNumber, name, level}` returns `id`, `pollUrl` and BankID properties (`name` is
  shown in the BankID sign text). The app opens BankID / shows the QR code and `POST`s `{pollUrl}` every second
  (`liveQrCodeData` changes on every poll), showing `statusText`, until `COMPLETED` (with `powerOfAttorney.id`) or
  `FAILED`. The share link is built client side: `Environment.current.deepLinkUrl` + `/poa?id={id}`.
- **List**: `GET /power-of-attorney` returns `[{id, name, ssn, level}]` of the granted powers of attorney, oldest first.

## Key Files
- **Entry point**: `Views/PowerOfAttorneyListScreen.swift` -- `PowerOfAttorneyListScreen` (public, pushed from Profile)
- **Add flow**: `Navigation/PowerOfAttorneyNavigation.swift` -- `PowerOfAttorneyNavigation` (presented as a large
  `.detent` from the list), `PowerOfAttorneyRouterType`
- **Screens**: `Views/PowerOfAttorneySelectCoInsuredScreen.swift` (co-insured dropdown, or -- behind the "Enter
  personal number instead" toggle -- personal number field + "Fetch info" lookup like adding a co-insured; level
  dropdown),
  `Views/PowerOfAttorneySigningScreen.swift` (BankID QR / open BankID / polling),
  `Views/PowerOfAttorneySuccessScreen.swift` (pushed via `PowerOfAttorneySuccessRouterType` with `.hidesBackButton`)
- **Share button**: `Views/PowerOfAttorneyShareLink.swift` -- used in the list rows and on the success screen
- **Models**: `Models/PowerOfAttorneyModels.swift` -- `PowerOfAttorney` (name, ssn, status, level), `PowerOfAttorneyUser`,
  `PowerOfAttorneySigningSession`, `PowerOfAttorneySigningStatus`, `PowerOfAttorneyError`

## Dependencies
- **Imports**: hCore, hCoreUI
- **Depended on by**: Profile (pushes the list screen), App (DI registration)

## Gotchas
- The list endpoint returns no created date or status: the network client sets every item `.active` (the backend has
  no expiry/revocation yet) (TODO).
- `getCoInsured()` in the network client appends the demo client's fake members to the real co-insured (TODO).
- The poll returns 404 once the BankID order expires (~3 min) -> `PowerOfAttorneyError.signingExpired`, start over.
- All calls return 403 when the session itself is a power of attorney login. Not handled specially (shown as a
  generic error); the feature isn't hidden in such sessions.
- `PowerOfAttorneyShareLink` presents the share sheet as a popover anchored to the button, also on iPhone
  (adaptive style `.none`). SwiftUI's `ShareLink` was dropped because on iPhone it always presents from the bottom,
  and hCoreUI's `ModalPresentationSourceWrapper` presents from a detached hosting controller.
- User-facing strings are hardcoded with `// TODO: Localize via Lokalise` until keys exist.
- The module has no test target yet.
