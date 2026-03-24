# Home

The Home module is the main dashboard of the Hedvig app. It displays the member's contract state (active, future, terminated), important messages, quick actions (e.g. FirstVet, travel insurance), a Help Center with FAQ, and provides the primary entry point for starting a new claim.

## Architecture
- **Mixed pattern**: Uses the legacy `PresentableStore` (`HomeStore: LoadingStateStore<HomeState, HomeAction, HomeLoadingType>`) for state management and data fetching, but the main screen uses a local `HomeVM: ObservableObject` ViewModel that subscribes to the store's state signal via Combine. The `HomeBottomScrollView` also has its own `HomeBottomScrollViewModel`.
- **Key services**: `HomeClient` protocol (in `Service/Protocols/HomeClient.swift`) defines all data-fetching methods. `HomeClientDemo` provides the demo implementation. The Octopus (real) implementation lives in `Projects/hGraphQL/`, not in this module.
- **Data flow**: `HomeScreen` creates `HomeVM`, which reads from `HomeStore`. On appear, `HomeVM.fetchHomeState()` dispatches multiple actions to `HomeStore` (and to `CrossSellStore`, `ContractStore`, `PaymentStore`). The store's `effects()` calls `HomeClient` methods, then dispatches setter actions that are handled in `reduce()`.
- **Navigation**: `HomeNavigationViewModel` is the central navigation coordinator, managing chat presentation, claim submission flow, cross-sell modals, and Help Center. `HelpCenterNavigationViewModel` manages the Help Center sub-navigation with its own `Router`.

## Key Files
- **Entry point**: `Screens/HomeScreen.swift` -- `HomeScreen` view and `HomeVM` ViewModel
- **Store**: `HomeState.swift` -- `HomeState`, `HomeAction`, `HomeStore`, `MemberInfo`, `FutureStatus`
- **Navigation**: `Navigation/HomeNavigation.swift` -- `HomeNavigationViewModel`, chat/claim/cross-sell orchestration
- **Help Center navigation**: `Navigation/HelpCenterNavigation.swift` -- `HelpCenterNavigationViewModel`, `HelpCenterNavigation` view with quick action routing
- **Service protocol**: `Service/Protocols/HomeClient.swift` -- `HomeClient`, `MemberState`, `MessageState`
- **Demo service**: `Service/DemoImplementation/HomeClientDemo.swift`
- **Components**: `Screens/Components/MainHomeView.swift`, `ImportantMessagesView.swift`, `RenewalCard.swift`, `FutureSectionView.swift`, `ContactInfoView.swift`, `StakeholderInfoHomeView.swift`
- **Help Center views**: `Screens/HelpCenter/HelpCenterStartView.swift`, `HelpCenterTopicView.swift`, `HelpCenterQuestionView.swift`
- **Models**: `Models/Contract.swift`, `ImportantMessage.swift`, `QuickAction.swift`, `HelpCenterFAQModel.swift`, `MemberContractState.swift`, `UpcomingRenewal.swift`
- **Derived views**: `Screens/HomeBottomScrollView.swift`, `Screens/CommonClaims/FirstVetView.swift`

## Dependencies
- **Imports**: hCore, hCoreUI, TravelCertificate, TerminateContracts, Payment, Chat, Claims, SubmitClaimChat (via Project.swift). Also imports CrossSell, Contracts, EditStakeholders, ChangeTier at the file level.
- **Depended on by**: Profile (imports Home), App (direct dependency)

## Navigation
- **Routes defined here**:
  - `HomeRouterAction.inbox` -- pushes the Chat `InboxView` within the Home tab
  - `HelpCenterNavigationRouterType.inbox` -- pushes `InboxView` inside the Help Center
  - `HelpCenterRedirectType` -- `.travelInsurance`, `.moveFlow`, `.deflect` for redirecting out of the Help Center
- **Entry from other modules**: Home is a root tab in the main tab bar (configured in App). `HomeNavigationViewModel` listens for `.openChat` and `.openCrossSell` notifications from anywhere in the app.
- **Navigation style**: Uses legacy `RouterHost + Router` for both the Help Center sub-navigation and the Home toolbar inbox route. Claim flow is launched via `handleClaimFlow` modifier (from SubmitClaimChat) bound to `claimsAutomationStartInput`.

## Gotchas
- `HomeVM` is a bridge between the old `PresentableStore` pattern and SwiftUI. It subscribes to `HomeStore.stateSignal` via Combine rather than using `@Inject` services directly. Data fetching is initiated by dispatching actions to multiple stores (`HomeStore`, `CrossSellStore`, `ContractStore`, `PaymentStore`) in `fetchHomeState()`.
- Chat notification polling uses a 10-second `Timer.publish` that checks the top-visible ViewController description string to decide whether to poll -- a fragile heuristic.
- The Help Center navigation handler (`HelpCenterNavigation`) is complex, managing quick actions that can launch termination flows, change-tier flows, travel certificates, address changes, edit co-insured, and more -- all via detents and modals from a single view.
- `openHelpCenter` in `HomeScreen` accesses `ContractStore` directly via `globalPresentableStoreContainer.get()` to check contract state -- mixing global store access into the view layer.
