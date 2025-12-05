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
                            CrossSellDiscountProgressComponent(crossSell: recommended)
                            CrossSellButtonComponent(crossSell: recommended)
                        }
                    }
                    CrossSellStackComponent(
                        crossSells: crossSells.others,
                        source: crossSells.source,
                        withHeader: crossSells.recommended != nil
                    )
                }
                .padding(.bottom, .padding16)
            }
            .withDismissButton()
            .setViewController
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
    return CrossSellingModal(crossSells: .init(recommended: nil, others: [], source: .insurances))
}
