# Campaign

Displays discount codes, bundle discounts, and referral ("Forever") rewards on the payments screen. Fetches discount data via `hCampaignService` and renders per-insurance discount lists alongside referral summaries.

## Key Files
- `Views/DiscountsView.swift` — Main UI; lists discounts per insurance and referrals
- `Store/CampaignStore.swift` — PresentableStore that fetches and holds `PaymentDiscountsData`
- `Models/PaymentDiscountsData.swift` — Data models (`Discount`, `Referral`, `ReferralsData`)
- `Navigation/CampaignNavigation.swift` — Entry point; routes to the Forever (referrals) flow

## Dependencies
- `hCore`, `hCoreUI`, `PresentableStore`
- `Forever` (referral invite flow, navigated to from the discounts screen)

## Gotchas
- `Discount.id` is generated via `UUID()` at init time, so two instances with the same `code` are not equal by `id`.
