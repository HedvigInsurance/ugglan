import Addons
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingModal: View {
    @PresentableStore var store: CrossSellStore
    let crossSell: CrossSell

    public init(
        crossSellInfo: CrossSellInfo
    ) {
        self.crossSell =
            crossSellInfo.crossSell
            ?? .init(
                title: "Accident Insurance",
                description: "Help when you need it the most",
                type: .accident
            )
        Task {
            try await Task.sleep(nanoseconds: 200_000_000)
            crossSellInfo.logCrossSellEvent()
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            CrossSellBannerComponent(crossSell: crossSell)
            hForm {
                VStack(spacing: .padding48) {
                    CrossSellPillowComponent(crossSell: crossSell)
                    CrossSellButtonComponent(crossSell: crossSell)
                    CrossSellingStack(withHeader: true)
                }
                .padding(.bottom, .padding16)
            }
            .withDismissButton()
            .embededInNavigation(tracking: self)
        }
        .task {
            store.send(.fetchAddonBanner)
        }
    }
}

extension CrossSellingModal: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return "CrossSellingModal"
    }
}

struct CrossSellingModal_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
        return CrossSellingModal(crossSellInfo: .init(type: .home))
    }
}
