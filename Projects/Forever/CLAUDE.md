# Forever

The referral program module. Displays a user's referral code, discount information, pie chart visualization of discounts, and a list of referred friends with their statuses. Users can share their referral code and change it.

## Architecture
- Pattern: ViewModel (`@MainActor class: ObservableObject`) with `@Inject`. `ForeverNavigationViewModel` uses `@Inject var foreverService: ForeverClient`.
- Key services: `ForeverClient` (protocol)
- Data flow: `ForeverNavigationViewModel` fetches referral data via `ForeverClient`, stores it as `ForeverData`, and manages change-code presentation state. `ForeverView` observes the VM via `@EnvironmentObject` and renders header, discount code section, and invitation table.

## Key Files
- Entry point: `ForeverNavigation` in `Sources/Navigation/ForeverNavigation.swift`
- Main view: `ForeverView` in `Sources/Forever.swift`
- ViewModel: `ForeverNavigationViewModel` in `Sources/Navigation/ForeverNavigation.swift`
- Service protocol: `ForeverClient` in `Sources/Service/Protocols/ForeverClient.swift`
- Demo: `ForeverClientDemo` in `Sources/Service/DemoImplementation/ForeverClientDemo.swift`
- Model: `ForeverData`, `Referral` in `Sources/Models/ForeverModel.swift`
- Components: `HeaderView` (`Sources/Header.swift`), `InvitationTable` (`Sources/Components/InivtationTable.swift`), `PieChartView` (`Sources/Components/PieChart/`), `PriceSectionView` (`Sources/Components/PriceSectionView.swift`), `DiscountCodeSection` (`Sources/DiscountCodeSection.swift`), `ChangeCodeView` (`Sources/ChangeCodeView.swift`)

## Dependencies
- Imports: hCore, hCoreUI, Environment
- Depended on by: Payment, Campaign, App

## Navigation
- `ForeverNavigation`: Can operate with its own `RouterHost` or be embedded (`useOwnNavigation` flag). Receives a `Router` via `@EnvironmentObject`.
- Change code flow presented as a detent with its own embedded navigation and router.
- Routes: `ForeverRouterActions.success` for the success screen after code change.
- Sharing uses `UIActivityViewController` via `ModalPresentationSourceWrapperViewModel`.
- Entered from the main tab bar (via App) and referenced by Payment and Campaign modules.

## Gotchas
- The `ForeverView` uses manual height calculations with `GeometryReader` to manage spacing between the header, discount code section, and invitation table. This creates complexity in layout logic.
- The file `InivtationTable.swift` has a typo in its name (should be "Invitation").
- `ForeverData.discountCode` is a `var` (mutable) while other properties are `let`, with a dedicated `updateDiscountCode` mutating method.
