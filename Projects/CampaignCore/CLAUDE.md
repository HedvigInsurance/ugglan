# CampaignCore

Data and domain layer for discounts/referrals: models, service protocol, and the discounts root ViewModel. UI-free; depends only on `hCore`.

## Key Files
- `Sources/Models/PaymentDiscountsData.swift` — `PaymentDiscountsData`, `DiscountsDataForInsurance`, `Discount`, `Referral`, `ReferralsData`, `DiscountType`, `DiscountStatus`.
- `Sources/Service/CampaignClient.swift` — `hCampaignClient` protocol + `CampaignError`.
- `Sources/Service/hCampaignService.swift` — Thin `hCampaignService` wrapper with `@Inject` of `hCampaignClient`.
- `Sources/Service/DemoImplementation/CampaignClientDemo.swift` — `hCampaignClientDemo` static demo data.
- `Sources/ViewModels/PaymentsDiscountsRootViewModel.swift` — `@MainActor` ObservableObject driving the discounts root screen (loads via `hCampaignService`, exposes `ProcessingState` from `hCore`).

## Dependencies
- `hCore`
- Octopus impl lives in `Projects/App/Sources/Service/OctopusClientsImplementation/CampaignsClientOctopus.swift`.

## Consumers
- `CampaignUI` (views + navigation built on top)
- `App` (DI registration, Octopus impl)
- `Payment` (uses `Discount` in `PaymentData`)

## Gotchas
- `Discount.id` is `UUID()` at init time, so two instances with the same `code` are not equal by `id`.
- `Discount.init(referral:)` is `@MainActor` because it formats a monetary amount.
