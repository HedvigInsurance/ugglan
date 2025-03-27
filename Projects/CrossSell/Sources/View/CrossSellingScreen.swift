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
        fromClaimId: String?
    ) {
        self.addonCardOnClick = addonCardOnClick
        logCrossSellEvent(claimId: fromClaimId)
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

    private func logCrossSellEvent(claimId: String?) {
        log.addUserAction(
            type: .custom,
            name: "cross sell",
            error: nil,
            attributes: ["claim id": claimId]
        )
    }
}

struct CrossSellingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
        return CrossSellingScreen(addonCardOnClick: { _ in }, fromClaimId: "claim id")
    }
}
