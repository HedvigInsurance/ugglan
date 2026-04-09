import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingDetent: View {
    @StateObject private var router = NavigationRouter()

    let crossSells: CrossSells

    public init(
        crossSells: CrossSells
    ) {
        self.crossSells = crossSells
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding48) {
                CrossSellStackComponent(crossSells: crossSells.others, discountAvailable: true, withHeader: false)
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
        .hFormContentPosition(.compact)
        .configureTitleView(title: L10n.crossSellSubtitle)
        .embededInNavigation(
            router: router,
            options: [.navigationType(type: .large), .extendedNavigationWidth],
            tracking: self
        )
    }
}

extension CrossSellingDetent: TrackingViewNameProtocol {
    public var nameForTracking: String {
        "CrossSellingDetent"
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
    return CrossSellingDetent(crossSells: .init(recommended: nil, others: [], discountAvailable: true))
}
