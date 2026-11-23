# ContractsUI

SwiftUI screens built on ContractsCore: the insurances tab showing active, pending and terminated contracts, contract
details (overview / coverage / documents), and entry points for editing a contract (change tier, co-insured /
co-owners, addons, termination, moving). It also hosts the missing pet chip id flow.

## Architecture
- `ContractsNavigation` is the entry point. Its `ContractsNavigationViewModel` owns the router and the presented
  modals and detents. Flows owned by other modules come back to the caller through the `redirect` closure
  (`RedirectType`: chat, moving flow, PDF, change tier) and the `redirectAction` closure (termination).
- `Contracts` refetches `ContractStore` every 60 seconds while visible and on pull-to-refresh.
- `ContractStore` is passed to `EditStakeholdersViewModel` as its `ExistingStakeholders`.
- Routes: `Contract` (pushes `ContractDetail`) and `ContractsRouterType.terminatedContracts`.

## Entry points
- App's insurances tab hosts `ContractsNavigation`. Home uses contract data and UI from this module.
- `.handleMissingChipIds(input:)` presents the missing pet chip id flow. It's used by App
  (`LoggedInNavigation+Presentations`) and Onboarding.

## Dependencies
- hCore, hCoreUI, ContractsCore, TerminateContractsCore/UI, EditStakeholdersCore/UI, ChangeTierUI, AddonsCore/UI,
  CrossSellCore/UI
- Depended on by: App, Home, Onboarding

## Gotchas
- `ContractTable` draws contracts as a stacked card "peek" using cumulative offsets. With VoiceOver on, it always shows
  the expanded state.
- `Contract.pillowType`, `Contract`'s `TrackingViewNameProtocol` conformance and `ExistingAddon.availableActions` are
  defined here, not in ContractsCore.
