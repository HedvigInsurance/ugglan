# InsuranceEvidence

Lets members request an insurance evidence (certificate) by email: an email input form, then a processing screen
that submits the request.

## Architecture
- `InsuranceEvidenceNavigation` (public) is the only entry point. Its `InsuranceEvidenceNavigationViewModel` owns the
  router, the `InsuranceEvidenceService` and the input screen's ViewModel.
- `InsuranceEvidenceService` wraps the `InsuranceEvidenceClient` (`getInitialData`, `canCreateInsuranceEvidence`,
  `createInsuranceEvidence`). The client protocol and demo live in `Service/Client/`, not the usual
  `Service/Protocols/` / `Service/DemoImplementation/`.
- No `AppStore`. Whether the entry point is shown comes from Profile (`ProfileStore.canCreateInsuranceEvidence`).

## Dependencies
- hCore, hCoreUI
- Depended on by: Profile, App (`InsuranceEvidenceClientOctopus`, deep-link presentation)
