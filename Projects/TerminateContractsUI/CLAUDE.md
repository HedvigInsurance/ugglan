# TerminateContractsUI

SwiftUI contract cancellation flow built on `TerminateContractsCore`: insurance selection, cancellation survey,
deflection screens (auto-decom, auto-cancel), date picking, confirmation and success/failure outcomes.

## Architecture
- `TerminateInsuranceViewModel` is the public entry ViewModel. `start(with:)` with a single config fetches the survey
  up front and opens the flow at the survey; with several configs it opens at insurance selection.
- `TerminationFlowNavigationViewModel` owns the router and all flow state (selected option, comment, date, survey
  data). Whether the flow terminates with a date or deletes the insurance comes from the survey's `action`
  (`.terminateWithDate` / `.deleteInsurance`).
- Survey options can carry a `TerminationSuggestion`: deflect suggestions push a `DeflectScreenContent` screen;
  other suggestions go through `TerminationRedirectHandler` (change tier, update address, external redirect).

## Entry points
- `.handleTerminateInsurance(vm:onDismiss:)`, used by App (`LoggedInNavigation+Presentations`), ContractsUI and Home
  quick actions. It also presents `ChangeTierNavigation` when a change-tier suggestion is accepted.

## Dependencies
- hCore, hCoreUI, TerminateContractsCore, ChangeTierCore, ChangeTierUI
- Depended on by: App, ContractsUI, Home

## Gotchas
- `TerminationFlowNavigationViewModel.swift` (~680 lines) also holds `TerminationRedirectHandler`, the
  `TerminationFlowNavigation` view and all route enums.
- Redirects to the move flow or an external URL dismiss the flow, then post `.openDeepLink` after 0.5 s.
  The move flow is opened via the `moveContract` deep link, not by importing MoveFlowUI.
- Tests keep their own `MockTerminateContractsClient` copy in `Tests/MockData.swift`, separate from the Core tests.
  `TerminationFlowNavigationViewModelRetainTests` checks the VM is released while its router lives. Progress is
  re-armed with `withObservationTracking` on `router.routeTypes`, so keep `[weak self]` there.
