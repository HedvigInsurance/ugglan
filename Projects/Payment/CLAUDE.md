# Payment

Manages payment information display, payin method setup (Trustly/Kivra/Adyen), payout method setup (Nordea/Swish), payment history, overdue/missed payment recovery, and payment status. Displays upcoming/ongoing payments with detailed breakdowns and routes users to fix payment issues.

## Architecture

`PaymentStore` is an `AppStateContainer`-backed `AppStore`; per-flow ViewModels handle setup screens.

- `PaymentStore` is `@MainActor @PersistableStore final class PaymentStore: AppStore`. `@Published` properties: `paymentData`, `ongoingPaymentData`, `paymentStatusData` (payin + payout methods + available providers), `paymentHistory`, `missedPaymentData`. `@Transient @Published` flags expose per-fetch loading and error state. Async methods: `load()`, `fetchPaymentStatus()`, `getHistory()`, `getMissedPayment()`. Views observe via `@AppObservedObject`.
- Per-flow ViewModels: `PaymentsNavigationViewModel`, `ConnectPaymentViewModel`, `NordeaPayoutSetupViewModel`, `SwishPayoutSetupViewModel`, `PaymentOverdueScreenViewModel`, `PaymentsViewModel`, `PaymentsHistoryViewModel`. The list/history VMs derive `viewState` from the store's `isFetchingX`/`fetchXError` publishers; setup VMs (Nordea/Swish/Trustly) call `hPaymentClient` directly and trigger `store.fetchPaymentStatus()` on success.
- `hPaymentClient` protocol exposes: `getPaymentData`, `getPaymentStatusData`, `getPaymentHistoryData`, `getMissedPaymentData`, `setupPaymentMethod(_:)`, `chargeOutstandingPayment()`. Octopus implementation lives in `Projects/App/Sources/Service/OctopusClientsImplementation/` (per project convention). Demo implementation is `hPaymentClientDemo` in this module.
- Setup providers are modeled by `PaymentProvider` (Trustly, Adyen, Kivra for payin; Nordea, Swish for payout). Each provider decides its own detent presentation style and the screen to show.

## Key Files

### Navigation
- `Sources/Navigation/PaymentNavigation.swift` — `PaymentsNavigation` (uses `hNavigationStack` + `NavigationRouter`), `PaymentsNavigationViewModel`, `PaymentsRouterAction` (`.discounts`, `.history`, `.paymentMethod`, `.payoutMethod`). Route destinations include `PaymentData`, `MissedPaymentData`, and `PayoutRouterActions`.
- `Sources/Navigation/PayoutNavigation.swift` — Standalone `PayoutNavigation` for entering the payout-method flow from outside Payments tab. Routes `.selectedPayoutMethod` and `.changePayoutMethod`.

### Main screens
- `Sources/Screens/PaymentsView.swift` — Main payments tab; shows upcoming/ongoing payments, overdue card, payin/payout sections.
- `Sources/Screens/PaymentDetails/PaymentDetailsView.swift` — Single-payment detail with breakdown.
- `Sources/Screens/PaymentDetails/PaymentDetailsContractDetails.swift` — Per-contract breakdown rows inside the detail.
- `Sources/Screens/PaymentDetails/PaymentStatusView.swift` — Status badge/banner reused on detail screens.
- `Sources/Screens/PaymentsHistoryView.swift` — Closed payments list. Contains `PaymentsHistoryViewModel`.
- `Sources/Screens/PaymentsMethodScreen.swift` — Payin method management; lists current method and provider options.

### Connect Payin (payment method setup)
- `Sources/Screens/ConnectPayments/ConnectPayment+modifier.swift` — `.handleConnectPayment(with:)` modifier that presents the connect-payment detent based on `ConnectPaymentViewModel`.
- `Sources/Screens/ConnectPayments/ConnectPaymentCard.swift` — Card content shown inside the connect-payment detent.
- `Sources/Screens/ConnectPayments/ConnectPaymentBottomView.swift` — Bottom button content for the connect-payment sheet.
- `Sources/Screens/ConnectPayments/DirectDebitSetup.swift` — `UIViewRepresentable` wrapping `WKWebView` for Trustly/Adyen flows.
- `Sources/Screens/ConnectPayments/TrustlyScriptHandler.swift` — Bridges Trustly JS messages back to Swift.
- `Sources/Screens/ConnectPayments/DirectDebitResult.swift` — Result/feedback view after a setup attempt.

### Payout (Nordea / Swish)
- `Sources/Screens/Payout/PayoutSelectedMethodScreen.swift` — Entry view: shows existing payout method, or routes to add-method if missing.
- `Sources/Screens/Payout/PayoutChangeMethodScreen.swift` — Lists available payout providers (filtered via `availablePayoutMethods`) and opens the provider-specific setup detent.
- `Sources/Screens/Payout/NordeaPayoutSetupScreen.swift` — Account-number entry form for Nordea (uses `NordeaPayoutSetupViewModel`).
- `Sources/Screens/Payout/SwishPayoutSetupScreen.swift` — Phone-number entry form for Swish (uses `SwishPayoutSetupViewModel`).

### Overdue / missed payment
- `Sources/Models/MissedPaymentData.swift` — `MissedPaymentData` model (paymentData + paymentMethodData). Conforms to `TrackingViewNameProtocol`.
- `Sources/Screens/MissedPaymentScreen.swift` — Full-screen flow for reviewing and clearing an overdue payment. Contains `.handleMissedPayment(data:)` View extension that presents it as a detent.
- `Sources/Screens/PaymentOverdueCardView.swift` — `MissedPaymentCardView` shown inline on the home/payments screen when a missed payment exists.

### Store / models / service
- `Sources/PaymentStore.swift` — `PaymentState`, `PaymentAction`, `LoadingAction`, `PaymentStore`.
- `Sources/Models/PaymentData.swift`, `PaymentStatusData.swift`, `PaymentHistoryData.swift` — Core data models; `PaymentStatusData` exposes payin/payout method lists and computed defaults.
- `Sources/Helpers/PaymentData+titleView.swift` — Display helpers.
- `Sources/Service/Protocols/PaymentClient.swift` — `hPaymentClient` protocol + `PaymentError`.
- `Sources/Service/Protocols/PaymentClientDemo.swift` — Demo client (note: lives directly under `Protocols/`, not in `DemoImplementation/`).
- `Sources/Service/PaymentService.swift` — Service wrapper.

## Dependencies

- Imports: hCore, hCoreUI, AppStateContainer, Campaign (referral discounts), Contracts, Forever, Apollo, WebKit (for Trustly setup webview).
- Project-level dependencies declared in `Project.swift`: hCore, hCoreUI, Contracts, Forever, Campaign.
- Depended on by: App (main), Home (overdue card, payment status badge).

## Navigation

- `PaymentsNavigation` uses `hNavigationStack + NavigationRouter` (new style). `RouterHost + Router` is no longer used here.
- `PaymentsRouterAction`: `.discounts` → CampaignNavigation, `.history` → `PaymentHistoryView`, `.paymentMethod` → `PaymentMethodScreen`, `.payoutMethod` → `PayoutSelectedMethodScreen`.
- `PayoutRouterActions`: `.selectedPayoutMethod` → `PayoutSelectedMethodScreen`, `.changePayoutMethod` → `PayoutChangeMethodScreen`.
- `PayoutNavigation` is a standalone `hNavigationStack` that wraps the payout flow when entered from outside the payments tab.
- Connect payin is triggered by setting state on `ConnectPaymentViewModel`; the `.handleConnectPayment(with:)` modifier presents the appropriate detent. Provider-specific setup (Nordea/Swish/Trustly/etc.) is shown as a detent whose style/options come from `PaymentProvider`.
- Missed payment is presented via `.handleMissedPayment(data:)` as a large detent embedding its own navigation stack.

## Gotchas

- **`PaymentStore` is the source of truth.** Setup screens (Nordea/Swish/Trustly) maintain their own local state and trigger `store.fetchPaymentStatus()` on success via `globalAppStateContainer.get()`.
- **Demo client path is non-standard**: `PaymentClientDemo.swift` is in `Service/Protocols/` instead of `Service/DemoImplementation/`. Other modules put demo clients under `DemoImplementation/`.
- **`DirectDebitSetup`** is a UIKit `UIViewRepresentable` wrapping `WKWebView`; uses `TrustlyScriptHandler` for JS↔Swift bridging and Combine-based state synchronization. Feature flag `isConnectPaymentEnabled` short-circuits the flow when disabled.
- **`ConnectPaymentViewModel`** is held at navigation level so it survives view dismissals; `SetupType` is determined at runtime based on `PaymentProvider`.
- **`PayinMethodStatus.hasFailed`** only returns true for `.addedtoFuture` (outstanding charge), not for arbitrary error states.
- **Overdue charge action**: `hPaymentClient.chargeOutstandingPayment()` is the API used by `MissedPaymentScreen` to trigger a re-charge; success bubbles back through the screen's `onSuccess` closure, popping back to the payments root.
- Kivra payments show an info card with a chat button instead of a setup flow; Trustly/Adyen open the webview flow.
