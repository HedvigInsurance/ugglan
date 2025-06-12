import Addons
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingCentered: View {
    let crossSell: CrossSell

    public init(
        crossSell: CrossSell
    ) {
        self.crossSell = crossSell
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding48) {
                CrossSellBannerComponent()
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
        return CrossSellingCentered(
            crossSell: .init(
                id: "id",
                title: "Accident Insurance",
                description: "Help when you need it the most",
                type: .accident
            )
        )
    }
}
