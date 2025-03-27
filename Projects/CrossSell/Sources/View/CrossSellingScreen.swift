import Addons
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct CrossSellingScreen: View {
    @EnvironmentObject private var router: Router
    @PresentableStore var store: CrossSellStore
    let addonCardOnClick: (_ contractIds: [String]) -> Void

    public init(
        addonCardOnClick: @escaping (_ contractIds: [String]) -> Void,
        claimInfo: CrossSellClaimInfo?
    ) {
        self.addonCardOnClick = addonCardOnClick
        logCrossSellEvent(claimInfo: claimInfo)
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding24) {
                CrossSellingStack(withHeader: false)
                addonBanner
            }
            .padding(.bottom, .padding8)
        }
        .hFormContentPosition(.compact)
        .configureTitleView(title: L10n.crossSellTitle, subTitle: L10n.crossSellSubtitle)
        .hFormAttachToBottom {
            hSection {
                hButton.LargeButton(type: .ghost) {
                    router.dismiss()
                } content: {
                    hText(L10n.generalCloseButton)
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
        .task {
            store.send(.fetchAddonBanner)
        }
    }

    @ViewBuilder
    private var addonBanner: some View {
        PresentableStoreLens(
            CrossSellStore.self,
            getter: { state in
                state.addonBanner
            }
        ) { banner in
            if let banner {
                hSection {
                    AddonCardView(
                        openAddon: {
                            addonCardOnClick(banner.contractIds)
                        },
                        addon: banner
                    )
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }

    private func logCrossSellEvent(claimInfo: CrossSellClaimInfo?) {
        log.addUserAction(
            type: .custom,
            name: "cross sell",
            error: nil,
            attributes: ["claim info": claimInfo]
        )
    }
}

public struct CrossSellClaimInfo: Codable, Equatable, Identifiable {
    public let id: String
    let type: String
    let status: String
    let outcome: String
    let submittedAt: String?
    public let payoutAmount: MonetaryAmount?

    public init(
        id: String,
        type: String,
        status: String,
        outcome: String,
        submittedAt: String?,
        payoutAmount: MonetaryAmount?
    ) {
        self.id = id
        self.type = type
        self.status = status
        self.outcome = outcome
        self.submittedAt = submittedAt
        self.payoutAmount = payoutAmount
    }
}

struct CrossSellingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
        return CrossSellingScreen(addonCardOnClick: { _ in }, claimInfo: nil)
    }
}
