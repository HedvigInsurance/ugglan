# MoveFlowCore

UI-free data layer for the address change (moving) flow: configuration and quote models, the client protocol and its
inputs, and the demo client. No SwiftUI or hCoreUI.

## Key Files
- `Sources/Model/MoveConfigurationModel.swift` — `MoveConfigurationModel` (move intent configuration, limits per
  housing type), `MoveAddress`, `MovingFlowError`
- `Sources/Model/MoveQuotesModel.swift` — `MoveQuotesModel`, `MovingFlowQuote`, `InsuranceDocument`, `DisplayItem`,
  `AddonDataModel`
- `Sources/Model/HousingType.swift` — `HousingType`, `ExtraBuildingType`, `ExtraBuilding`
- `Sources/Service/Protocols/MoveFlowClient.swift` — `MoveFlowClient`, `MovingFlowSource`, `RequestMoveIntentInput`,
  `MoveAddressInput`, `MoveHouseInformationInput`, `GetMoveIntentCostInput`
- `Sources/Service/DemoImplementation/MoveFlowClientDemo.swift` — demo client used by previews

## Dependencies
- hCore, ChangeTierCore (`ChangeTierIntentModel` in `MoveQuotesModel`)
- Depended on by: MoveFlowUI, App (`MoveFlowClientOctopus`, DI)

## Gotchas
- `RequestMoveIntentInput` carries plain snapshots of the address and house forms (`MoveAddressInput`,
  `MoveHouseInformationInput`); MoveFlowUI builds them from `AddressInputModel` / `HouseInformationInputModel` when the
  intent is requested.
- No service wrapper and no test target; MoveFlowUI's view models call `MoveFlowClient` directly.
