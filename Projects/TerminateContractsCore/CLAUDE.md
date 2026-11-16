# TerminateContractsCore

UI-free data layer for the contract cancellation flow: termination models, the client protocol, the demo client and
the service wrapper. No SwiftUI or hCoreUI.

## Key Files
- `Sources/Models/TerminationConfig.swift` — `TerminationConfirmConfig` (per-contract flow input, built by Contracts'
  `asTerminationConfirmConfig`)
- `Sources/Models/TerminationFlowSurveyStepModel.swift` — `TerminationSurveyData`, `TerminationSurveyOption`,
  `TerminationSuggestion(Type)`, `TerminationRedirection`, `TerminationAction`, `TerminationContractResult`,
  `SurveyScreenSubtitleType`
- `Sources/Models/TerminationFlowDateNextStepModel.swift` — `ExtraCoverageItem`, `TerminationNotification`
- `Sources/Models/DeflectScreenContent.swift` — `DeflectScreenContent` and `DeflectScreenContent.from(suggestion:)`,
  which maps auto-cancel/auto-decom suggestions to deflect screen content
- `Sources/Service/Protocols/TerminateContractsClient.swift` — client protocol
- `Sources/Service/TerminateContractsService.swift` — logging wrapper around `TerminateContractsClient` (`@Inject`);
  terminate/delete calls enforce a 3 s minimum duration
- `Sources/Service/DemoImplementation/TerminateContractsClientDemo.swift` — demo client and `TerminationRedirection.mock`

## Dependencies
- hCore (+ AutomaticLog)
- Depended on by: TerminateContractsUI, Contracts, Home, App (`TerminateContractsClientOctopus`, DI)

## Tests
- `DeflectScreenContentTests`, `TerminationSuggestionTests`, `TerminateContractsTests` (service, with
  `MockTerminateContractsClient` in `Tests/MockData.swift`)
