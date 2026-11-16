# TerminateContractsUI

SwiftUI flow built on `TerminateContractsCore`. Multi-step contract cancellation flow. Guides users through insurance selection, date picking, surveys, deflection screens (auto-decom, auto-cancel), confirmation, and success/failure outcomes.

## Key Files
- `Sources/Navigation/TerminationFlowNavigationViewModel.swift` — Central navigation ViewModel; owns the `Router`, manages step routing, context, and all step models. Also contains `TerminationFlowNavigation` view, all router action enums and the `TrackingViewNameProtocol` conformance of `DeflectScreenContent`
- `Sources/Models/TerminateInsuranceViewModel.swift` — Entry point ViewModel; decides single-contract vs multi-select flow
- `Sources/Views/SetTerminationDateLandingScreen.swift` — Date selection landing screen
- `Sources/Views/TerminationSurveyScreen.swift` — Cancellation reason survey
- `Sources/Views/TerminationSummaryScreen.swift` — Termination summary before confirmation
- `Sources/Views/ConfirmTerminationScreen.swift` — Final confirmation step
- `Sources/Helpers/View+hide.swift` — View extension helper
- Service, client protocol, demo client and models (`TerminationConfirmConfig`, `TerminationSurveyData`, `DeflectScreenContent`, …): see TerminateContractsCore

## Dependencies
- hCore, hCoreUI, TerminateContractsCore, ChangeTier
- Depended on by: App, Contracts, Home

## Gotchas
- `TerminationFlowNavigationViewModel.swift` is a large file (~740 lines) containing the main ViewModel, helper classes (`TerminationRedirectHandler`, `TerminationStepHandler`), the navigation view, and all routing enums
- The flow is **context-driven**: each API response returns a `terminationContext` string and the next step, which the ViewModel uses to navigate forward
- Supports deflection: the backend can redirect users to change-tier or move-contract flows instead of terminating
- `TerminateInsuranceViewModel` branches on `configs.count > 1` to show insurance selection or skip directly to the termination flow
- Tests keep their own `MockTerminateContractsClient` / `MockTerminationData` copy in `Tests/MockData.swift`
