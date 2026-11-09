# EditStakeholdersCore

UI-free data layer for co-insured and co-owner (stakeholder) management: models, the client protocol and the
service wrapper. No SwiftUI or hCoreUI.

## Key Files
- `Sources/Models/StakeholderModel.swift` — `Stakeholder`, `StakeholderItem`, `StatusPillType`, `StakeholderConfigModel`
- `Sources/Models/StakeholdersConfig.swift` — `StakeholdersConfig` (per-contract edit input) and `StakeholderType`
  (`.coInsured` / `.coOwner`) with its localized strings and tracking names
- `Sources/Models/ContractModel.swift` — module-local `Contract`/`Agreement`/`ProductVariant` returned by
  `EditStakeholdersClient.fetchContracts()` (not the Contracts module's `Contract`)
- `Sources/Models/ExistingStakeholders.swift` — protocol implemented by `ContractStore` to supply stakeholders already
  on other contracts
- `Sources/Models/IntentData.swift`, `PersonalData.swift` — midterm change intent and SSN lookup results
- `Sources/Service/Protocols/EditStakeholdersClient.swift` — client protocol, `StakeholderAction`, `EditStakeholdersError`
- `Sources/Service/EditStakeholdersService.swift` — logging wrapper around `EditStakeholdersClient`

## Dependencies
- hCore (+ AutomaticLog)
- Depended on by: EditStakeholdersUI, Contracts, Home, Onboarding, TravelCertificate, App
  (`EditStakeholdersClientOctopus`, DI)

## Gotchas
- No DemoImplementation exists; demo/mock clients must be registered externally.
- No test target: the stakeholder logic under test lives in EditStakeholdersUI's view models.
