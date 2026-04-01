# Profile

The Profile module provides the user profile screen with access to personal info editing, app settings (language, notifications, email preferences), EuroBonus/SAS integration, travel certificates, insurance evidence, claim history, app info, and account deletion.

## Architecture
- **Legacy PresentableStore pattern**: Uses `ProfileStore: LoadingStateStore<ProfileState, ProfileAction, ProfileLoadingAction>` as the primary state management. Views read state via `@PresentableStore var store: ProfileStore` and `PresentableStoreLens`. The store dispatches actions and handles async effects (API calls) in `effects()`, then updates state in `reduce()`.
- **Some ViewModels**: Certain sub-screens use the modern ViewModel pattern: `DeleteAccountViewModel` (`@MainActor class: ObservableObject`), `MyInfoViewModel` (uses `ProfileService` directly with `@Inject`), `MemberSubscriptionPreferenceViewModel`. These ViewModels coexist with the store.
- **Key services**:
  - `ProfileClient` -- protocol defining all profile operations (get state, get member details, update language, delete request, update email/phone, update eurobonus, update subscription preference).
  - `ProfileService` -- thin service wrapper that uses `@Inject var client: ProfileClient` and adds logging.
  - `ProfileClientDemo` -- demo implementation.
- **Data flow**: `ProfileView.onAppear` dispatches `.fetchProfileState` to `ProfileStore`. The store's `effects()` calls `profileService.getProfileState()` and then dispatches multiple setter actions. Sub-screens like `MyInfoView` use `ProfileService` directly (bypassing the store for writes) and then dispatch setter actions to update the store.

## Key Files
- **Entry point**: `Views/Screens/Profile/Profile.swift` -- `ProfileView`
- **Store**: `Store/ProfileStore.swift` -- `ProfileStore`
- **State**: `Store/ProfileState.swift` -- `ProfileState`, `PartnerData`, `PartnerDataSas`, `ProfileLoadingState`
- **Actions**: `Store/ProfileAction.swift` -- `ProfileAction`, `ProfileLoadingAction`
- **Navigation**: `Navigation/ProfileNavigation.swift` -- `ProfileNavigationViewModel`, `ProfileNavigation` view, `ProfileRouterType`, `ProfileRouterTypeWithHiddenBottomBar`, `ProfileRedirectType`, `ProfileDetentType`
- **Service protocol**: `Service/Protocols/ProfileClient.swift` -- `ProfileClient`, `ProfileError`, `ChangeEuroBonusError`
- **Service implementation (local)**: `Service/OctopusImplementation/ProfileService.swift` -- `ProfileService`
- **Demo implementation**: `Service/DemoImplementation/ProfileClientDemo.swift`
- **Models**: `Models/MemberDetails.swift`
- **My Info**: `Views/Screens/MyInfo/MyInfoView.swift` -- `MyInfoView`, `MyInfoViewModel`
- **My Info errors**: `Views/Screens/MyInfo/MyInfoSaveError.swift`
- **Settings**: `Views/Screens/SettingsScreen/SettingsView.swift`, `MemberSubscriptionPreferenceView.swift`
- **Delete account**: `Views/Screens/DeleteAccount/DeleteAccountView.swift`, `DeleteAccountViewModel.swift`, `DeleteRequestLoadingView.swift`
- **EuroBonus**: `Views/Screens/EuroBonus/EuroBonusView.swift`, `ChangeEuroBonusView.swift`, `EuroBonusNavigation.swift`
- **Certificates**: `Views/Screens/Certificates/CertificatesScreen.swift`
- **Email preferences**: `Views/Screens/EmailPreferences/EmailPreferencesConfirmView.swift`
- **App info**: `Views/Screens/AppInfo/AppInfoView.swift`
- **Components**: `Views/Components/NotificationsCardView.swift`, `ProfileRow.swift`, `ProfileRowType.swift`

## Dependencies
- **Imports**: hCore, hCoreUI, Home, Claims, Contracts, TravelCertificate, Market, Authentication, InsuranceEvidence (via Project.swift). Also uses Apollo, PresentableStore at the file level.
- **Depended on by**: App (direct dependency). No other feature modules import Profile.

## Navigation
- **Routes defined here**:
  - `ProfileRouterType`: `.myInfo`, `.appInfo`, `.settings`, `.euroBonus`, `.certificates`, `.claimHistory`, `.travelCertificates`
  - `ProfileRouterTypeWithHiddenBottomBar`: `.claimsCard(claim:)` -- pushes claim detail with bottom bar hidden
  - `ProfileRedirectType`: `.deleteAccount`, `.deleteRequestLoading`, `.pickLanguage`, `.travelCertificate` -- for modals/detents managed by the parent
  - `ProfileDetentType`: `.profile`, `.languagePicker`, `.emailPreferences` -- for tracking
- **Entry from other modules**: Profile is a root tab in the main tab bar (configured in App). `ProfileNavigation` is the top-level navigation container.
- **Navigation style**: Uses legacy `RouterHost + Router` pattern. `ProfileNavigationViewModel` owns `profileRouter` and manages modal/detent presentations for delete account, language picker, insurance evidence, and delete request flows.

## Gotchas
- **Wrongly-placed OctopusImplementation**: The `Service/OctopusImplementation/ProfileService.swift` file contains a local `ProfileService` class that wraps `ProfileClient` with logging. Per project conventions, Octopus implementations should live in `Projects/hGraphQL/GraphQL/Octopus/`, not inside the feature module. This `ProfileService` is actually a service-layer wrapper (not a true Octopus implementation), making the directory name misleading.
- The module uses the legacy `PresentableStore` pattern throughout. `ProfileView` uses `@PresentableStore` and `PresentableStoreLens` to read state reactively, unlike newer modules that use `@StateObject` ViewModels.
- `MyInfoViewModel` uses `ProfileService` directly (not through the store) for the update operation, then manually dispatches setter actions to `ProfileStore` and `HomeStore` to sync state. This creates a split write path.
- `ProfileState.init()` launches a `Task` to check push notification settings and dispatches an action to the store from within the state initializer -- an unusual side effect in a state struct.
- `DeleteAccountViewModel` reads from `ClaimsStore` and `ContractStore` (from other modules) to determine if the user has active claims/contracts before allowing deletion.
- The `ProfileView` accesses `ApolloClient.deleteAccountStatus` and `ApolloClient.saveDeleteAccountStatus` directly for persisting delete request state, bypassing the store pattern.
