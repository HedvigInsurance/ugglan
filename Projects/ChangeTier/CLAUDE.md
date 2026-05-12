# ChangeTier

Handles insurance plan tier upgrades and downgrades. Users can compare coverage tiers, select deductible levels, preview price changes, and commit tier changes.

## Architecture
- Pattern: ViewModel (`@MainActor class: ObservableObject`). `ChangeTierService` uses `@Inject var client: ChangeTierClient`.
- Key services: `ChangeTierClient` (protocol), `ChangeTierService` (thin wrapper with `@Log` macro), `ChangeTierQuoteDataProvider` (protocol for external cost calculation, e.g. from MoveFlow)
- Data flow: `ChangeTierViewModel` fetches tier data via `ChangeTierService`, maintains selected tier/quote/addon state, and calculates totals. `ChangeTierNavigationViewModel` manages navigation state and detent presentations.

## Key Files
- Entry point: `ChangeTierNavigation` in `Sources/Navigation/ChangeTierNavigation.swift`
- ViewModel: `ChangeTierViewModel` in `Sources/Views/ChangeTierViewModel.swift`
- Navigation VM: `ChangeTierNavigationViewModel` in `Sources/Navigation/ChangeTierNavigation.swift`
- Service protocol: `ChangeTierClient` in `Sources/Service/Protocols/ChangeTierClient.swift`
- Data provider protocol: `ChangeTierQuoteDataProvider` in `Sources/Service/Protocols/ChangeTierQuoteDataProvider.swift`
- Service implementation: `ChangeTierService` in `Sources/Service/ChangeTierService.swift`
- Demo: `ChangeTierClientDemo` in `Sources/Service/DemoImplementation/ChangeTierClientDemo.swift`
- Screens: `ChangeTierLandingScreen`, `ChangeTierSummaryScreen`, `ChangeTierProcessingScreen`, `CompareTierScreen`, `EditScreen`, `SelectInsuranceScreen` in `Sources/Views/`
- Model: `ChangeTierIntentModel` in `Sources/Models/ChangeTierIntentModel.swift`

## Dependencies
- Imports: hCore, hCoreUI, CrossSell
- Depended on by: Contracts, TerminateContracts, MoveFlow, App

## Navigation
- `ChangeTierNavigation`: Entry point SwiftUI view. Accepts `ChangeTierInput` (single contract) or `ChangeTierContractsInput` (multiple contracts with selection screen). Uses `RouterHost` with `routerDestination` for summary and processing screens.
- Routes: `ChangeTierRouterActions.summary`, `ChangeTierRouterActionsWithoutBackButton.commitTier`
- Detent presentations for tier/deductible editing (`EditScreen`), insurable limits info, compare tiers, and PDF preview.
- Can optionally accept an external `Router` and `ChangeTierQuoteDataProvider` (used by MoveFlow to embed tier selection inline).

## Gotchas
- `ChangeTierQuoteDataProvider` is an external protocol that MoveFlow implements to provide cost calculations. When provided, the VM delegates total cost calculation to the provider instead of using the quote's built-in cost.
- `ChangeTierNavigation` has two init paths: one for direct use (creates its own `RouterHost`) and one for embedding in another flow (uses the provided router).
- The `ChangeTierNavigationViewModel.vm` property is force-unwrapped in several places; it is set during init but the multi-contract path defers it.
