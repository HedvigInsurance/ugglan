# EditStakeholdersUI

SwiftUI flow built on EditStakeholdersCore for adding, editing and removing co-insured and co-owners on a contract.
It uses a midterm change intent and SSN-based personal data lookup.

## Architecture
- `EditStakeholdersViewModel` is the shared entry ViewModel. `start(...)` fetches contracts and decides whether to
  present the flow as a detent (and the insurance picker when several contracts support stakeholders) or full screen.
  `checkForAlert()` shows the missing-stakeholder alert.
- `StakeholdersViewModel` tracks local add / delete / edit state. `IntentViewModel` creates and commits the intent.
  `StakeholderInputViewModel` handles a single person's input. Service calls go through `EditStakeholdersService`.
- Navigation views: `EditStakeholdersNavigation` (main flow), `EditStakeholdersSelectInsuranceNavigation` (picks the
  contract) and `EditStakeholdersAlertNavigation` (missing-stakeholder alert).

## Entry points
- Host views apply `.handleEditStakeholders(with: vm)` and call `vm.start(...)`. This is used by App
  (`LoggedInNavigation`), Home (quick actions), Onboarding, ContractsUI and TravelCertificate.

## Dependencies
- hCore, hCoreUI, EditStakeholdersCore
- Depended on by: App, ContractsUI, Home, Onboarding, TravelCertificate

## Gotchas
- `EditStakeholdersViewModel` needs an `ExistingStakeholders` conformer at init. In practice that's `ContractStore`.
- `StakeholdersViewModel` keeps local state separate from the server, so if the intent call fails, local state can
  drift.
