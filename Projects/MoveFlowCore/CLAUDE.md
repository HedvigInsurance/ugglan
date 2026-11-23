# MoveFlowCore

UI-free data layer for the address change (moving) flow: configuration and quote models (`MoveConfigurationModel`,
`MoveQuotesModel`, `HousingType`), the `MoveFlowClient` protocol with its request inputs, and the demo client.
No SwiftUI or hCoreUI.

## Dependencies
- hCore, ChangeTierCore (`ChangeTierIntentModel` in `MoveQuotesModel`)
- Depended on by: MoveFlowUI, App (`MoveFlowClientOctopus`, DI)

## Gotchas
- `RequestMoveIntentInput` carries plain snapshots of the address and house forms (`MoveAddressInput`,
  `MoveHouseInformationInput`). MoveFlowUI builds them from `AddressInputModel` / `HouseInformationInputModel` when
  the intent is requested.
- No service wrapper and no test target; MoveFlowUI's ViewModels call `MoveFlowClient` directly via `@Inject`.
