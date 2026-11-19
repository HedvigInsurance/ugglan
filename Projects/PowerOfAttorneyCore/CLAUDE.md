# PowerOfAttorneyCore

UI-free data layer for powers of attorney: models, the client protocol, the service and the demo client. No SwiftUI or
hCoreUI.

## Key Files
- `Sources/Models/PowerOfAttorneyModels.swift` — `PowerOfAttorney` (granted: name, ssn, level, share url),
  `ReceivedPowerOfAttorney` (granted to the member: granting member id, name, level, login url),
  `PowerOfAttorneyUser`, `PowerOfAttorneySigningSession`, `PowerOfAttorneySigningStatus`, `PowerOfAttorneyError`
- `Sources/Service/Protocols/PowerOfAttorneyClient.swift` — `getPowerOfAttorneys()`,
  `getReceivedPowerOfAttorneys()`, `revokePowerOfAttorney(id:)`, `startSigning(for:level:)`,
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
- `GET /power-of-attorney` — `[{id, name, ssn, level, revokedAt}]`, oldest first. Revoked ones stay in the list
  (`revokedAt` set); the Octopus client drops them
- `GET /power-of-attorney/received` — `[{id, memberId, name, level}]`, oldest first: the powers of attorney whose
  personal number matches the member's. `memberId` is the granting member, `name` is the member's own name as the
  granter typed it (the granter's name isn't returned). 403 for a power of attorney login
- `POST /power-of-attorney/{id}/revoke` — empty 200; also logs out the power of attorney's sessions and blocks new
  logins with it. 403 if the caller didn't grant it
- `POST /power-of-attorney {personalNumber, name, level}` — `id`, `pollUrl`, BankID properties (`name` is shown in
  the BankID sign text)
- `POST {pollUrl}` every second (`liveQrCodeData` changes on every poll) until `COMPLETED` (with
  `powerOfAttorney.id`) or `FAILED`. 404 once the BankID order expires (~3 min) → `PowerOfAttorneyError.signingExpired`
- The share link (and a received one's login url) is built client side: `Environment.current.deepLinkUrl` +
  `/poa?id={id}`

## Dependencies
- hCore (+ AutomaticLog), ContractsCore, EditStakeholdersCore
- Depended on by: PowerOfAttorneyUI, App (Octopus client, DI)

## Gotchas
- The service resolves `FetchContractsClient` and `EditStakeholdersClient`, so both must be registered (demo mode
  registers `EditStakeholdersClientDemo`).
- There's no revoked state in the app: revoked powers of attorney are filtered out of the granted list. The
  received list has no `revokedAt`, so revoked ones still show there (logging in with them fails).
- All calls return 403 when the session itself is a power of attorney login (Profile hides the entry then).
- No test target yet.
