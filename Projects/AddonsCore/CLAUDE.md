# AddonsCore

Data and domain layer for insurance addons: models, the client protocol, the `AddonsService` wrapper, and demo data. UI-free; depends only on `hCore`.

## Key Files
- `Sources/Models/AddonOffer.swift` — `AddonOffer`, `AddonContractQuote`, `ActiveAddon`, `AddonOfferContent`, `AddonOfferSelectable`, `AddonOfferToggleable`, `AddonOfferQuote`, `AddonContractInfo`, `AddonBanner`, `AddonDisplayItem`, `AddonDeflect`, `AddonOfferData`.
- `Sources/Models/AddonRemoveOffer.swift` — `AddonRemoveOffer`, `RemoveAddonInput`, `AddonRemoveOfferWithSelectedItems`.
- `Sources/Models/ChangeAddonInput.swift` — `ChangeAddonInput` and `AddonSource`.
- `Sources/Service/Protocols/AddonsClient.swift` — `AddonsClient` protocol + `AddonsError`.
- `Sources/Service/AddonsService.swift` — `@MainActor` wrapper with `@Inject var client: AddonsClient` and `@Log` on every call.
- `Sources/Service/DemoImplementation/` — `AddonsClientDemo` and the shared demo/test fixtures (`testTravelOffer45Days`, `testAddonBanner`, …).

## Dependencies
- `hCore`
- Octopus impl lives in `Projects/App/Sources/Service/OctopusClientsImplementation/AddonsClientOctopus.swift`.

## Consumers
- `AddonsUI` (views, navigation and ViewModels built on top)
- `App` (DI registration, Octopus impl)
- `Contracts`, `CrossSellCore`, `TravelCertificate`, `Home`, `Chat` (models such as `AddonBanner`, `AddonSource`, `AddonContractInfo`)

## Gotchas
- `AddonSource` raw values mirror Android's `AddonBannerSource` so the Datadog `flow` attribute is queryable across platforms — don't rename them.
- `AddonsService.submitAddons` and `confirmAddonRemoval` run the network call inside `Task.withMinimumDuration(.seconds(3))`, so the processing screen shows for a minimum duration.
- ViewModels are in `AddonsUI`, not here, because they build hCoreUI types (`QuoteDisplayItem`, `QuoteSummary`).
- `AddonBanner.AddonType.pillowType` maps to hCore `PillowType`; render it with hCoreUI `AddonPillowView(pillow:)`
