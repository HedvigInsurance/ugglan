# CampaignUI

SwiftUI views and navigation for the discounts/referrals screen. Sits on top of `CampaignCore`.

## Key Files
- `Sources/Views/DiscountsView.swift` — `DiscountsView` (per-insurance discounts + referrals list) and `PaymentsDiscountsRootView` (drives the VM, handles loading/error states).
- `Sources/Views/DiscountDetailView.swift` — Single discount row.
- `Sources/Navigation/CampaignNavigation.swift` — Entry point view; routes to the Forever (referrals) flow via `CampaignRouterAction`.

## Dependencies
- `CampaignCore`, `hCore`, `hCoreUI`
- `Forever` (referral invite flow, navigated to from the discounts screen)

## Consumers
- `App` (presented from the Payments tab via `CampaignNavigation`)
- `Payment` (routes to `CampaignNavigation` from the discounts row in payments)
