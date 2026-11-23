# CampaignUI

SwiftUI screens for discounts and referrals (`PaymentsDiscountsRootView`, `DiscountsView`, `DiscountDetailView`),
built on CampaignCore.

## Entry points
- `CampaignNavigation` is pushed inside Payment's navigation stack (`PaymentsNavigation`); it doesn't create its own
  `hNavigationStack`. Pushing `CampaignRouterAction.forever` opens `ForeverNavigation(useOwnNavigation: false)` in
  the same stack.

## Dependencies
- hCore, hCoreUI, CampaignCore, Forever
- Depended on by: Payment (App links it through Project.swift but doesn't import it)
