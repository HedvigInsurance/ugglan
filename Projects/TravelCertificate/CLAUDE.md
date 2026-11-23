# TravelCertificate

Travel insurance certificates: a list of existing certificates (PDF preview) and a creation flow where the member picks
a contract, sets the travel start date and chooses who is travelling (incl. co-insured), then gets a PDF.

## Architecture
- `TravelCertificateNavigationViewModel` holds the navigation state and the child VMs for the creation flow
  (`StartDateViewModel`, `WhoIsTravelingViewModel`). `TravelInsuranceService` wraps `TravelInsuranceClient`.
- The list screen is always the root; creating a certificate is presented modally (start date → who is travelling →
  processing).
- `TravelInsuranceClient.getList` also returns the addon banner, so the list screen shows the travel addon upsell
  (via AddonsUI's `.handleAddons(input:)` and `AddonCardView`).

## Entry points
- `TravelCertificateNavigation(vm:infoButtonPlacement:useOwnNavigation:)`. With `useOwnNavigation: false` it's
  embedded in the caller's stack (Profile); App presents it standalone.

## Dependencies
- hCore, hCoreUI, AddonsCore, AddonsUI, ContractsCore, EditStakeholdersCore, EditStakeholdersUI
- Depended on by: Profile, App

## Gotchas
- Resolves `ContractStore` from `globalAppStateContainer` to give `EditStakeholdersViewModel` the existing
  stakeholders.
- `startDateViewModel` and `whoIsTravelingViewModel` are force-unwrapped in the route destinations; they're set
  before those routes are pushed.
