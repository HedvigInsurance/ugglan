# TravelCertificate

Generates travel insurance certificates. Users select a contract, set travel dates, specify travelers (including co-insured), and receive a downloadable PDF certificate.

## Architecture
- Pattern: ViewModel (`@MainActor class: ObservableObject`). `TravelInsuranceService` uses `@Inject var client: TravelInsuranceClient`.
- Key services: `TravelInsuranceClient` (protocol), `TravelInsuranceService` (wrapper)
- Data flow: `TravelCertificateNavigationViewModel` manages overall navigation state and holds child VMs (`StartDateViewModel`, `WhoIsTravelingViewModel`). The list screen fetches existing certificates and addon banners. The creation flow goes through start date -> who is traveling -> processing.

## Key Files
- Entry point / Navigation: `TravelCertificateNavigation` in `Sources/TravelCertificateNavigation.swift`
- Navigation VM: `TravelCertificateNavigationViewModel` in `Sources/TravelCertificateNavigation.swift`
- Service protocol: `TravelInsuranceClient` in `Sources/Service/Protocols/TravelInsuranceClient.swift`
- Service implementation: `TravelInsuranceService` in `Sources/Service/TravelInsuranceService.swift`
- Demo: `TravelInsuranceClientDemo` in `Sources/Service/DemoImplementation/TravelInsuranceClientDemo.swift`
- Screens: `TravelCertificatesListScreen`, `TravelCertificateSelectInsuranceScreen`, `StartDateScreen`, `WhoIsTravelingScreen`, `TravelCertificateProcessingScreen` in `Sources/Views/`
- Model: `TravelInsuranceContractSpecification` in `Sources/Models/TravelInsuranceContractSpecification.swift`

## Dependencies
- Imports: hCore, hCoreUI, Contracts, EditStakeholders, Addons (for `AddonSource`, `ChangeAddonInput`), PresentableStore
- Depended on by: Home, Profile, App

## Navigation
- `TravelCertificateNavigation`: Can operate with its own `RouterHost` or be embedded in an existing navigation stack (`useOwnNavigation` flag).
- The list screen is always the root. Creating a new certificate is presented modally via `.modally(item:)`.
- Routes: `TravelCertificateRouterActions` (whoIsTravelling, startDate, list) and `TravelCertificateRouterActionsWithoutBackButton` (processingScreen, startScreen).
- Integrates with Addons via `.handleAddons(input:)` modifier for travel addon upsell banners.
- PDF preview of existing certificates shown via `.detent`.
- Entered from Home and Profile modules.

## Gotchas
- This module imports `PresentableStore` to access `ContractStore` for providing existing stakeholders to `EditStakeholdersViewModel`. This is a legacy coupling that could be refactored.
- `whoIsTravelingViewModel` and `startDateViewModel` on the navigation VM are force-unwrapped when used in navigation destinations.
- The `TravelInsuranceClient.getList` method returns a tuple including addon banner data, coupling travel certificate listing with addon upsell logic.
