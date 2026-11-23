# ChangeTierUI

SwiftUI flow for upgrading or downgrading an insurance tier, built on ChangeTierCore: compare tiers, pick a
deductible, preview the new price and commit the change.

## Architecture
- `ChangeTierNavigationViewModel` owns the router and detent state; `ChangeTierViewModel` fetches tiers through
  `ChangeTierService`, tracks the selected tier/quote/addons, and calculates totals.
- `ChangeTierInput` (UI-only, defined here) is either `.contractWithSource` (fetch an intent for a contract) or
  `.existingIntent` (an intent that already exists, plus an `onSelect` callback). MoveFlowUI and
  TerminateContractsUI use `.existingIntent`.
- `ChangeTierQuoteDataProvider`: when one is passed in (MoveFlowUI does this), the ViewModel gets the total price and
  display items from the provider instead of from the quote.

## Entry points
- `ChangeTierNavigation(input: ChangeTierInput, dataProvider:router:)`: with a `router`, the flow is embedded in the
  caller's stack; without one, it creates its own `hNavigationStack`.
- `ChangeTierNavigation(input: ChangeTierContractsInput)`: for several contracts, shows `SelectInsuranceScreen`
  first. With a single contract it skips straight to the landing screen.
- Presented from App (`LoggedInNavigation`), Home quick actions, ContractsUI, MoveFlowUI and TerminateContractsUI.

## Dependencies
- hCore, hCoreUI, ChangeTierCore, CrossSellCore
- Depended on by: App, ContractsUI, Home, MoveFlowUI, TerminateContractsUI

## Gotchas
- `ChangeTierNavigationViewModel.vm` is an implicitly unwrapped optional. In the multi-contract path it is only set
  once a contract is selected, so it must be assigned before `ChangeTierLandingScreen` is shown.
