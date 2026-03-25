# Payment

Manages payment information display, payment method setup, and connects payment methods (Trustly/Kivra). Displays upcoming/ongoing payments with detailed breakdowns, payment history, and payment status tracking through Trustly or Kivra providers.

## Architecture

Legacy mixed pattern: `PaymentStore` (extends `LoadingStateStore`) manages centralized state alongside several ViewModels (`PaymentsViewModel`, `PaymentsNavigationViewModel`, `ConnectPaymentViewModel`, `PaymentsHistoryViewModel`). Some views still use `PresentableStoreLens` for reactive data binding. Navigation managed through `PaymentsNavigation` which coordinates tab routing and detail views. Payment method setup uses `DirectDebitSetup` view with WebView integration for Trustly flows.

Key services: `hPaymentClient` protocol defines payment data fetching; `hPaymentService` is a wrapper. `PaymentStore` manages states: upcoming/ongoing payments, payment status, and payment history. Data flows: UI -> PresentableStoreLens -> PaymentStore state updates via service calls.

## Key Files

- Entry point: `Sources/Navigation/PaymentNavigation.swift` (tab routing)
- Screens: `Screens/PaymentsView.swift` (main), `Screens/PaymentDetails/PaymentDetailsView.swift` (payment detail), `Screens/PaymentsHistoryView.swift` (history list), `Screens/PaymentsMethodScreen.swift` (payment method display)
- Store: `PaymentStore.swift` (state management)
- Service: `PaymentService.swift` + `PaymentClient.swift` protocol + `PaymentClientDemo.swift`
- Models: `PaymentData.swift`, `PaymentStatusData.swift`, `PaymentHistoryData.swift`
- Connect Payment: `DirectDebitSetup.swift` (WebView wrapper for Trustly), `ConnectPayment+modifier.swift` (view modifier for modal presentation)

## Dependencies

- Imports: hCore, hCoreUI, Campaign (for referral discounts), Contracts, Forever, PresentableStore, Apollo, WebKit (for Trustly setup)
- Imported by: App (main), Home (payment status badge)

## Navigation

- `PaymentsRouterAction` enum: `.discounts` -> Campaign module, `.history` -> PaymentHistoryView, `.paymentMethod(data:)` -> PaymentMethodScreen
- Entry: PaymentsNavigation as tab 3 in LoggedInNavigation
- Connect payment triggered via ConnectPaymentViewModel -> presented as detent modal with DirectDebitSetup

## Gotchas

- **Legacy Store pattern**: Uses `PresentableStore` throughout, not ViewModels
- DirectDebitSetup uses UIViewRepresentable with WKWebView for Trustly/external provider flows; complex Combine-based state synchronization
- ConnectPaymentViewModel held at navigation level to survive view dismissals; SetupType determined at runtime
- Payment status `hasFailed` only returns true for `.addedtoFuture` (outstanding), not for other error states
- Real OctopusImplementation lives in App module (`hPaymentClientOctopus`), not in hGraphQL
- Feature flag check (`isConnectPaymentEnabled`) in DirectDebitSetup prevents flow if not enabled
- Kivra payments show info card with chat button; Trustly shows setup flow
