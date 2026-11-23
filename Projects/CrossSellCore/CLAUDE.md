# CrossSellCore

UI-free data layer for cross-selling insurance products and addon banners: models, `CrossSellClient`,
`CrossSellService`, `CrossSellStore`, demo data and Firebase cross-sell tracking. No SwiftUI or hCoreUI.

## Architecture
- `CrossSellStore` (`@PersistableStore` `AppStore`) has three fetches: `fetchCrossSell` (Insurances tab, fills
  `crossSells`), `fetchHomeCrossSells` (`HOME_X_SELL` flow, fills `homeCrossSells` and derives `hasNewOffer`) and
  `fetchAddonBanners`.
- `CrossSellSource` tells the backend where an offer is shown (home, closed claim, change tier, moving flow,
  insurances, onboarding…). `CrossSellInfo` carries the source and extra info when a cross-sell is presented.

## Dependencies
- hCore, AddonsCore
- Depended on by: CrossSellUI, App (DI, `CrossSellClientOctopus`), ChangeTierUI, Chat, Claims, ContractsUI, Home,
  MoveFlowUI, Onboarding

## Gotchas
- `hasNewOffer` compares the recommended product ID against the last-seen ID. That ID is stored in `UserDefaults`, not
  in the `@PersistableStore` snapshot.
- Event names and parameters in `CrossSellTracking.swift` match Android's, so one analytics query covers both apps.
  Don't rename them.
- `CrossSellShownTracker` dedupes `shown` events per visit. Pair it with CrossSellUI's `onCrossSellShown`.
- `Tests/Experiments/` holds hCore feature-flag tests from before the split. They test hCore, not cross-sell.
