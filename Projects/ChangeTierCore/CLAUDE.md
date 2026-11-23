# ChangeTierCore

UI-free data layer for insurance tier changes: tier/quote models (`ChangeTierIntentModel`, `Tier`, `Quote`,
`Deflection`, …), flow inputs (`ChangeTierInputData`, `ChangeTierContractsInput`), the `ChangeTierClient` protocol,
the `ChangeTierService` logging wrapper and the demo client.

## Dependencies
- hCore. Octopus impl: `ChangeTierClientOctopus` in App.
- Depended on by: ChangeTierUI, TerminateContractsUI, MoveFlowCore, MoveFlowUI, Home, App

## Gotchas
- SubmitClaimChat also defines a `Deflection`, so files that import both modules must qualify the name.
- `Tests/MockData.swift` and `Tests/TierFixtures.swift` are also compiled into ChangeTierUI's tests
  (`sharedTestSources` in ChangeTierUI's `Project.swift`).
