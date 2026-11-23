# MoveFlowUI

SwiftUI address change (moving) flow built on `MoveFlowCore`: select contract, housing type, new address, house
details (incl. extra buildings), choose tier/deductible for the new address, confirm and process.

## Architecture
- `MovingFlowNavigationViewModel` is the central VM: it fetches the move intent configuration, holds the address and
  house form models, tracks quote selection and talks to `MoveFlowClient` via `@Inject` (no service wrapper).
- `AddressInputModel` / `HouseInformationInputModel` are the form ViewModels; `asMoveAddressInput` /
  `asMoveHouseInformationInput` turn them into MoveFlowCore's request inputs.
- `MovingFlowQuoteManager` builds the quote summary and updates quote costs.
- Tier selection reuses ChangeTierUI: `MovingFlowNavigationViewModel` conforms to `ChangeTierQuoteDataProvider`, and
  `ChangeTierNavigation` is pushed inside the move flow's own router (embedded, not a separate stack).

## Entry points
- `MovingFlowNavigation(onMoved:)`, presented by App (`LoggedInNavigation`). `onMoved` fires from `.onDeinit` when the
  flow is dismissed.
- The first screen is contract selection when the member has more than one current home address, otherwise
  housing type selection.

## Dependencies
- hCore, hCoreUI, MoveFlowCore, CrossSellCore, ChangeTierCore, ChangeTierUI (+ CoreDependencies)
- Depended on by: App

## Gotchas
- `MovingFlowNavigation.swift` holds the navigation VM, `MovingFlowQuoteManager`, the view and all route enums.
- `movingFlowConfirmViewModel` and `totalPremium` are force-unwrapped in the navigation; they're set before the
  routes that use them are pushed.
