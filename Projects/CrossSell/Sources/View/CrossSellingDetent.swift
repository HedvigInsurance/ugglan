import Addons
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingDetent: View {
    @StateObject private var router = Router()

    let crossSells: CrossSells

    public init(
        crossSells: CrossSells
    ) {
        self.crossSells = crossSells
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding48) {
                CrosssSellStackComponent(crossSells: crossSells.others, withHeader: false)
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
        .embededInNavigation(router: router, options: [.navigationType(type: .large)], tracking: self)
    }
}

extension CrossSellingDetent: TrackingViewNameProtocol {
    public var nameForTracking: String {
        "CrossSellingDetent"
    }
}

struct CrossSellingDetent_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
        return CrossSellingDetent(crossSells: .init(recommended: nil, others: []))
    }
}
