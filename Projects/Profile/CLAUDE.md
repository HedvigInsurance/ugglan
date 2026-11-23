# Profile

The Profile tab: personal info editing, settings (language, theme, notifications, email preferences, analytics
consent), EuroBonus/SAS, certificates (travel certificates, insurance evidence), claim history, the information
(app info / legal) screen, dev settings and account deletion.

## Architecture
- `ProfileStore` (`@PersistableStore` `AppStore`) holds `memberDetails`, `partnerData`, `pushNotificationStatus`,
  `hasTravelCertificates`, `canCreateInsuranceEvidence`, … Views observe it with `@AppObservedObject`. Reads
  (`fetchProfileState`, `fetchMemberDetails`, `updateLanguage`) live on the store and use `ProfileClient` directly.
- Writes go through ViewModels (`MyInfoViewModel`, `MemberSubscriptionPreferenceViewModel`, the EuroBonus and
  delete-request screens) using `ProfileService`, a `@Log` wrapper around `ProfileClient`, and then update the store
  via its `set…` methods.

## Entry points
- `ProfileNavigation(profileNavigationViewModel:redirect:)` is the Profile tab root, created by App. Delete account,
  delete-request loading and the language picker are built by App through the
  `redirect: (ProfileRedirectType) -> Content` builder; the rest is presented from `ProfileNavigationViewModel`.

## Dependencies
- hCore, hCoreUI, Home, Claims, ContractsCore, TravelCertificate, Market, AuthenticationCore, AuthenticationUI,
  InsuranceEvidence
- Depended on by: App, Onboarding

## Gotchas
- `ProfileService` sits in `Service/OctopusImplementation/` but is only a logging wrapper; the real GraphQL client is
  App's `ProfileClientOctopus`. Profile doesn't link hGraphQL, so network needs go through `ProfileClient` (e.g.
  `getDeviceIdentifier()` for `InformationScreen`).
- `MyInfoViewModel.save()` refreshes `HomeStore.fetchMemberState()` after saving, to keep Home's member data in sync.
- `ProfileStore.init()` reads the push notification authorization in a `Task`, skipped outside an `.app` bundle
  (hostless unit tests).
- `DeleteAccountViewModel` takes `ClaimsStore` and `ContractStore` to check for active claims/contracts before
  allowing deletion. Delete-request state is persisted with hCore's `DeleteAccountStatus`, not the store.
- Dev Settings can reset `OnboardingPresentationState.hasSeenOnboarding`.
