# AddonsUI

SwiftUI flows for buying and removing insurance addons, built on AddonsCore. Supports toggleable addons (independent
selection) and selectable addons (mutually exclusive options with sub-option drilling).

## Architecture
- Two parallel flows, each with a coordinator `ViewModifier`, a navigation view and a ViewModel:
  - Change/add: `ChangeAddonCoordinator` fetches the offer, then presents `ChangeAddonNavigation` or a `DeflectView`.
    `ChangeAddonViewModel` owns selection state and cost fetching.
  - Remove: `RemoveAddonCoordinator` → `RemoveAddonNavigation`, driven by `RemoveAddonViewModel`.
- `AddonLogInfo` holds the Datadog purchase attributes; `analyticsUserFlow` (a fileprivate `AddonSource`
  extension in `ChangeAddonViewModel.swift`) maps each source to the Firebase `addon_purchased` `user_flow` value.

## Entry points
- `View.handleAddons(input:)` with a `ChangeAddonInput?` binding, and `View.handleRemoveAddons(input:)` with a
  `RemoveAddonInput?` binding. Used from App (`LoggedInNavigation`), ContractsUI and TravelCertificate.

## Dependencies
- hCore, hCoreUI, AddonsCore
- Depended on by: App, ContractsUI, TravelCertificate

## Gotchas
- Because the flow is attached via a modifier, it can start from many places — search for `handleAddons(` to find
  them all.
- `Tests/MockData.swift` has its own copy of `MockAddonsService` (separate from AddonsCore's test copy).
