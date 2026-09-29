# Payment

Payments tab and everything around a member's payment methods: pay-in setup and management (Trustly, Swish, Kivra/invoice), payout setup (Nordea, Swish, Trustly), upcoming/ongoing payments with breakdowns, payment history, and overdue-payment recovery. Also exposes the pay-in entry points Home and Onboarding present.

## Architecture

`PaymentStore` is the single source of truth; screens observe it with `@AppObservedObject` and small per-flow ViewModels own one mutation each.

- `PaymentStore` — `@MainActor @PersistableStore final class PaymentStore: AppStore`. `@Published`: `paymentData`, `ongoingPaymentData`, `paymentStatusData`, `paymentHistory`, `missedPaymentData`, `paymentDataFetchedAt`; `@Transient @Published` per-fetch loading/error flags. Async: `load(forceUpdate:)`, `fetchPaymentStatus()`, `getHistory()`, `getMissedPayment()`. Layout flags (`showsPayinSection`, `showsConnectPayment`, `showsConnectPayout`, `showsPayoutSection`, …) combine `paymentStatusData.layout` with the connected methods. `PaymentStore.refreshStatusDetached()` is how sheet completions refresh — detached so it outlives the sheet's teardown.
- ViewModels — `PaymentActionViewModel` (`Helpers/`) is the base for one-shot mutations: `processingState`, `isLoading`, `errorMessage`, `perform(_:) -> Bool`. Subclasses: `PaymentsConfirmDefaultViewModel`, `PaymentRemoveMethodViewModel`. Standalone: `SwishPayinSetupViewModel` (phone entry + `setupPaymentMethod(.swishPayin)`), `SwishPayinConsentViewModel` (QR code + polling), `NordeaPayoutSetupViewModel`, `SwishPayoutSetupViewModel`, `PaymentOverdueScreenViewModel`, `PaymentsViewModel`, `PaymentsHistoryViewModel`. `PaymentsNavigationViewModel` holds `paymentsRouter` plus the `showAddPaymentMethod` / `showChooseDefaultPaymentMethod` sheet flags.
- Service — `hPaymentClient`: `getPaymentData`, `getPaymentStatusData`, `getPaymentHistoryData`, `getMissedPaymentData`, `setupPaymentMethod(_:)`, `getPaymentSetupStatus(orderId:)`, `chargeOutstandingPayment()`, `setDefaultPaymentMethod(_:)`, `removePaymentMethod(_:)`. `hPaymentService` wraps it with `@Log`. Octopus implementation is in `Projects/App/Sources/Service/OctopusClientsImplementation/PaymentsClientOctopus.swift` (`PaymentMethodsQuery(version: 2)`); demo is `hPaymentClientDemo` here.
- Models — `PaymentStatusData` (`payinMethods`, `payoutMethods`, `availableMethods`, `missingConnection`, `layout`, `memberPhoneNumber`; computed `availablePayin/PayoutMethods`, `defaultOrFirstDefaultPayin/PayoutMethod`, `activePayinMethods`, `selectablePayinMethods`, `canChooseDefaultPayinMethod`, `payinMethod(for:)`). `ConnectedPaymentMethod` = `status` + `isDefault` + `method: PaymentMethod` (`.trustly(bankAccount)`, `.nordea(bankAccount)`, `.swish(phoneNumber)`, `.invoice(delivery)`, `.unknown`); `provider: PaymentProvider` is derived from the case. `AvailablePaymentMethod` (provider + supportsPayin/Payout), `PaymentDirection` (`.payin`/`.payout`), `PaymentMethodSetupType`, `PaymentSetupResult` (status, `orderId`, url, errorMessage), `PaymentLayout` (`.qasaOnly`/`.other`).
- Display copy and presentation live on `PaymentProvider` extensions: `Models/PaymentProvider+UI.swift` (`payinTitle/Subtitle`, `payoutTitle/Subtitle`, `title(for:)`, `image(size:)`, `chooseDefaultImage(size:)`, info texts) and `Navigation/PaymentProvider+Presentation.swift` (`payin/payoutSetupPresentationStyle/Options`). `Models/ConnectedPaymentMethod+UI.swift` gives a connected method its `title`, `subtitle`, `info` and `item: ItemModel`.

## Key Files

### Navigation and entry points
- `Sources/Navigation/PaymentNavigation.swift` — `PaymentsNavigation` (`hNavigationStack` + `NavigationRouter`), `PaymentsNavigationViewModel`, `PaymentsRouterAction` (`.discounts`, `.history`, `.paymentMethod(provider:)`, `.paymentMethods`), shared `paymentsDestination(for:)`, and `.withPaymentsPresentations(_:)` (environment object + choose-default and add-method sheets).
- `Sources/Navigation/PayoutNavigation.swift` — standalone payout stack; `PayoutRouterActions.selectedPayoutMethod` is the only route (the picker is a sheet).
- Public presentation modifiers, all detents: `.handleAddPaymentMethod(presented:)` (`Payin/PaymentAddPaymentMethod+modifier.swift`), `.handlePaymentMethods(presented:)` (`Payin/PaymentMethods+modifier.swift`, wraps the list in its own stack), `.handleSwishPayinSetup(presented:)` / `.handleDirectDebitSetup(presented:)` (`Payin/PaymentSetup+modifier.swift`, deep-link entries that open the provider's setup directly), `.handleMissedPayment(data:)`. Internal: `.handlePaymentSetup(for:phoneNumber:onSuccess:)` opens the provider's setup screen, `.handleChangePayoutMethod(presented:)` the payout picker.

### Pay-in (`Sources/Screens/Payin/`)
- `PaymentMethodsScreen.swift` — connected pay-in methods; empty state offers to add one; "choose primary" only with 2+ active methods.
- `PaymentMethodScreen.swift` — one provider's method: info rows, change (Trustly/Swish) and remove; the default method can't be removed (InfoView instead).
- `PaymentAddPaymentMethod.swift` — `public`. Picker of `availablePayinMethods` → provider setup → confirmation. Standalone in a detent, or hosted by a flow with a `Heading`, prefilled `phoneNumber`, `connectedProvider` and `onFinished` (Onboarding).
- `PaymentsChooseDefaultScreen.swift` / `PaymentsConfirmDefaultScreen.swift` — pick and confirm the primary method (`setDefaultPaymentMethod`).
- `PaymentRemoveMethodScreen.swift` — confirmation sheet for `removePaymentMethod`.
- `SwishPayinSetupScreen.swift` — own `NavigationRouter`; phone entry, then `SwishPayinRoute.consent`. `SwishPayinConsentScreen.swift` — QR code for the Swish URL, "Open Swish" when installed, polls `getPaymentSetupStatus(orderId:)` every 2 s for up to 120 s, retry on failure. `SwishExplanationScreen.swift` — the "how recurring Swish works" sheet.

### Payout (`Sources/Screens/Payout/`)
- `PayoutSelectedMethodScreen.swift` — existing payout method (locked row) or the missing-payout/missing-payin states. `PayoutChangeMethodScreen.swift` — the shared picker with `direction: .payout`, then the provider setup detent. `NordeaPayoutSetupScreen.swift`, `SwishPayoutSetupScreen.swift` — entry forms.

### Cards, shared views (`Sources/Viewables/`, `Sources/Screens/ConnectPayments/`)
- `PaymentMethodRow.swift` — the one row for a method: chevron/plain, selectable radio, or locked; inits for `ConnectedPaymentMethod` and for `PaymentProvider` + `PaymentDirection`.
- `PaymentMethodPickerList.swift` — radio list of available providers + connect/cancel buttons. `PaymentConnectionGraphics.swift` — `paymentMethodTile()`, `PaymentMethodPickerGraphic`, `PaymentConnectionPairGraphic`, `StatusBadge`, `SwishPillow`. `PaymentErrorLabel.swift`, `PaymentMethodInfoView.swift`.
- `ConnectPaymentCard.swift` — `ConnectPaymentCardView(onConnectPayment:)`, the needs-setup / overdue card shown on Home and the payments tab. `ConnectPayoutCard.swift`. `DirectDebitSetup.swift` (+ `TrustlyScriptHandler`, `DirectDebitResult`) — Trustly web flow.

### Payments, history, overdue
- `Sources/Screens/PaymentsView.swift`, `PaymentDetails/`, `PaymentsHistoryView.swift`, `MissedPaymentScreen.swift`, `PaymentOverdueCardView.swift` — unchanged in shape; `PaymentsView` shows the primary pay-in method row and links to the methods list.

### Helpers
- `Sources/Helpers/PaymentActionViewModel.swift`, `SwishDeepLink.swift` (`canOpen`, `open(_:)`), `PaymentData+titleView.swift`.

## Dependencies

- Imports: hCore, hCoreUI, AppStateContainer, CampaignUI, Combine, WebKit (Trustly), CoreImage (QR), UIKit (Swish deep link).
- Depended on by: App, Home (cards, deep links), Onboarding (hosts `PaymentAddPaymentMethod`).

## Deep links

`connect-payment` → `.handlePaymentMethods`, `connect-swish` → `.handleSwishPayinSetup`, `direct-debit` → `.handleDirectDebitSetup` (straight into the Trustly web view); all wired in `LoggedInNavigation` through `HomeNavigationViewModel` flags.

## Gotchas

- **`load()` is cached** on `paymentDataFetchedAt` and skipped while in flight; `load(forceUpdate: true)` bypasses both.
- **Refresh after a sheet finishes with `PaymentStore.refreshStatusDetached()`**, never an inline `Task` capturing the view — the sheet is torn down before the fetch completes.
- **`payinMethod(for:)`** merges `payinMethods` with `defaultPayinMethod` and prefers an active match; `isProcessing` is true when any match is pending.
- **`memberPhoneNumber`** on `PaymentStatusData` prefills Swish setup; the deep-link path has no other source for it.
- **`SwishDeepLink.canOpen`** needs `swish` under `LSApplicationQueriesSchemes` in both Info.plists or iOS answers `false`. The consent poll keeps `try await Task.sleep(for:)` so cancellation exits the loop.
- **Localisation keys come from Lokalise.** `Strings.swift` is generated from `Localizable.strings` and gitignored; a key hand-added to `.strings` disappears on the next translations pull and its `L10n.x` accessor stops compiling. On prototype branches use `"literal"  //L10n.key`.
- **`hRadioOptionList` needs a `.sectionContainerStyle(.transparent)` section** or it draws a second card.
- **`PaymentDetailsView` is public**: Home presents it for the upcoming-payment tile.
- **Demo client path is non-standard**: `PaymentClientDemo.swift` sits in `Service/Protocols/`.
- **`DirectDebitSetup`** is a `UIViewRepresentable` around `WKWebView` bridged by `TrustlyScriptHandler`.
- **`PayinMethodStatus.hasFailed`** is true only for `.addedtoFuture`.
- **Kivra** methods can only be removed, not changed, from `PaymentMethodScreen`.
