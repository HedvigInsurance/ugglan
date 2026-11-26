# TravelCertificateCore

UI-free data layer for travel insurance certificates: the certificate and specification models, the client protocol,
the service wrapper and the demo client. No SwiftUI or hCoreUI.

## Key Files
- `Sources/Models/TravelInsuranceContractSpecification.swift` — `TravelInsuranceContractSpecification`,
  `PolicyCoinsuredPersonModel`, `TravelCertificateModel`
- `Sources/Service/Protocols/TravelInsuranceClient.swift` — `TravelInsuranceClient`, `TravelInsuranceFormDTO`,
  `CoInsuredDto`, `TravelInsuranceError`
- `Sources/Service/TravelInsuranceService.swift` — logging wrapper around `TravelInsuranceClient` (`@Inject`)
- `Sources/Service/DemoImplementation/TravelInsuranceClientDemo.swift` — demo client used by previews

## Dependencies
- hCore, AddonsCore (`AddonSource`, `AddonBanner`)
- Depended on by: TravelCertificateUI, App (`TravelInsuranceClientOctopus`, DI)

## Gotchas
- No test target: the client and list view model tests share one serialized suite in TravelCertificateUITests.
