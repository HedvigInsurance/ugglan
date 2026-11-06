# CrossSellCore

Data and domain layer for cross-selling additional insurance products and addon banners: models, the client protocol, the `CrossSellService` wrapper, the `CrossSellStore`, demo data and Firebase cross-sell tracking. UI-free; depends only on `hCore` and `AddonsCore`.

## Key Files
- `Sources/Models/CrossSellModels.swift` — `CrossSells`, `CrossSell`, `RecommendedCrossSell` and `AddonCrossSell` data models
- `Sources/Models/CrossSellInfo.swift` — `CrossSellInfo` (source + extra info passed when presenting a cross-sell, logged to Datadog)
- `Sources/Service/CrossSellClient.swift` — `CrossSellClient` protocol (`getCrossSell`, `getAddonBanners`) and `CrossSellSource`
- `Sources/Service/CrossSellService.swift` — Service wrapper using `@Inject` to resolve the client
- `Sources/Service/CrossSellClientDemo.swift` — Demo client
- `Sources/Store/CrossSellStore.swift` — `AppStore` managing cross-sell and addon banner state; async methods `fetchCrossSell` (Insurances tab flow, fills `crossSells`), `fetchHomeCrossSells` (`HOME_X_SELL` flow, fills `homeCrossSells` and derives `hasNewOffer`), `fetchAddonBanners`
- `Sources/Tracking/CrossSellTracking.swift` — `CrossSellEvent`, `CrossSell.track(_:)` / `openStore()` and the Firebase parameters
- `Sources/Tracking/CrossSellShownTracker.swift` — Dedupes `shown` events per visit (pair it with CrossSellUI's `onCrossSellShown`)

## Dependencies
- hCore, AppStateContainer, AddonsCore
- Octopus impl lives in `Projects/App/Sources/Service/OctopusClientsImplementation/CrossSellClientOctopus.swift`.

## Consumers
- `CrossSellUI` (views built on top)
- `App` (DI registration, Octopus impl)
- `ChangeTier`, `Claims`, `MoveFlow` (`CrossSellInfo`), `Chat` (`CrossSellClient`, `CrossSellShownTracker`), `Contracts`, `Home`, `Onboarding`

## Gotchas
- `CrossSellSource` enum controls context-dependent fetching (home, closedClaim, insurances, etc.)
- Tracks "new recommended" cross-sell state by comparing product IDs across fetches; the last-seen ID is persisted in `UserDefaults` (not the `@PersistableStore` snapshot)
- Event names and parameters in `CrossSellTracking.swift` match Android's, so one analytics query covers both apps — don't rename them.
- `Tests/Experiments/` holds hCore feature-flag tests that predate the split; they test hCore, not cross-sell.
