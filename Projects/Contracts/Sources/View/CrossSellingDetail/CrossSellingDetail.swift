import Combine
import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct CrossSellingDetail: View {
    @PresentableStore var store: ContractStore
    var crossSell: CrossSell

    public init(
        crossSell: CrossSell
    ) {
        self.crossSell = crossSell
    }

    public var body: some View {
        hForm {
            CrossSellingHeroImage(
                imageURL: crossSell.imageURL,
                blurHash: crossSell.blurHash
            )

            hSection {
                VStack {
                    hText(
                        crossSell.title,
                        style: .title1
                    )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            .sectionContainerStyle(.transparent)

            if let info = crossSell.infos.first {
                CrossSellHightlights(info: info)
                CrossSellAbout(info: info)
            }
            CrossSellMoreInfoSection(crossSell: crossSell)
        }
        .hFormAttachToBottom {
            ContinueButton(crossSell: crossSell)
        }
        .trackOnAppear(hAnalyticsEvent.screenView(screen: .crossSellDetail))
    }
}

public enum CrossSellingDetailResult {
    case embark(name: String)
    case chat
    case web(url: URL)
}

extension CrossSellingDetail {
    public func journey<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ result: CrossSellingDetailResult) -> Next,
        style: PresentationStyle = .detented(.large),
        options: PresentationOptions = [.defaults, .allowSwipeDismissAlways]
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: self,
            style: style,
            options: options
        ) { action in
            if case let .crossSellingDetailEmbark(name) = action {
                next(.embark(name: name))
            } else if case .openCrossSellingChat = action {
                next(.chat)
            } else if case let .crossSellingCoverageDetailNavigation(action: .detail(info)) = action {
                CrossSellingCoverageDetail(crossSell: self.crossSell, crossSellInfo: info).journey(next)
            } else if case .crossSellingFAQListNavigation(action: .list) = action {
                CrossSellingFAQList(crossSell: self.crossSell).journey(next)
            } else if case let .crossSellWebAction(url) = action {
                next(.web(url: url))
            }
        }
        .configureTitle(crossSell.title)
        .withDismissButton
        .scrollEdgeNavigationItemHandler
    }
}
