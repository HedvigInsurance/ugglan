import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingModal: View {
    let crossSells: CrossSells

    public init(
        crossSells: CrossSells
    ) {
        self.crossSells = crossSells
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let recommended = crossSells.recommended {
                CrossSellBannerComponent(crossSell: recommended)
            }
            hForm {
                VStack(spacing: .padding48) {
                    if let recommended = crossSells.recommended {
                        CrossSellPillowComponent(crossSell: recommended)
                        VStack(spacing: .padding16) {
                            if case let .insurance(insurance) = recommended {
                                CrossSellDiscountProgressComponent(crossSell: insurance)
                            }
                            CrossSellButtonComponent(crossSell: recommended)
                        }
                    }
                    CrossSellStackComponent(
                        crossSells: crossSells.others,
                        discountAvailable: crossSells.discountAvailable,
                        withHeader: crossSells.hasRecommendation
                    )
                }
                .padding(.bottom, .padding16)
            }
            .withDismissButton()
            .embededInNavigation(
                options: .extendedNavigationWidth,
                tracking: self
            )
        }
    }
}

extension CrossSellingModal: TrackingViewNameProtocol {
    public var nameForTracking: String {
        "CrossSellingModal"
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
    return CrossSellingModal(crossSells: .init(recommended: nil, others: [], discountAvailable: true))
}
