import Addons
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingCentered: View {
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
        hForm {
            VStack(spacing: .padding48) {
                CrossSellBannerComponent(crossSell: crossSell)
                CrossSellPillowComponent(crossSell: crossSell)
                CrossSellButtonComponent(crossSell: crossSell)
            }
            .padding(.bottom, .padding16)
        }
        .hFormContentPosition(.compact)
    }
}

struct CrossSellingCentered_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
        return CrossSellingCentered(crossSellInfo: .init(type: .home))
    }
}
