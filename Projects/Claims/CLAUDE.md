# Claims

Shows insurance claims after submission: active-claim cards on Home (including a resumable in-progress claim),
the claim detail screen with file uploads and chat access, and the claim history screen for closed claims.

## Architecture
- `ClaimsStore` is a `@PersistableStore` `AppStore` holding `activeClaims`, `historyClaims`, per-claim `files` and
  `claimInProgress`. Its fetch methods call `hFetchClaimsClient` directly. `allActiveClaims` merges the in-progress
  draft with the active claims for `ClaimsCard`. `claimInProgress` is gated by the `isResumeClaimEnabled` feature flag,
  and the store refetches it when that flag changes.
- `ClaimDetailViewModel` uses `FetchClaimDetailsService` (a logging wrapper around `hFetchClaimDetailsClient`) for
  single-claim details and files. It doesn't go through the store.
- Client protocols: `hFetchClaimsClient`, `hFetchClaimDetailsClient`, `hClaimFileUploadClient`. All Octopus
  implementations are in App, and the demo clients are in this module.

## Entry points
- `ClaimsCard` is embedded in Home. Tapping a claim pushes `ClaimModel` onto the home router, and App's
  `LoggedInNavigation` maps it to `ClaimDetailView` through `.routerDestination(for: ClaimModel.self)`. The deep link
  `claim-details?id=` and the `OPEN_CLAIM` / `CLAIM_CLOSED` push notifications open the same screen.
- `ClaimHistoryScreen` is shown from Profile and gets an `onTap` closure that routes through the caller's router.

## Dependencies
- hCore, hCoreUI, Chat, Payment (declared in `Project.swift` but not imported), CrossSellCore
- Depended on by: App, Home, Profile, SubmitClaimChat

## Gotchas
- `Service/OctopusImplementation/UploadClaimFileClientOctopus.swift` holds `hClaimFileUploadService`, which is only a
  logging wrapper. The real upload client is in App
  (`OctopusClientsImplementation/SubmitClaim/SubmitClaimFileUploadOctopus.swift`).
- `FetchClaimDetailsService` falls back to a partner-claim lookup when a regular claim isn't found, but not on network
  errors. This is covered in `FetchClaimDetailsTests`.
- `ClaimDetailViewModel` polls claim details every 5 seconds to update the chat toolbar. There are no push-based
  updates.
- Cross-module actions go through `NotificationCenter`: `.openChat` from the detail view, `.startClaim` when resuming a
  draft, and `.openCrossSell`. When a claim with `showClaimClosedFlow` is dismissed, App's `LoggedInNavigation` posts
  `.openCrossSell` with `claim.asCrossSellInfo`.
- `ClaimDetailView`, `ClaimFilesViewModel` and `FileGridViewModel` reach into UIKit
  (`getTopViewControllerNavigation()` / `getTopViewController()`) to toggle the nav bar and present alerts.
- ViewModels live in the same file as their views (`ClaimDetailViewModel`, `ClaimFilesViewModel`,
  `FileGridViewModel`).
