# AddonsUI

SwiftUI views, navigation and ViewModels for insurance addon purchase and removal, built on `AddonsCore`. Supports both toggleable addons (independent selection) and selectable addons (mutually exclusive options with sub-option drilling).

## Architecture
- Pattern: ViewModel (`@MainActor @Observable class`). ViewModels call `AddonsService` from `AddonsCore`.
- Data flow: `ChangeAddonCoordinator` (ViewModifier) fetches the initial offer, then presents either `ChangeAddonNavigation` or a deflect view. `ChangeAddonViewModel` manages addon selection state and cost fetching. `RemoveAddonViewModel` handles addon removal.
- Two parallel flows: Change/Add addons and Remove addons, each with their own navigation and coordinator.

## Key Files
- Coordinators: `ChangeAddonCoordinator` in `Sources/Navigation/ChangeAddonCoordinator.swift` (also holds `OfferInput`), `RemoveAddonCoordinator` in `Sources/Navigation/RemoveAddonCoordinator.swift`
- Navigation: `ChangeAddonNavigation` in `Sources/Navigation/ChangeAddonNavigation.swift`, `RemoveAddonNavigation` in `Sources/Navigation/RemoveAddonNavigation.swift`
- ViewModels: `ChangeAddonViewModel` in `Sources/Views/ChangeAddonViewModel.swift`, `RemoveAddonViewModel` in `Sources/Views/RemoveAddonViewModel.swift`
- Screens: `ChangeAddonScreen`, `ChangeAddonSummaryScreen`, `AddonProcessingScreen`, `AddonSelectInsuranceScreen`, `AddonSelectSubOptionScreen`, `AddonLearnMoreView`, `RemoveAddonScreen`, `RemoveAddonSummaryScreen`, `RemoveAddonProcessingScreen`, `DeflectView` in `Sources/Views/`
- Logging: `AddonLogInfo` in `Sources/Models/AddonLogInfo.swift` (Datadog purchase attributes)

## Dependencies
- Imports: hCore, hCoreUI, AddonsCore
- Depended on by: Contracts (`handleAddons`, `handleRemoveAddons`), TravelCertificate (`handleAddons`, `AddonCardView`), App (`handleAddons`)

## Navigation
- Public entry via `View.handleAddons(input:)` modifier -- attach to any view, bind a `ChangeAddonInput?`, and the coordinator handles fetching offers and presenting the flow modally.
- Public entry for removal via `View.handleRemoveAddons(input:)` modifier with `RemoveAddonInput?`.
- `ChangeAddonNavigation` uses `hNavigationStack` with a `NavigationRouter` and `routerDestination` for the landing -> summary flow. Detents for sub-option selection, learn-more, PDF preview, and info.
- `RemoveAddonNavigation` follows the same pattern for the removal flow.
- `analyticsUserFlow` in `ChangeAddonViewModel` maps each `AddonSource` case to the Firebase `addon_purchased` `user_flow` value.

## Gotchas
- The coordinator pattern (ViewModifier) means the addon flow can be attached to any view in the app, which makes it hard to trace where addon flows originate.
- `Tests/MockData.swift` duplicates `MockAddonsService` from `AddonsCore/Tests` — test targets can't share helpers yet.
