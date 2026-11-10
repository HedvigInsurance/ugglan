# ChangeTierCore

UI-free data layer for insurance tier changes: tier/quote models, flow input models, the client protocol, the demo
client and the service wrapper. No SwiftUI or hCoreUI.

## Key Files
- `Sources/Models/ChangeTierIntentModel.swift` — `ChangeTierIntentModel`, `ChangeTierIntentModelState`, `Tier`,
  `Quote` (+ `DisplayItem`, `Addon`), `AddonQuote`, `Deflection`, `ProductVariantComparison`
- `Sources/Models/ChangeTierInputData.swift` — `ChangeTierInputData` (single-contract flow input), `ChangeTierSource`,
  `ChangeTierContract` and `ChangeTierContractsInput` (multi-contract selection input, built by Home and App)
- `Sources/Service/Protocols/ChangeTierClient.swift` — client protocol and `ChangeTierError`
- `Sources/Service/ChangeTierService.swift` — logging wrapper (`@Log`) around `ChangeTierClient` (`@Inject`)
- `Sources/Service/DemoImplementation/` — `ChangeTierClientDemo` and its demo data

## Dependencies
- hCore (+ AutomaticLog)
- Depended on by: ChangeTierUI, TerminateContractsUI, MoveFlow, Home, App (`ChangeTierClientOctopus`,
  `MoveFlowClientOctopus`, DI)

## Gotchas
- `Deflection` here is ChangeTier's; SubmitClaimChat also has a `Deflection`, so files importing both must qualify it.

## Tests
- `ChangeTierServiceTests` (with `MockChangeTierService` in `Tests/MockData.swift` and `TierFixtures`)
