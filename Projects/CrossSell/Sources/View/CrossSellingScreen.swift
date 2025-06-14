import Addons
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingScreen: View {
    @EnvironmentObject private var router: Router
    @PresentableStore var store: CrossSellStore
    let addonCardOnClick: (_ contractIds: [String]) -> Void

    public init(
        addonCardOnClick: @escaping (_ contractIds: [String]) -> Void,
        info: CrossSellInfo
    ) {
        self.addonCardOnClick = addonCardOnClick
        Task {
            try await Task.sleep(nanoseconds: 200_000_000)
            info.logCrossSellEvent()
        }
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
        .configureTitleView(title: L10n.crossSellSubtitle)
        .hFormAttachToBottom {
            hSection {
                hCloseButton {
                    router.dismiss()
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
}

struct CrossSellingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
        return CrossSellingScreen(addonCardOnClick: { _ in }, info: .init(type: .home))
    }
}
