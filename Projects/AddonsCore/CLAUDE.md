# AddonsCore

UI-free data layer for insurance addons: offer/removal models, the `AddonsClient` protocol, the `AddonsService`
logging wrapper, and demo data (`AddonsClientDemo` plus shared fixtures such as `testTravelOffer45Days`).

## Dependencies
- hCore. Octopus impl: `AddonsClientOctopus` in App.
- Depended on by: AddonsUI, App, Chat, ContractsCore, ContractsUI, CrossSellCore, CrossSellUI, Home,
  TravelCertificate (mostly for `AddonBanner`, `AddonSource`, `AddonContractInfo`)

## Gotchas
- `AddonSource` raw values mirror Android's `AddonBannerSource` so the Datadog `flow` attribute is queryable across
  platforms — don't rename them.
- `submitAddons` and `confirmAddonRemoval` wrap the call in `Task.withMinimumDuration(.seconds(3))` so the processing
  screen is shown for a minimum time.
- ViewModels live in AddonsUI because they build hCoreUI types (`QuoteDisplayItem`, `QuoteSummary`).
- `AddonBanner.AddonType.pillowType` maps to hCore `PillowType`; render it with hCoreUI `AddonPillowView(pillow:)`.
