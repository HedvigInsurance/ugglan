# CrossSellUI

SwiftUI views for cross-sell offers and addon banners, built on CrossSellCore. Offers can be shown as a modal,
centered, a detent, a banner or rows.

## Architecture
- `CrossSellingView` observes `CrossSellStore` through `@AppObservedObject`. The presentation formats
  (`CrossSellingModal`, `CrossSellingCentered`, `CrossSellingDetent`) wrap it.
- `CrossSellRow` is the shared pillow-row shell. Home's addon section uses it too.
- `View.onCrossSellShown(perform:)` fires once at least half the view has been visible for 0.5 seconds. Dedupe with
  `CrossSellShownTracker` from CrossSellCore.

## Dependencies
- hCore, hCoreUI, AddonsCore, CrossSellCore
- Depended on by: App, Chat, ContractsUI, Home, Onboarding

## Gotchas
- There's no test target. All cross-sell logic lives in CrossSellCore and is tested there.
