# Contracts

Displays active, pending, and terminated insurance contracts with details on coverage, agreements, and available actions like tier changes, stakeholder management, and addon handling.

## Architecture

- **Pattern**: Legacy Store. Uses `ContractStore` (extends `LoadingStateStore`) managed via `PresentableStore`. Navigation coordinated by `ContractsNavigationViewModel`.
- **Key services**: `FetchContractsClient` protocol for fetching active/pending/terminated contracts and addon banners. `FetchContractsClientDemo` provides sample data.
- **Data flow**: `ContractStore` holds `ContractState` with three contract lists. Views use `@PresentableStore` to access state and send actions. `ContractsNavigationViewModel` manages navigation state and coordinates modal/detent presentations.

## Key Files

- **Entry point**: `Contracts.swift` — main view with polling (60s intervals) and pull-to-refresh
- **Navigation**: `ContractsNavigation.swift` — orchestrates routes, detents, and modals for detail, termination, tier changes, stakeholder edits, addon management
- **ViewModels**: `ContractsNavigationViewModel` (router + published modals), `ContractDetailsViewModel` (observes store for contract deletion), `ContractTableViewModel` (loading state + addon banners)
- **Service**: `Service/Protocols/ContractsClient.swift`, `Service/DemoImplementation/ContractsClientDemo.swift`
- **Models**: `Models/ContractModels.swift` — `Contract`, `Agreement`, `ContractRenewal`, `AddonsInfo`, `ExistingAddon`, `AvailableAddon`
- **View**: `ContractDetail.swift` (tabbed: Overview/Coverage/Details), `ContractTable.swift` (list with stacked card UI), `ContractRow.swift`, `ContractInformation.swift`, `ContractCoverage.swift`, `ContractDocuments.swift`
- **Store**: `ContractsStore.swift`, `ContractState.swift`, `ContractAction.swift`

## Dependencies

- Imports: hCore, hCoreUI, PresentableStore, Addons, TerminateContracts, EditStakeholders, ChangeTier, CrossSell, Apollo
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
