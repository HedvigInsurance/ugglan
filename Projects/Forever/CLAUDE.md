# Forever

The referral program: shows the member's referral code, discount information, a pie chart of earned discounts and a
list of referred friends with their status. Members can share their code and change it.

## Architecture
- `ForeverNavigationViewModel` fetches `ForeverData` through `@Inject var foreverService: ForeverClient` and holds the
  change-code presentation state. `ForeverView` reads the ViewModel from the environment.
- The change-code flow is a detent with its own `NavigationRouter`. `ForeverRouterActions.success` shows the success
  screen.
- Sharing uses `ModalPresentationSourceWrapper` (hCoreUI) so the share sheet anchors to the button.

## Entry points
- `ForeverNavigation(useOwnNavigation:)`: App shows it as the Forever tab (`true`, which creates its own
  `hNavigationStack`) and as a large detent (`false`, which uses the `NavigationRouter` from the environment).
  CampaignUI also embeds it.

## Dependencies
- hCore, hCoreUI, Environment (web base URL for the share link)
- Depended on by: App, CampaignUI, Onboarding (`ForeverData` for the invite step)

## Gotchas
- `ForeverView` uses several `GeometryReader`s to manually space the header, discount code section and invitation
  table.
- The file name `Components/InivtationTable.swift` has a typo, so search for "Inivtation" when looking for it.
- `ForeverData.discountCode` can only be changed through `updateDiscountCode(_:)`. The other properties are `let`.
