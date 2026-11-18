# ChangeMileageUI

SwiftUI flow built on `ChangeMileageCore` for changing the yearly mileage of a car insurance: pick a mileage band,
review the summary, commit.

## Architecture
- Pattern: ViewModel (`@MainActor @Observable class`). `ChangeMileageViewModel` loads the intent through
  `ChangeMileageService`, holds the selected quote and commits it. `ChangeMileageNavigationViewModel` owns the router,
  the picker detent and the "how far do I drive" info detent.

## Key Files
- Entry point: `ChangeMileageNavigation` in `Sources/Navigation/ChangeMileageNavigation.swift`, taking a
  `ChangeMileageInput`; with more than one contract it starts on `SelectMileageInsuranceScreen`
- Screens: `ChangeMileageLandingScreen`, `MileagePickerScreen`, `ChangeMileageSummaryScreen`,
  `ChangeMileageProcessingScreen` in `Sources/Views/`

## Dependencies
- Imports: hCore, hCoreUI, ChangeMileageCore
- Depended on by: ContractsUI (edit contract sheet), App (`change-mileage` deep link)

## Gotchas
- The lower-mileage notice is decided on the client (`isLowerThanCurrentSelected`), the API has no message for it.
- A successful commit posts `.mileageChanged`, which App observes to refetch contracts.
- Copy is hardcoded with Lokalise TODOs until the keys exist.
