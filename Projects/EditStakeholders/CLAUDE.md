# EditStakeholders

Manages co-insured and co-owner editing for insurance contracts. Supports adding, editing, and removing stakeholders with midterm change intent workflows and SSN-based personal data lookup.

## Architecture
- Pattern: ViewModel (`@MainActor class: ObservableObject`) -- no `@Inject` on the top-level ViewModels; instead, `EditStakeholdersService` uses `@Inject var service: EditStakeholdersClient`
- Key services: `EditStakeholdersClient` (protocol), `EditStakeholdersService` (thin wrapper with logging)
- Data flow: `EditStakeholdersViewModel` orchestrates contract fetching and determines which navigation model to present. `StakeholdersViewModel` tracks local add/delete/edit state for stakeholders. `IntentViewModel` handles the commit step. Service calls go through `EditStakeholdersService` -> `EditStakeholdersClient`.

## Key Files
- Entry point views: `EditStakeholdersNavigation` and `EditStakeholdersSelectInsuranceNavigation` in `Sources/Navigation/EditStakeholdersNavigation.swift`
- ViewModels: `EditStakeholdersViewModel` (`Sources/Models/EditStakeholdersViewModel.swift`), `StakeholdersViewModel` (`Sources/View/StakeholdersViewModel.swift`), `StakeholderInputViewModel` (`Sources/View/StakeholderInput/StakeholderInputViewModel.swift`), `IntentViewModel` (`Sources/View/StakeholderInput/IntentViewModel.swift`)
- Service protocol: `EditStakeholdersClient` in `Sources/Service/Protocols/EditStakeholdersClient.swift`
- Service implementation: `EditStakeholdersService` in `Sources/Service/EditStakeholdersService.swift`
- Models: `StakeholderModel`, `StakeholdersConfig`, `ContractModel`, `IntentData`, `PersonalData` in `Sources/Models/`

## Dependencies
- Imports: hCore, hCoreUI, CrossSell
- Depended on by: TravelCertificate, Contracts

## Navigation
- `EditStakeholdersNavigation`: Main flow using `RouterHost`, presents `StakeholdersScreen` as root. Uses `.modally` and `.detent` for sub-flows (input, select, progress).
- `EditStakeholdersSelectInsuranceNavigation`: Shown when multiple contracts support stakeholders; user picks which contract to edit.
- `EditStakeholdersAlertNavigation`: Presents a missing-stakeholder alert that can open the full edit flow.
- Entered from Contracts module (contract detail) and TravelCertificate (via `EditStakeholdersViewModel` as an `@EnvironmentObject`).

## Gotchas
- `EditStakeholdersViewModel` requires an `ExistingStakeholders` conformer at init, which couples it to whichever module provides current stakeholder data (typically ContractStore).
- No DemoImplementation exists in this module; demo/mock client must be registered externally.
- The `StakeholdersViewModel` tracks local add/delete state independently from the server. If the intent call fails, local state may drift.
