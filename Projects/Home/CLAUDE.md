# Home

The Home module is the main dashboard of the Hedvig app. It displays the member's contract state (active, future, terminated), important messages, quick actions (e.g. FirstVet, travel insurance), a Help Center with FAQ, and provides the primary entry point for starting a new claim.

## Architecture
- **Pattern**: `HomeStore` is an `@PersistableStore`-backed `AppStore` (`AppStateContainer`) with `@Published` properties for member contract state, contracts, important messages, quick actions, FAQ, and chat-notification state. `HomeScreen` reads it via `@AppObservedObject`; a thin `HomeVM` mirrors `memberContractState` so the screen can switch on it without rebuilding when other store fields change. `HomeBottomScrollView` has its own `HomeBottomScrollViewModel` for composing the bottom-card list.
- **Key services**: `HomeClient` protocol (in `Service/Protocols/HomeClient.swift`) defines all data-fetching methods. `HomeClientDemo` provides the demo implementation. The Octopus (real) implementation lives in `Projects/App/Sources/Service/OctopusClientsImplementation/HomeClientOctopus.swift`.
- **Data flow**: `HomeScreen.onAppear` calls `vm.fetchHomeState()` which kicks off async fetches on `HomeStore`, `CrossSellStore`, `ContractStore`, and `PaymentStore` in parallel. Each store's async method updates its `@Published` properties; views observing those properties re-render automatically. `HomeStore.init()` also subscribes to `CrossSellStore.$hasNewOffer`, `FeatureFlags`, and `.didChargeOutstandingPayment` to keep `toolbarOptionTypes` current.
- **Navigation**: `HomeNavigationViewModel` is the central navigation coordinator, managing chat presentation, claim submission flow, cross-sell modals, and Help Center. `HelpCenterNavigationViewModel` manages the Help Center sub-navigation with its own `Router`.

## Key Files
- **Entry point**: `Screens/HomeScreen.swift` -- `HomeScreen` view and `HomeVM` ViewModel
- **Store**: `HomeStore.swift` -- `HomeStore` (`AppStore`), `MemberInfo`, `FutureStatus`
- **Navigation**: `Navigation/HomeNavigation.swift` -- `HomeNavigationViewModel`, chat/claim/cross-sell orchestration
- **Help Center navigation**: `Navigation/HelpCenterNavigation.swift` -- `HelpCenterNavigationViewModel`, `HelpCenterNavigation` view with quick action routing
- **Service protocol**: `Service/Protocols/HomeClient.swift` -- `HomeClient`, `MemberState`, `MessageState`
- **Demo service**: `Service/DemoImplementation/HomeClientDemo.swift`
- **Components**: `Screens/Components/MainHomeView.swift`, `ImportantMessagesView.swift`, `RenewalCard.swift`, `FutureSectionView.swift`, `ContactInfoView.swift`, `StakeholderInfoHomeView.swift`
- **Help Center views**: `Screens/HelpCenter/HelpCenterStartView.swift`, `HelpCenterTopicView.swift`, `HelpCenterQuestionView.swift`
- **Help Center reusable components**: `Screens/HelpCenter/ReusableComponents/HelpCenterPill.swift`, `HelpCenterQuestion.swift`, `HelpCenterQuickActionView.swift`, `HelpCenterSupportView.swift`, `HelpViewSource.swift`
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
- `HomeVM` mirrors `HomeStore.memberContractState` rather than subscribing to the whole store; it triggers the cross-store fetches in `fetchHomeState()` for Home/CrossSell/Contract/Payment stores.
- Chat notification polling uses a 10-second `Timer.publish` that checks the top-visible ViewController description string to decide whether to poll -- a fragile heuristic.
- The Help Center navigation handler (`HelpCenterNavigation`) is complex, managing quick actions that can launch termination flows, change-tier flows, travel certificates, address changes, edit stakeholders, and more -- all via detents and modals from a single view.
- `openHelpCenter` in `HomeScreen` reaches into `ContractStore` directly via `globalAppStateContainer.get()` to check contract state -- a global-state read inside the view layer.
