# CampaignCore

UI-free layer for discounts and referrals: models (`PaymentDiscountsData`, `Discount`, `Referral`, …), the
`hCampaignClient` protocol, the `hCampaignService` wrapper, the demo client, and `PaymentsDiscountsRootViewModel`,
which drives the discounts screen.

## Dependencies
- hCore. Octopus impl: `hCampaignsClientOctopus` in App.
- Depended on by: CampaignUI, App, Payment (`Discount` in `PaymentData`)

## Gotchas
- `Discount.id` is a fresh `UUID().uuidString` on every init and `==` compares only `id`, so two discounts with the
  same code are never equal.
- `Discount.init(referral:)` is `@MainActor` because it formats a monetary amount.
