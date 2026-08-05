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
- **Help Center navigation**: `Navigation/HelpCenterNavigation.swift` -- `HelpCenterNavigationViewModel` plus a thin `hNavigationStack` wrapper; it owns a `QuickActionsViewModel` but no routing logic of its own
- **Quick action routing**: `Navigation/QuickActionsViewModel.swift` -- `QuickActionsViewModel` (`perform(_:)` + six flat presentation flags), the `handleQuickActions(with:redirect:)` modifier holding the detent/modal chain, and `HelpCenterRedirectType`. Mounted twice: by `HelpCenterNavigation` and by `HomeTab` in App
- **Service protocol**: `Service/Protocols/HomeClient.swift` -- `HomeClient`, `MemberState`, `MessageState`
- **Demo service**: `Service/DemoImplementation/HomeClientDemo.swift`
- **Components**: `Screens/Components/MainHomeView.swift`, `ImportantMessagesView.swift`, `RenewalCard.swift`, `FutureSectionView.swift`, `ContactInfoView.swift`, `StakeholderInfoHomeView.swift`, `HomeQuickActionsSection.swift`
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
  - `HelpCenterRedirectType` -- `.travelInsurance`, `.moveFlow`, `.deflect` for flows Home cannot present itself; defined in `Navigation/QuickActionsViewModel.swift` and supplied by whichever host mounts `handleQuickActions` (App resolves all three in one shared `quickActionRedirect(for:)`)
- **Entry from other modules**: Home is a root tab in the main tab bar (configured in App). `HomeNavigationViewModel` listens for `.openChat` and `.openCrossSell` notifications from anywhere in the app.
- **Navigation style**: Help Center sub-navigation uses `hNavigationStack` with a `NavigationRouter` (`HelpCenterNavigation.swift`); the Home toolbar inbox route uses the legacy `RouterHost + Router`. Claim flow is launched via `handleClaimFlow` modifier (from SubmitClaimChat) bound to `claimsAutomationStartInput`.

## Gotchas
- `HomeVM` mirrors `HomeStore.memberContractState` rather than subscribing to the whole store; it triggers the cross-store fetches in `fetchHomeState()` for Home/CrossSell/Contract/Payment stores.
- Chat notification polling uses a 10-second `Timer.publish` that checks the top-visible ViewController description string to decide whether to poll -- a fragile heuristic.
- Quick-action routing is shared, not Help Center's: `QuickActionsViewModel.perform(_:)` can launch termination, change-tier, travel certificate, address change, edit stakeholders, FirstVet, connect payments and the sick-abroad deflection. Six flat `@Published` presentation properties (`editContractActions`, `isTravelCertificatePresented`, `isChangeAddressPresented`, `firstVetPartners`, `sickAbroadData`, `isChangeTierPresented`) drive six separate detent/modal hosts inside the `handleQuickActions` modifier -- one host per property, no grouped presentation enum, matching how `ContractsNavigationViewModel` and `LoggedInNavigation` do it. The ones with a payload (`editContractActions`, `firstVetPartners`, `sickAbroadData`, `isChangeTierPresented`) are optionals that carry it, captured from the `QuickAction` associated value in `perform(_:)` and passed to `detent(item:)`, so no presented screen reads a store for its own data (the terminate-dismiss handler still resolves `HomeStore`/`ContractStore` to refetch, and App's separate toolbar FirstVet host still snapshots the store): `firstVetPartners` in particular uses the `FirstVetPartnersWrapper` box (`Models/QuickAction.swift`, sibling of `EditInsuranceActionsWrapper`) only because `detent(item:)` requires `Identifiable & Equatable` and an array is not Identifiable. Help Center and the Home tab each own a separate `QuickActionsViewModel` instance, so a Home tile never opens the Help Center modal -- and a change to the switch changes both surfaces at once.
- `openHelpCenter` in `HomeScreen` reaches into `ContractStore` directly via `globalAppStateContainer.get()` to check contract state -- a global-state read inside the view layer.
