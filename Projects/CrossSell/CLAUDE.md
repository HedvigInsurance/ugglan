# CrossSell

Handles cross-selling of additional insurance products and addon banners. Fetches recommended and other cross-sell offers from the backend and displays them in various presentation formats (modal, centered, detent, banner).

## Key Files
- `Sources/Service/CrossSellClient.swift` — `CrossSellClient` protocol; defines `getCrossSell` and `getAddonBanners`
- `Sources/Service/CrossSellService.swift` — Service wrapper using `@Inject` to resolve the client
- `Sources/Store/CrossSellStore.swift` — `AppStore` managing cross-sell and addon banner state; async methods `fetchCrossSell`, `fetchAddonBanners`, `fetchRecommendedCrossSellId`
- `Sources/Models/CrossSellModels.swift` — `CrossSells` and `CrossSell` data models
- `Sources/View/CrossSellingView.swift` — Main view; observes the store via `@AppObservedObject`
- `Sources/View/Components/` — UI components: banner, button, pillow, stack, discount progress

## Dependencies
- hCore, hCoreUI, AppStateContainer, Addons

## Gotchas
- `CrossSellSource` enum controls context-dependent fetching (home, closedClaim, insurances, etc.)
- Tracks "new recommended" cross-sell state by comparing product IDs across fetches; the last-seen ID is persisted in `UserDefaults` (not the `@PersistableStore` snapshot)
- Demo client at `Sources/Service/CrossSellClientDemo.swift`
