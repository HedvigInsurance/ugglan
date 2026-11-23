# ContractsCore

UI-free data layer for insurance contracts: the contract models, `ContractStore`, the fetch and pet chip id client
protocols with their demo implementations, and `PetChipIdService`. No SwiftUI or hCoreUI.

## Key Files
- `Sources/Models/ContractModels.swift` — `Contract`, `Agreement`, `AgreementDisplayItem`, `ContractRenewal`,
  `AddonsInfo`, `ExistingAddon`, `AvailableAddon`, plus the stakeholder helpers (`nbOfMissingCoInsured`, …),
  `terminationMessage`, `StakeholdersConfig.init(contract:stakeholderType:fromInfoCard:)`,
  `asTerminationConfirmConfig` and `asAddonContractInfo`
- `Sources/Models/EditType+Contract.swift` — `EditType.getTypes(for:)` factory + `Contract.supportsAddonRemoval`
- `Sources/Stores/ContractsStore.swift` — `ContractStore` (`@PersistableStore` `AppStore`) with active/terminated/
  pending contracts, `contractForId`, `allStakeholders`, `getAddonContractInfosFor`; conforms to
  `ExistingStakeholders`
- `Sources/Service/Protocols/ContractsClient.swift` — `FetchContractsClient`, `ContractsStack`
- `Sources/Service/Protocols/PetChipIdClient.swift`, `Sources/Service/PetService.swift` — missing pet chip id
- `Sources/Service/DemoImplementation/` — `FetchContractsClientDemo`, `PetChipIdClientDemo`

## Dependencies
- hCore, AppStateContainer, AddonsCore, EditStakeholdersCore, TerminateContractsCore
- Depended on by: ContractsUI, Chat (`ContractStore`), Profile (`ContractStore`), TravelCertificateUI, Home, Onboarding,
  App (`ContractsClientOctopus`, `PetClientOctopus`, DI)

## Tests
- `ContractTests` (client via `MockContractService`) and `StoreTests/ContractStoreTests`

## Gotchas
- `Contract.pillowType` and `Contract`'s `TrackingViewNameProtocol` conformance live in ContractsUI (they need
  hCoreUI / `ContractDetail`), so modules that use them must import ContractsUI.
