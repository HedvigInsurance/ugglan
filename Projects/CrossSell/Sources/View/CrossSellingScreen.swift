import Addons
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct CrossSellingScreen: View {
    @EnvironmentObject private var router: Router
    @PresentableStore var store: CrossSellStore
    let addonCardOnClick: (_ contractIds: [String]) -> Void

    public init(
        addonCardOnClick: @escaping (_ contractIds: [String]) -> Void,
        info: CrossSellInfo
    ) {
        self.addonCardOnClick = addonCardOnClick
        logCrossSellEvent(info: info)
    }

    public var body: some View {
        hForm {
            VStack(spacing: .padding24) {
                CrossSellingStack(withHeader: false)
                addonBanner
            }
            .padding(.bottom, .padding8)
        }
        .hFormContentPosition(.compact)
        .configureTitleView(title: L10n.crossSellTitle, subTitle: L10n.crossSellSubtitle)
        .hFormAttachToBottom {
            hSection {
                hButton.LargeButton(type: .ghost) {
                    router.dismiss()
                } content: {
                    hText(L10n.generalCloseButton)
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
        .task {
            store.send(.fetchAddonBanner)
        }
    }

    @ViewBuilder
    private var addonBanner: some View {
        PresentableStoreLens(
            CrossSellStore.self,
            getter: { state in
                state.addonBanner
            }
        ) { banner in
            if let banner {
                hSection {
                    AddonCardView(
                        openAddon: {
                            addonCardOnClick(banner.contractIds)
                        },
                        addon: banner
                    )
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }

    private func logCrossSellEvent(info: CrossSellInfo) {
        log.addUserAction(
            type: .custom,
            name: "crossSell",
            error: nil,
            attributes: info.asLogData()
        )
    }
}

public struct CrossSellInfo: Identifiable, Equatable {
    public static func == (lhs: CrossSellInfo, rhs: CrossSellInfo) -> Bool {
        lhs.id == rhs.id
    }

    public let id: String = UUID().uuidString
    public let type: CrossSellInfoType
    let additionalInfo: (any Encodable)?

    public init<T>(type: CrossSellInfoType, additionalInfo: T) where T: Encodable & Equatable {
        self.type = type
        self.additionalInfo = additionalInfo
    }

    public init(type: CrossSellInfoType) {
        self.type = type
        self.additionalInfo = nil
    }

    public enum CrossSellInfoType: String, Codable, Equatable {
        case home
        case claim
    }

    fileprivate func asLogData() -> [AttributeKey: AttributeValue] {
        var data = [AttributeKey: AttributeValue]()
        data["type"] = type.rawValue
        data["info"] = additionalInfo
        return data
    }
}

struct CrossSellingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
        return CrossSellingScreen(addonCardOnClick: { _ in }, info: .init(type: .home))
    }
}
