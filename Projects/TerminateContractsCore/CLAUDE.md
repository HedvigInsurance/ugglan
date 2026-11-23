# TerminateContractsCore

UI-free data layer for the contract cancellation flow: termination models (`TerminationConfirmConfig`, survey,
suggestion and redirection models, `DeflectScreenContent`), the `TerminateContractsClient` protocol, the demo client and
the `TerminateContractsService` logging wrapper. No SwiftUI or hCoreUI.

## Dependencies
- hCore
- Depended on by: TerminateContractsUI, ContractsCore, ContractsUI, Home, App (`TerminateContractsClientOctopus`, DI)

## Gotchas
- `TerminationConfirmConfig` is built from a contract by ContractsCore's `Contract.asTerminationConfirmConfig`.
- `DeflectScreenContent.from(suggestion:)` maps auto-cancel / auto-decom suggestions to deflect screen content; it's
  covered by `DeflectScreenContentTests`.
- `TerminateContractsService.terminateContract` / `deleteContract` enforce a 3 s minimum duration
  (`Task.withMinimumDuration`) so the processing screen doesn't flash.
