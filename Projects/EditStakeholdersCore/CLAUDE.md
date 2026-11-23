# EditStakeholdersCore

UI-free data layer for managing co-insured and co-owners (stakeholders): models, `EditStakeholdersClient` and the
`EditStakeholdersService` logging wrapper. No SwiftUI or hCoreUI.

## Architecture
- `StakeholderType` (`.coInsured` / `.coOwner`) drives one shared flow for both kinds, including localized strings
  and tracking names. `StakeholdersConfig` is the per-contract edit input.
- `ExistingStakeholders` is a protocol that `ContractStore` (ContractsCore) implements to provide stakeholders already
  on other contracts.

## Dependencies
- hCore
- Depended on by: EditStakeholdersUI, ContractsCore, ContractsUI, Home, Onboarding, TravelCertificate, App
  (`EditStakeholdersClientOctopus`, DI)

## Gotchas
- `Models/ContractModel.swift` defines a module-local `Contract` / `Agreement` / `ProductVariant` returned by
  `EditStakeholdersClient.fetchContracts()`. This is not ContractsCore's `Contract`.
- There's no DemoImplementation. Mock clients have to be registered elsewhere (see EditStakeholdersUI's
  `Tests/MockData.swift`).
- There's no test target. The stakeholder logic under test lives in EditStakeholdersUI's ViewModels.
