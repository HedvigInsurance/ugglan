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
            VStack(spacing: 0) {
                CrossSellBannerComponent(crossSell: crossSell)
                CrossSellPillowComponent(crossSell: crossSell)
                    .padding(.top, contentTopPadding)
                VStack(spacing: .padding16) {
                    if case let .insurance(insurance) = crossSell {
                        CrossSellDiscountProgressComponent(crossSell: insurance)
                    }
                    CrossSellButtonComponent(crossSell: crossSell)
                }
                .padding(.top, buttonTopPadding)
            }
            .padding(.bottom, bottomPadding)
        }
        .task {
            logStartView(viewId, String(describing: CrossSellingCentered.self))
        }
        .onDisappear {
            logStopView(viewId)
        }
    }

    private var contentTopPadding: CGFloat {
        switch crossSell {
        case .insurance: return .padding48
        case .addon: return .padding32
        }
    }

    private var buttonTopPadding: CGFloat {
        switch crossSell {
        case .insurance: return .padding48
        case .addon: return .padding40
        }
    }

    private var bottomPadding: CGFloat {
        switch crossSell {
        case .insurance: return .padding16
        case .addon: return .padding32
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
