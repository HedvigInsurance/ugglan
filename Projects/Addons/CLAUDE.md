# Addons

Handles insurance addon discovery, purchase, and removal. Supports both toggleable addons (independent selection) and selectable addons (mutually exclusive options with sub-option drilling).

## Architecture
- Pattern: ViewModel (`@MainActor class: ObservableObject`). `AddonsService` uses `@Inject var client: AddonsClient`.
- Key services: `AddonsClient` (protocol), `AddonsService` (wrapper with `@Log` macro and artificial delays on submit/confirm)
- Data flow: `ChangeAddonCoordinator` (ViewModifier) fetches the initial offer, then presents either `ChangeAddonNavigation` or a deflect view. `ChangeAddonViewModel` manages addon selection state and cost fetching. `RemoveAddonViewModel` handles addon removal.
- Two parallel flows: Change/Add addons and Remove addons, each with their own navigation and coordinator.

## Key Files
- Coordinators: `ChangeAddonCoordinator` in `Sources/Navigation/ChangeAddonCoordinator.swift`, `RemoveAddonCoordinator` in `Sources/Navigation/RemoveAddonCoordinator.swift`
- Navigation: `ChangeAddonNavigation` in `Sources/Navigation/ChangeAddonNavigation.swift`, `RemoveAddonNavigation` in `Sources/Navigation/RemoveAddonNavigation.swift`
- ViewModels: `ChangeAddonViewModel` in `Sources/Views/ChangeAddonViewModel.swift`, `RemoveAddonViewModel` in `Sources/Views/RemoveAddonViewModel.swift`
- Service protocol: `AddonsClient` in `Sources/Service/Protocols/AddonsClient.swift`
- Service implementation: `AddonsService` in `Sources/Service/OctopusImplementation/AddonsService.swift`
- Demo: `AddonsClientDemo` in `Sources/Service/DemoImplementation/AddonsClientDemo.swift`
- Screens: `ChangeAddonScreen`, `ChangeAddonSummaryScreen`, `AddonProcessingScreen`, `AddonSelectInsuranceScreen`, `AddonSelectSubOptionScreen`, `AddonLearnMoreView`, `RemoveAddonScreen`, `RemoveAddonSummaryScreen`, `RemoveAddonProcessingScreen`, `DeflectView` in `Sources/Views/`
- Models: `AddonOffer` in `Sources/Models/AddonOffer.swift`, `AddonRemoveOffer` in `Sources/Models/AddonRemoveOffer.swift`

## Dependencies
- Imports: hCore, hCoreUI
- Depended on by: CrossSell, Contracts, TravelCertificate (via `AddonSource` and `handleAddons` modifier)

## Navigation
- Public entry via `View.handleAddons(input:)` modifier -- attach to any view, bind a `ChangeAddonInput?`, and the coordinator handles fetching offers and presenting the flow modally.
- Public entry for removal via `View.handleRemoveAddons(input:)` modifier with `RemoveAddonInput?`.
- `ChangeAddonNavigation` uses `RouterHost` with `routerDestination` for landing -> summary flow. Detents for sub-option selection, learn-more, PDF preview, and info.
- `RemoveAddonNavigation` follows the same pattern for the removal flow.
- `AddonSource` enum tracks where the addon flow was initiated from (insurances tab, travel certificates, cross sell, deeplink).

## Gotchas
- The `OctopusImplementation/` directory (`Sources/Service/OctopusImplementation/AddonsService.swift`) is located inside this module rather than in the central `hGraphQL` project where other Octopus implementations live. This is inconsistent with the rest of the codebase.
- `AddonsService.submitAddons` and `confirmAddonRemoval` both run an artificial 3-second delay in parallel with the actual network call, ensuring the processing screen shows for a minimum duration.
- The coordinator pattern (ViewModifier) means the addon flow can be attached to any view in the app, which makes it hard to trace where addon flows originate.
