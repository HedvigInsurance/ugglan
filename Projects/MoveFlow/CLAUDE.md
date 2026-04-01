# MoveFlow

Handles the address change (moving) flow for insurance contracts. Guides users through selecting a contract, housing type, entering address details, house-specific information, choosing a tier/deductible for the new address, and confirming the move.

## Architecture
- Pattern: ViewModel (`@MainActor class: ObservableObject`). `MovingFlowNavigationViewModel` uses `@Inject private var service: MoveFlowClient`.
- Key services: `MoveFlowClient` (protocol)
- Data flow: `MovingFlowNavigationViewModel` is the central VM that fetches move intent configuration, manages address/house input models, handles quote selection, and implements `ChangeTierQuoteDataProvider` to integrate with the ChangeTier module for tier selection. `MovingFlowQuoteManager` is a helper that builds summary view models and updates quote costs.

## Key Files
- Entry point: `MovingFlowNavigation` in `Sources/Navigation/MovingFlowNavigation.swift`
- ViewModel: `MovingFlowNavigationViewModel` in `Sources/Navigation/MovingFlowNavigation.swift` (same file as navigation)
- Helper: `MovingFlowQuoteManager` in `Sources/Navigation/MovingFlowNavigation.swift`
- Service protocol: `MoveFlowClient` in `Sources/Service/Protocols/MoveFlowClient.swift`
- Demo: `MoveFlowClientDemo` in `Sources/Service/DemoImplementation/MoveFlowClientDemo.swift`
- Screens: `MovingFlowSelectContractScreen`, `MovingFlowHousingTypeScreen`, `MovingFlowAddressScreen`, `MovingFlowHouseScreen`, `MovingFlowAddExtraBuildingScreen`, `MovingFlowConfirmScreen`, `MovingFlowProcessingScreen`, `TypeOfBuildingPickerScreen` in `Sources/View/`
- Models: `MoveConfigurationModel` in `Sources/Model/MoveConfigurationModel.swift`, `MoveQuotesModel` in `Sources/Model/MoveQuotesModel.swift`

## Dependencies
- Imports: hCore, hCoreUI, Contracts, ChangeTier (for `ChangeTierNavigation`, `ChangeTierQuoteDataProvider`, `ChangeTierIntentModel`)
- Additional build dependencies: CoreDependencies, ResourceBundledDependencies
- Depended on by: App

## Navigation
- `MovingFlowNavigation`: Uses `RouterHost` with `routerDestination` for multi-step flow.
- Routes: `MovingFlowRouterActions` (housing, confirm, houseFill, selectTier) and `MovingFlowRouterWithHiddenBackButtonActions` (processing).
- Initial screen depends on whether the user has multiple home addresses (shows contract selection) or one (shows housing type selection directly).
- Integrates ChangeTier inline by pushing `ChangeTierNavigation` with the move flow's own router and data provider.
- Detent presentations for extra building input, PDF preview, and building type picker.
- Calls `onMoved()` callback via `.onDeinit` when the flow is dismissed.

## Gotchas
- `MovingFlowNavigationViewModel` implements `ChangeTierQuoteDataProvider`, meaning it acts as a data bridge between the move flow and the change tier module for real-time cost calculations.
- The navigation VM, quote manager, and route enums are all defined in `MovingFlowNavigation.swift`, making it a large file.
- No separate service wrapper class exists; the VM calls `MoveFlowClient` directly via `@Inject`.
- `movingFlowConfirmViewModel` and `quoteSummaryViewModel` are force-unwrapped in the navigation views.
