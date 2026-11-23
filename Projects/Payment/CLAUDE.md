# Payment

The Payments tab and everything around a member's payment methods: pay-in setup and management (Trustly, Swish,
Kivra/invoice), payout setup (Nordea, Swish, Trustly), upcoming/ongoing payments with breakdowns, payment history,
payment notices (tab badge) and overdue-payment recovery. Also exposes the pay-in entry points used by Home, App and
Onboarding.

## Architecture
- `PaymentStore` (`@PersistableStore` `AppStore`) is the single source of truth: payment data, `paymentStatusData`
  (connected/available methods + `layout`), history, missed payment and the notice badge. Screens observe it with
  `@AppObservedObject`. `connectPaymentPrompt` is the one place that decides whether a connect-payment card shows
  (`nil` = no card); Home only adds its member-state gate. Layout flags (`showsPayinSection`, `showsConnectPayout`, …)
  combine `paymentStatusData.layout` (`.qasaOnly` / `.other`) with the connected methods.
- Mutations live in small ViewModels. `PaymentActionViewModel` runs one change on a method (built with
  `.setDefault(_:)`, `.setDefaultPayout(_:)`, `.remove(_:)`) and drives the shared `PaymentMethodActionSheet`. Swish
  pay-in, Nordea/Swish payout and the overdue screen have their own ViewModels.
- `hPaymentService` wraps `hPaymentClient` with `@Log`; the GraphQL client is App's `hPaymentClientOctopus`.
- Display copy and presentation live on `PaymentProvider` extensions (`PaymentProvider+UI`,
  `PaymentProvider+Presentation`) and `ConnectedPaymentMethod+UI`; add provider-specific strings there, not in views.
- `PaymentConnectFlowView` is the shared pick → connect → confirm screen for both directions. Picker and confirmation
  share one `hForm` so `PaymentConnectionGraphic` stays mounted and animates between them.

## Entry points
- `PaymentsNavigation` (tab root) and the standalone payout stack (`PayoutNavigation`).
- Public detent modifiers: `.handleAddPaymentMethod(presented:)`, `.handlePaymentMethods(presented:)`,
  `.handlePayinSetupDeepLink(provider:)` (opens one provider's setup directly), `.handleMissedPayment(data:)`.
- `AddPaymentMethodScreen` is public and can be hosted by another flow (Onboarding passes a heading,
  `connectedProvider` and `onFinished`). `PaymentDetailsView` is public; App presents it for the upcoming-payment tile.
- Deep links (wired in App's `LoggedInNavigation`): `connect-payment` → payment methods list; `connect-swish` /
  `direct-debit` → `payinSetupProvider = .swish` / `.trustly` (Trustly goes straight to the web view).

## Dependencies
- hCore, hCoreUI, Forever (declared in `Project.swift` but not imported), CampaignCore, CampaignUI (+ CoreDependencies)
- Depended on by: App, Home, Onboarding

## Gotchas
- `load()` is cached on `paymentDataFetchedAt` and skipped while in flight; `load(forceUpdate: true)` bypasses both.
- After a sheet finishes, refresh with `PaymentStore.refreshStatusDetached()`, not an inline `Task` capturing the
  view: the sheet is torn down before the fetch completes.
- `connectedPaymentMethod(for:)` merges `defaultPayinMethod` with `payinMethods` and prefers an active match over a
  pending one for the same provider.
- `SwishDeepLink.canOpen` needs `swish` under `LSApplicationQueriesSchemes` in both Info.plists, otherwise iOS returns
  `false`. The Swish consent poll uses `try await Task.sleep(for:)` so cancellation exits the loop.
- The demo client `hPaymentClientDemo` sits in `Service/Protocols/`, not `Service/DemoImplementation/`.
- `DirectDebitSetup` hosts `TrustlyIosSdk`'s `TrustlyWKWebView`. Success/error/abort and the BankID hand-off arrive
  as checkout events on the SDK's bridge. **Don't re-add URL sniffing or a `bankid://` scheme handler**; Android has
  none either. The inner `WKWebView` is `internal`, so it's reached via `subviews`, and it ships with a fixed frame
  and no constraints, hence the `autoresizingMask`.
- `PaymentData.PaymentStatus.hasFailed` is true only for `.addedtoFuture`, not `.failedForPrevious`.
- Kivra (invoice) methods can only be removed, not changed, in `PaymentMethodDetailScreen`.
- The default method can't be removed. "Choose primary" only shows with 2+ active methods.
