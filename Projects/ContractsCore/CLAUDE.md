# ContractsCore

UI-free data layer for insurance contracts: the contract models, `ContractStore`, the fetch and pet chip id client
protocols with their demo implementations, and `PetChipIdService`. No SwiftUI or hCoreUI.

## Architecture
- `ContractStore` is a `@PersistableStore` `AppStore` holding active, pending and terminated contracts. It conforms
  to `ExistingStakeholders`, so EditStakeholders and Onboarding can use it as the source of existing co-insured and
  co-owners.
- `Contract` exposes the derived state that other modules rely on: missing stakeholder counts, the termination
  message, and conversions to termination and addon inputs.
- `EditType.getTypes(for:)` decides which edit actions a contract offers, based only on the contract's `supports…`
  flags.

## Dependencies
- hCore, AddonsCore, EditStakeholdersCore, TerminateContractsCore
- Depended on by: ContractsUI, Chat, Profile, TravelCertificate, Home, Onboarding, App (`FetchContractsClientOctopus`,
  `PetChipIdClientOctopus`, DI)

## Gotchas
- `Contract.pillowType` and `Contract`'s `TrackingViewNameProtocol` conformance live in ContractsUI because they need
  hCoreUI. Modules that use them must import ContractsUI.
