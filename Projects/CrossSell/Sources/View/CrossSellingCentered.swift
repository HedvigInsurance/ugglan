import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingCentered: View {
    private let crossSell: CrossSell

    public init(
        crossSell: CrossSell
    ) {
        self.crossSell = crossSell
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding48) {
                CrossSellBannerComponent(crossSell: crossSell)
                CrossSellPillowComponent(crossSell: crossSell)
                VStack(spacing: .padding16) {
                    CrossSellDiscountProgressComponent(crossSell: crossSell)
                    CrossSellButtonComponent(crossSell: crossSell)
                }
            }
            .padding(.bottom, .padding16)
        }
        .setViewController
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
    return CrossSellingCentered(
        crossSell: .init(
            id: "id",
            title: "Accident Insurance",
            description: "Help when you need it the most",
            buttonTitle: "Save 50%",
            imageUrl: nil,
            buttonDescription: "buttonDescription",
            numberOfEligibleContracts: 1
        )
    )
}
