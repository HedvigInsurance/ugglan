import Addons
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingDetent: View {
    @State private var router = NavigationRouter()

    let crossSells: CrossSells
    let source: CrossSellSource
    let addons: [AddonBanner]
    let onAddonTap: (AddonBanner) -> Void

    public init(
        crossSells: CrossSells,
        source: CrossSellSource,
        addons: [AddonBanner],
        onAddonTap: @escaping (AddonBanner) -> Void
    ) {
        self.crossSells = crossSells
        self.source = source
        self.addons = addons
        self.onAddonTap = onAddonTap
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding48) {
                CrossSellStackComponent(crossSells: crossSells.others, source: source)
                CrossSellAddonsSection(addons: addons, onAddonTap: onAddonTap)
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
        .configureTitleView(title: L10n.crossSellTitle, subTitle: L10n.crossSellSubtitle)
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
    return CrossSellingDetent(
        crossSells: .init(recommended: nil, others: []),
        source: .homeXSell,
        addons: [],
        onAddonTap: { _ in }
    )
}
