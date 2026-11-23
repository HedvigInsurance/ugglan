# App

Main application target. Owns root navigation (logged-in vs logged-out), dependency injection for every feature
module, deep link and push notification routing, the Octopus (GraphQL) client implementations, and Datadog setup.
Two app targets: `Ugglan` (staging) and `Hedvig` (production), each with its own NotificationService extension.

## Architecture
- `AppDelegate` does initial setup (session, Apollo client, Datadog, Unleash feature flags).
  `DI.initAndRegisterClient()` (`AppDelegate+DI.swift`) registers every client implementation into `Dependencies` —
  demo clients when `UgglanStore.isDemoMode` is set, otherwise Octopus clients per environment (staging vs
  production/custom).
- `MainNavigation` (`@main`) + `MainNavigationViewModel` switch between `LoginNavigation`, `LoggedInNavigation` and
  `ImpersonationSettings` based on `ApplicationState` (`@AppStorage`). Logging in triggers initial fetches (contracts,
  member details, …) from the `state` `didSet`.
- `LoggedInNavigation` is a SwiftUI `TabView` (0 Home, 1 Insurances, 2 Forever, 3 Payments, 4 Profile; Forever and
  Payments are hidden depending on contracts and feature flags). `LoggedInNavigationViewModel` holds tab selection and
  presentation state; the cross-feature modals (travel certificate, move, change tier, addons, termination,
  co-insured, pet chip ids, onboarding, …) are attached in `LoggedInNavigation+Presentations.swift`.
- `UgglanStore` is a minimal persisted `AppStore` holding only `isDemoMode`.

## Octopus implementations
- `Sources/Service/OctopusClientsImplementation/` is the canonical home for the GraphQL-backed implementations of
  feature-module client protocols (`<Feature>ClientOctopus`). Protocols and demo clients live in the feature modules.
- App-local services (`AnalyticsCoordinator/`, `Notifications/`, `EventTracking/`) keep protocol + Octopus/Demo
  implementations side by side inside App.

## Entry points
- `DeepLinkHandler` (in `LoggedInNavigation.swift`) routes the `DeepLink` cases defined in hCore
  (`hCore/Sources/DeepLink.swift`) — add new deep links there first.
- `PushNotificationHandler` (same file) routes `PushNotificationType` (`AppDelegate+Notifications.swift`), e.g.
  `NEW_MESSAGE`, `PAYMENT_FAILED`, `CHANGE_TIER`, `ADDON_TRAVEL`, `OPEN_CLAIM`, `INSURANCE_EVIDENCE`, `PAYOUT`.

## Dependencies
- Every feature module (Core and UI targets), hCore, hCoreUI, hGraphQL, CoreDependencies, AppDependencies.
- Nothing depends on App. It is the only module that links hGraphQL.

## Gotchas
- `DI.initAndRegisterClient()` has near-identical staging and production registration blocks — when registering a
  new client, add it to the demo block and both environment blocks.
- `LoggedInNavigation.swift` is very large (1300+ lines): tabs, push handling and deep link handling all live there.
- `ApplicationState` transitions happen through a property observer (`didSet`), not a dedicated state machine.
