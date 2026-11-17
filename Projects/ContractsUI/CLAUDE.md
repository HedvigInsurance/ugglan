# ContractsUI

SwiftUI screens built on `ContractsCore`. Displays active, pending, and terminated insurance contracts with details on coverage, agreements, and available actions like tier changes, stakeholder management, and addon handling.

## Architecture

- **Pattern**: `ContractStore` is an `@PersistableStore`-backed `AppStore` exposing `activeContracts`, `terminatedContracts`, and `pendingContracts` as observable arrays, plus helpers (`contractForId`, `allStakeholders`, `getAddonContractInfosFor`). Navigation coordinated by `ContractsNavigationViewModel`.
- **Key services**: `FetchContractsClient`, `ContractStore` and the contract models live in ContractsCore.
- **Data flow**: Views observe the store via `@AppObservedObject`. `Contracts.swift` triggers `await store.fetchContracts()` on appear, on pull-to-refresh, and on a 60-second polling timer. `ContractStore` conforms to `ExistingStakeholders` so it can be injected into `EditStakeholdersViewModel`. `ContractsNavigationViewModel` manages navigation state and coordinates modal/detent presentations.

## Key Files

- **Entry point**: `Contracts.swift` — main view with polling (60s intervals) and pull-to-refresh
- **Navigation**: `ContractsNavigation.swift` — orchestrates routes, detents, and modals for detail, termination, tier changes, stakeholder edits, addon management
- **ViewModels**: `ContractsNavigationViewModel` (router + published modals), `ContractDetailsViewModel` (observes store for contract deletion), `ContractTableViewModel` (loading state + addon banners)
- **Models**: `Models/Contract+UI.swift` — `Contract.pillowType`, `Contract`'s `TrackingViewNameProtocol` conformance, `ExistingAddon.availableActions`. `Models/Contract + displayItems.swift` — `ContractInformationDisplayItem` mapping. Service, store and data models: see ContractsCore.
- **View**: `ContractDetail.swift` (tabbed: Overview/Coverage/Details), `ContractTable.swift` (list with stacked card UI), `ContractRow.swift`, `ContractInformation.swift`, `ContractCoverage.swift`, `ContractDocuments.swift`

## Dependencies

- Imports: hCore, hCoreUI, AppStateContainer, AddonsCore, AddonsUI, TerminateContractsCore, TerminateContractsUI, EditStakeholdersCore, EditStakeholdersUI, ChangeTierUI, CrossSellCore, CrossSellUI, Apollo
- Depended on by: Home (contract data for navigation, renewal cards), App (insurances tab)

## Navigation

- `ContractsRouterType.terminatedContracts` — shows terminated contracts list
- `Contract` model-based route — navigates to `ContractDetail` for specific contract
- Entry: `ContractsNavigation` wraps `Contracts` view, provides redirect closures for external flows (movingFlow, chat, PDF, changeTier)
- Destinations: Contract list → detail → edit info detent → moving flow / changeTier / editStakeholders / terminate / addon actions

## Gotchas

- **Card Stack Animation**: ContractTable uses complex cumulative offset calculations for stacked card peek effect; VoiceOver forces expanded state
- **Store Polling**: Main Contracts view polls every 60 seconds — ensure service latency doesn't cause janky UI
- **EditType Logic**: `EditType.getTypes()` dynamically determines available actions; some require feature flags (e.g., termination flow)
- **Missing Data Handling**: Contract state tracks missing stakeholders (co-insured/co-owners) separately with and without termination dates
- **Termination Message Logic**: Different contract types show "Valid Until" vs "Terminated At" with handling for past, today, and future dates
