# ChangeMileageCore

UI-free data layer for changing the yearly mileage of a car insurance: models, the client protocol, the demo client
and the service wrapper. No SwiftUI or hCoreUI.

## Key Files
- `Sources/Models/ChangeMileageModels.swift` — `ChangeMileageIntent`, `MileageQuote`, `MileageDisplayItem`,
  `ChangeMileageContract` and `ChangeMileageInput` (one contract, or several to choose from)
- `Sources/Service/Protocols/ChangeMileageClient.swift` — client protocol and `ChangeMileageError`
- `Sources/Service/ChangeMileageService.swift` — logging wrapper (`@Log`) around `ChangeMileageClient` (`@Inject`)
- `Sources/Service/DemoImplementation/ChangeMileageClientDemo.swift` — the five mileage bands, 1 500 mil current

## Dependencies
- hCore (+ AutomaticLog)
- Depended on by: ChangeMileageUI, ContractsUI, App (`ChangeMileageClientOctopus`, DI)

## Gotchas
- The current quote's `id` is the id of the agreement being changed, not a quote; it must never be committed.
- `quotes` are sorted ascending by mileage, which is what the lower-mileage notice relies on.

## Tests
- `ChangeMileageServiceTests` (with `MockChangeMileageClient` and `MileageFixtures` in `Tests/MockData.swift`)
