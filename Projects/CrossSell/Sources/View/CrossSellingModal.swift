import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingModal: View {
    let crossSells: CrossSells
    let source: CrossSellSource
    @State private var shownTracker: CrossSellShownTracker

    public init(
        crossSells: CrossSells,
        source: CrossSellSource
    ) {
        self.crossSells = crossSells
        self.source = source
        _shownTracker = State(initialValue: CrossSellShownTracker(source: source))
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
                            .onCrossSellShown { shownTracker.offerWasShown(recommended) }
                        VStack(spacing: .padding16) {
                            if case let .insurance(insurance) = recommended {
                                CrossSellDiscountProgressComponent(crossSell: insurance)
                            }
                            CrossSellButtonComponent(crossSell: recommended, source: source)
                        }
                    }
                    CrossSellStackComponent(crossSells: crossSells.others, shownTracker: shownTracker)
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
    return CrossSellingModal(crossSells: .init(recommended: nil, others: []), source: .homeXSell)
}
