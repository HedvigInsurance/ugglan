# PowerOfAttorneyCore

UI-free data layer for powers of attorney: models, the client protocol, the service and the demo client. No SwiftUI or
hCoreUI.

## Key Files
- `Sources/Models/PowerOfAttorneyModels.swift` — `PowerOfAttorney` (granted: name, ssn, level, share url),
  `PowerOfAttorneyUser`, `PowerOfAttorneySigningSession`, `PowerOfAttorneySigningStatus`, `PowerOfAttorneyError`
- `Sources/Service/Protocols/PowerOfAttorneyClient.swift` — `getPowerOfAttorneys()`, `startSigning(for:level:)`,
  `observeSigningStatus(pollUrl:)`
- `Sources/Service/PowerOfAttorneyService.swift` — `@Log` wrapper around the client, plus the composition that
  isn't a power of attorney endpoint: `getCoInsured()` (from `FetchContractsClient`) and `getUser(personalNumber:)`
  (`EditStakeholdersClient.fetchPersonalInformation`, the same lookup as adding a co-insured)
- `Sources/Service/DemoImplementation/PowerOfAttorneyClientDemo.swift` — demo client

The level (`PowerOfAttorneyLevel`) and the acting person (`ActingPowerOfAttorney`) live in hCore, since
AuthenticationCore, Home, ContractsUI and App need them too.

## API
Plain HTTPS against `Environment.current.authUrl`, not GraphQL. The Octopus client is App's
`NetworkClient+PowerOfAttorneyClient`; every request (also the login ones) is built by App's `PowerOfAttorneyRequest`.
- `GET /power-of-attorney` — `[{id, name, ssn, level}]`, oldest first
- `POST /power-of-attorney {personalNumber, name, level}` — `id`, `pollUrl`, BankID properties (`name` is shown in
  the BankID sign text)
- `POST {pollUrl}` every second (`liveQrCodeData` changes on every poll) until `COMPLETED` (with
  `powerOfAttorney.id`) or `FAILED`. 404 once the BankID order expires (~3 min) → `PowerOfAttorneyError.signingExpired`
- The share link is built client side: `Environment.current.deepLinkUrl` + `/poa?id={id}`

## Dependencies
- hCore (+ AutomaticLog), ContractsCore, EditStakeholdersCore
- Depended on by: PowerOfAttorneyUI, App (Octopus client, DI)

## Gotchas
- The service resolves `FetchContractsClient` and `EditStakeholdersClient`, so both must be registered (demo mode
  registers `EditStakeholdersClientDemo`).
- The list endpoint has no status or expiry yet, so there's no revoked state.
- All calls return 403 when the session itself is a power of attorney login (Profile hides the entry then).
- No test target yet.
