# Home

The main dashboard. It shows the member's contract state (active, future, terminated), important messages, quick
action tiles, ongoing web-shop quotes, cross-sells and addons, active claims, and the Help Center (FAQ, quick actions,
Puppy Guide). It's also the main entry point for starting a claim.

## Architecture
- `HomeStore` is a `@PersistableStore` `AppStore` holding member state, contracts, important messages, quick actions,
  FAQ, ongoing quotes, chat-notification state and `toolbarOptionTypes`. `HomeScreen` renders `ActiveHomeView` for
  every member state.
- `HomeVM` has no state of its own. `fetchHomeState()` starts every fetch (Home, CrossSell, Contract, Payment and
  Claims stores) and owns two polling timers: chat notifications every 10 seconds and claims every 120 seconds. Both
  only run while `VisibleScreenTracker` reports `HomeScreen` as visible. Store initializers only subscribe and never
  fetch.
- `HomeStore.init()` refreshes the toolbar when `CrossSellStore.hasNewOffer` changes, and refetches ongoing quotes when
  their feature flag changes. `homeQuickActions` (the Home tiles, their eligibility and their order) is a computed
  property built from `quickActions` and `PaymentStore.paymentData`.
- `HomeNavigationViewModel` coordinates chat, claim start (`claimsAutomationStartInput`), cross-sell, Forever and
  upcoming-payment presentation. It listens for `.openChat` and `.openCrossSell` notifications posted from anywhere in
  the app. `HelpCenterNavigation` has its own router.
- Client protocols: `HomeClient` and `PuppyGuideClient`. Octopus implementations are in App, demo clients are here.

## Entry points
- App's `HomeTab` (`LoggedInNavigation.swift`) hosts the Home stack and maps `HomeRouterAction.inbox` to Chat's
  `InboxView`. It also hosts the Forever and upcoming-payment detents and the `handleClaimFlow` modifier from
  SubmitClaimChat.
- `HelpCenterRedirectType` (`.travelInsurance`, `.moveFlow`, `.deflect`) covers flows Home can't present itself.
  Whoever mounts `handleQuickActions` supplies them (App resolves all three in `quickActionRedirect(for:)`).

## Dependencies
- hCore, hCoreUI, AddonsCore, TravelCertificate (declared but not imported),
  TerminateContractsCore/UI, Payment, Chat, Claims, SubmitClaimChat,
  CrossSellCore/UI, EditStakeholdersCore/UI, ChangeTierCore/UI, ContractsCore/UI
- Depended on by: App, Profile

## Gotchas
- Member state, important messages and quick actions all come from one `Home` query. `HomeStore.fetchHomeData()` loads
  all three in one request, while `fetchMemberState()`, `fetchQuickActions()` and `fetchImportantMessages()` send the
  same query and keep only their part. Chat state and ongoing quotes are separate queries. A failed `fetchHomeData()`
  sets both `fetchMemberStateError` and `fetchQuickActionsError`.
- The `HomeStore` snapshot decodes all-or-nothing. Removing a persisted property or adding an `Optional` one is safe,
  but a new non-Optional property or a changed type wipes every member's restored `HomeStore`. Mark derived or
  short-lived state `@Transient`. `quickActions` stays persisted because `toolbarOptionTypes` reads
  `quickActions.hasFirstVet`.
- Toolbar: the Home toolbar buttons are a floating overlay in `ActiveHomeView`, and the real navigation bar is hidden.
  The exception is a system toolbar down the side of the screen (iPhone Duo). There, `isSystemToolbarOnSide` (from
  hCoreUI's `.onSystemToolbarEdgeChange`) swaps the overlay for real bar items through `setHomeNavigationBars`, which
  also publishes `\.tooltipDirection`.
  - When folded (compact vertical size class), `collapsesIntoMenu` puts every option behind one hand-built `Menu`. The
    system overflow menu can't show `ToolbarButtonView`'s custom content. Don't turn the button content into a `Label`
    to work around that: the bar would draw its own button, which drops the tooltip and repaints the icon.
  - Only `ActiveHomeView` may set the Home bar's visibility. `HomeTab` uses `.ignoreNavigationBarVisibility`, and any
    `.toolbar(_, for: .navigationBar)` applied outside, even `.automatic`, swallows the switch on iOS 27.
- Quick actions: `QuickActionsViewModel.perform(_:)` is shared. Help Center and the Home tab each own an instance, so
  changing the switch changes both screens.
  - Each of its six presentation properties drives its own detent or modal host inside `handleQuickActions`. There's
    no grouped presentation enum.
  - Payload-carrying properties pass their data through `detent(item:)`, so presented screens don't read stores for it.
    `FirstVetPartnersWrapper` and `EditInsuranceActionsWrapper` exist only because `detent(item:)` needs
    `Identifiable & Equatable`.
- `.upgradeCoverage` only ever arrives inside `.editInsurance(actions:)`, never at the top level.
- The Home "Edit insurance" tile hides cancellation when `isCancelInsuranceHiddenFromHomeScreen` is on (Unleash
  `hide_cancel_insurance_from_home_screen`, not inverted). The filter lives in `homeQuickActions` because Help Center
  reads the same `quickActions` and must keep offering cancellation. If cancellation was the only action, the tile is
  dropped.
- Invite a friend and Upcoming payment are Home detents (`isForeverPresented` / `isUpcomingPaymentPresented`), not
  quick actions. `presentUpcomingPayment()` force-refetches and shows a toast on error or when nothing is due.
- Ongoing quotes (unfinished web-shop sessions):
  - `fetchOngoingQuotes()` checks `isResumingOngoingShopSessionsEnabled` (inverted Unleash kill switch
    `disable_resuming_ongoing_shop_sessions`, matching Android). The flag check is in the store, so the section hides
    itself when the flag is off.
  - `ongoingQuotes` is `@Transient`, and the backend already excludes signed and expired sessions. A card resumes by
    opening `resumeUrl`, which needs no auth, through `Dependencies.urlOpener`.
- Dismissing an ongoing quote: `DismissedOngoingQuotesTracker` stores the dismissed IDs in `UserDefaults`, keyed by
  member ID, so they survive logout wiping `AppStateContainer`.
  - The IDs are deliberately never pruned. `fetchOngoingQuotes()` turns network errors into `[]`, so pruning against
    the fetched list would be unsafe.
