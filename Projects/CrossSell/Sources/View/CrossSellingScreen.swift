import Addons
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingScreen: View {
    @EnvironmentObject private var router: Router
    @PresentableStore var store: CrossSellStore

    public init(
        info: CrossSellInfo
    ) {
        Task {
            try await Task.sleep(nanoseconds: 200_000_000)
            info.logCrossSellEvent()
        }
    }

    public var body: some View {
        bannerView
            .ignoresSafeArea(edges: .vertical)
        VStack(spacing: 0) {
            hForm {
                CrossSellingStack(withHeader: false)
                    .padding(.bottom, .padding8)
            }
        }
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
        .embededInNavigation(
            tracking: self
        )
    }

    @ViewBuilder
    private var bannerView: some View {
        HStack(alignment: .top, spacing: .padding8) {
            hCoreUIAssets.campaign.view
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(hSignalColor.Green.element)
            hText(L10n.crossSellBannerText, style: .label)
                .foregroundColor(hSignalColor.Green.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .background(hSignalColor.Green.fill)
    }
}

extension CrossSellingScreen: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: self)
    }
}

struct CrossSellingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
        return CrossSellingScreen(info: .init(type: .home))
    }
}
