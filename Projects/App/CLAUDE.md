# App

Main application entry point for the Hedvig iOS app. Manages root navigation (logged-in vs logged-out), dependency injection for all feature modules, deep link routing, push notification handling, and Datadog analytics/tracking setup.

## Architecture
- Pattern: Mixed. The root `MainNavigation` uses a SwiftUI `App` with `MainNavigationViewModel` (ObservableObject). Sub-components use `@Inject` for services and `@PresentableStore` for accessing legacy stores. The app-level `UgglanStore` is a legacy `StateStore<UgglanState, UgglanAction>` used solely for demo mode state.
- Key services: `AnalyticsClient` (analytics/user tracking), `NotificationClient` (push token registration). Both have protocol, OctopusImplementation, and DemoImplementation within this module.
- Data flow: `AppDelegate` performs initial setup (session, Apollo client, Datadog, feature flags). `MainNavigationViewModel` observes `ApplicationState` to switch between logged-in, logged-out, and impersonation states. `LoggedInNavigationViewModel` manages tab selection and all modal presentation state. `DI.initAndRegisterClient()` registers all service implementations (demo or Octopus) into the global `Dependencies` container.

## Key Files
- `Sources/Navigation/MainNavigation.swift` — `@main` App struct and root `MainNavigationViewModel`. Controls launch screen, OS/update checks, and routes to `LoggedInNavigation` or `LoginNavigation`.
- `Sources/Navigation/LoggedInNavigation.swift` — TabView with 5 tabs (Home, Contracts, Forever, Payments, Profile). Contains `LoggedInNavigationViewModel`, `PushNotificationHandler`, and `DeepLinkHandler`.
- `Sources/Navigation/LoggedInNavigation+Presentations.swift` — ViewModifier managing modals for travel insurance, moving flow, change tier, addons, termination, EuroBonus, FAQ, and insurance evidence.
- `Sources/Navigation/LoginNavigation.swift` — Pre-auth flow using `RouterHost` (legacy navigation).
- `Sources/AppDelegate.swift` — UIApplicationDelegate handling lifecycle, logout, URL handling, session setup, Datadog logger init.
- `Sources/AppDelegate+DI.swift` — `DI` enum with `initServices()`, `initAndRegisterClient()` (registers all service implementations for every module), and `initNetworkClients()`.
- `Sources/AppDelegate+Notifications.swift` — Push notification registration, `UNUserNotificationCenterDelegate`, `PushNotificationType` enum.
- `Sources/AppDelegate+Tracking.swift` — Datadog RUM, Trace, Logs, and CrashReporting setup.
- `Sources/UgglanStore.swift` — Minimal `StateStore` holding `isDemoMode` flag.
- `Sources/Service/OctopusClientsImplementation/` — Octopus GraphQL implementations for most feature module service protocols.
- `Sources/Service/AnalyticsCoordinator/` — AnalyticsClient protocol + Octopus/Demo implementations.
- `Sources/Service/Notifications/` — NotificationClient protocol + Octopus/Demo implementations.

## Dependencies
- Imports: hCore, hCoreUI, hGraphQL, Contracts, Claims, Home, Payment, Forever, Chat, SubmitClaimChat, Profile, Authentication, Market, MoveFlow, TerminateContracts, TravelCertificate, EditStakeholders, ChangeTier, Addons, CrossSell, Campaign, CoreDependencies, AppDependencies, ResourceBundledDependencies.
- No other module depends on App; it is the top-level target. Two app targets exist: `Ugglan` (staging) and `Hedvig` (production).

## Navigation
- `MainNavigation` (root): Switches between `LoginNavigation`, `LoggedInNavigation`, and `ImpersonationSettings`.
- `LoggedInNavigation`: SwiftUI `TabView` with tabs at indices 0 (Home), 1 (Contracts), 2 (Forever), 3 (Payments), 4 (Profile). Tabs 2 and 3 are conditionally hidden based on contract type and feature flags.
- Deep links handled by `DeepLinkHandler` — supports routes like `/forever`, `/direct-debit`, `/profile`, `/insurances`, `/home`, `/payments`, `/contract?id=`, `/terminate-contract?id=`, `/change-tier?id=`, `/help-center`, `/submit-claim`, `/claim-details?id=`, and more.
- Push notifications handled by `PushNotificationHandler` — routes `NEW_MESSAGE`, `REFERRAL_SUCCESS`, `CONNECT_DIRECT_DEBIT`, `PAYMENT_FAILED`, `CROSS_SELL`, `CHANGE_TIER`, `ADDON_TRAVEL`, `ADDON_CAR_PLUS`, `OPEN_CLAIM`, `CLAIM_CLOSED`, `INSURANCE_EVIDENCE`, `TRAVEL_CERTIFICATE`, etc.
- Login flow uses legacy `RouterHost + Router` pattern.
- Logged-in tab contents use their respective module navigation components.

## Gotchas
- **Misplaced OctopusImplementation**: `Sources/Service/OctopusClientsImplementation/` contains Octopus implementations for nearly all feature modules (contracts, claims, payments, profile, forever, chat, etc.). Per project convention, these should live in `Projects/hGraphQL/GraphQL/Octopus/`, not in the App module.
- **Misplaced AnalyticsClient and NotificationClient OctopusImplementation**: `Sources/Service/AnalyticsCoordinator/OctopusImplementation/` and `Sources/Service/Notifications/OctopusImplementation/` also live locally rather than in hGraphQL.
- `DI.initAndRegisterClient()` has duplicated registration blocks for staging vs production that are nearly identical, making maintenance error-prone.
- `LoggedInNavigation.swift` is very large (900+ lines) and handles push notifications, deep links, tab management, and modal presentation all in one file.
- The `LoginNavigation` uses legacy `RouterHost + Router` while `LoggedInNavigation` uses SwiftUI `TabView`. Both navigation patterns coexist.
- `ApplicationState` uses `@AppStorage` with a string key, and state transitions happen through a property observer (`didSet`) rather than a dedicated state machine.
