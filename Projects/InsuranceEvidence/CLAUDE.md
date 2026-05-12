# InsuranceEvidence

Allows users to request insurance evidence/certificates by entering their email. Handles the input form, submission, and processing states.

## Key Files
- `Sources/Service/Client/InsuranceEvidenceClient.swift` — `InsuranceEvidenceClient` protocol with `getInitialData`, `canCreateInsuranceEvidence`, `createInsuranceEvidence`
- `Sources/Service/InsuranceEvidenceService.swift` — Service wrapper using `@Inject` to resolve the client
- `Sources/Views/InsuranceEvidenceNavigation.swift` — Navigation root; `InsuranceEvidenceNavigationViewModel` owns the router and service
- `Sources/Views/InsuranceEvidenceInputScreen.swift` — Email input form with `InsuranceEvidenceInputScreenViewModel`
- `Sources/Views/InsuranceEvidenceProcessingScreen.swift` — Processing/loading screen shown after submission
- `Sources/Models/InsuranceEvidenceInput.swift` — Input model (email)
- `Sources/Models/InsuranceEvidenceInitialData.swift` — Data model for pre-populated form data

## Dependencies
- hCore, hCoreUI

## Gotchas
- Uses the modern ViewModel pattern (`@MainActor class: ObservableObject`) with `@Inject` services; no PresentableStore
- Navigation is managed by `InsuranceEvidenceNavigationViewModel` which owns a `Router` and coordinates between screens
- Demo client at `Sources/Service/Client/InsuranceEvidenceClientDemo.swift`
