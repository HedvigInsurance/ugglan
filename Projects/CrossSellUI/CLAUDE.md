# CrossSellUI

SwiftUI views for cross-sell offers and addon banners, built on `CrossSellCore`. Presents offers in several formats (modal, centered, detent, banner, rows).

## Key Files
- `Sources/View/CrossSellingView.swift` — Main view; observes `CrossSellStore` via `@AppObservedObject`
- `Sources/View/CrossSellingModal.swift`, `CrossSellingCentered.swift`, `CrossSellingDetent.swift` — Presentation formats
- `Sources/View/CrossSellingItem.swift` — Single offer row
- `Sources/View/Components/` — banner, button, pillow, stack, discount progress, addons section, and `CrossSellRow` (shared pillow-row shell, also used by Home's addon section)
- `Sources/Tracking/CrossSellShownModifier.swift` — `View.onCrossSellShown(perform:)`, fires once half the view has been visible for 0.5s; dedupe with `CrossSellShownTracker` from CrossSellCore

## Dependencies
- hCore, hCoreUI, AddonsCore, CrossSellCore
- Depended on by: App, Chat, Contracts, Home, Onboarding

## Gotchas
- No test target: all cross-sell logic is in CrossSellCore and tested there.
