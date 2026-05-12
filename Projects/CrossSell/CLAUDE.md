# CrossSell

Handles cross-selling of additional insurance products and addon banners. Fetches recommended and other cross-sell offers from the backend and displays them in various presentation formats (modal, centered, detent, banner).

## Key Files
- `Sources/Service/CrossSellClient.swift` — `CrossSellClient` protocol; defines `getCrossSell` and `getAddonBanners`
- `Sources/Service/CrossSellService.swift` — Service wrapper using `@Inject` to resolve the client
- `Sources/Store/CrossSellStore.swift` — PresentableStore managing cross-sell and addon banner state
- `Sources/Models/CrossSellModels.swift` — `CrossSells` and `CrossSell` data models
- `Sources/View/CrossSellingView.swift` — Main view using `PresentableStoreLens` to render cross-sell items
- `Sources/View/Components/` — UI components: banner, button, pillow, stack, discount progress

## Dependencies
- hCore, hCoreUI, Addons

## Gotchas
- Uses **PresentableStore** (legacy pattern) via `CrossSellStore` and `@PresentableStore` property wrapper
- `CrossSellSource` enum controls context-dependent fetching (home, closedClaim, insurances, etc.)
- Tracks "new recommended" cross-sell state by comparing product IDs across fetches
- Demo client at `Sources/Service/CrossSellClientDemo.swift`
