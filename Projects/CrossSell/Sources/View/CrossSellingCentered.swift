import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingCentered: View {
    private let crossSell: RecommendedCrossSell
    @State private var viewId = UUID().uuidString
    public init(
        crossSell: RecommendedCrossSell
    ) {
        self.crossSell = crossSell
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding48) {
                if case let .insurance(insurance) = crossSell {
                    CrossSellBannerComponent(crossSell: insurance)
                } else {
                    Spacing(height: 48)
                }
                CrossSellPillowComponent(crossSell: crossSell)
                VStack(spacing: .padding16) {
                    if case let .insurance(insurance) = crossSell {
                        CrossSellDiscountProgressComponent(crossSell: insurance)
                    }
                    CrossSellButtonComponent(crossSell: crossSell)
                }
            }
            .padding(.bottom, .padding16)
        }
        .task {
            logStartView(viewId, String(describing: CrossSellingCentered.self))
        }
        .onDisappear {
            logStopView(viewId)
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
    return CrossSellingCentered(
        crossSell: .insurance(
            .init(
                id: "id",
                title: "Accident Insurance",
                description: "Help when you need it the most",
                buttonTitle: "Save 50%",
                imageUrl: nil,
                buttonDescription: "buttonDescription",
                numberOfEligibleContracts: 1
            )
        )
    )
}
