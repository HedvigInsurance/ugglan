import Foundation
import Presentation
import SwiftUI
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
            VStack {
                LinearGradient(
                    gradient: Gradient(
                        colors: [.black.opacity(0.5), .clear]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .frame(height: 250)
            .backgroundImageWithBlurHashFallback(imageURL: crossSell.imageURL, blurHash: crossSell.blurHash)
            .clipped()

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

            if let info = crossSell.info {
                CrossSellHightlights(info: info)
                CrossSellAbout(info: info)
                CrossSellMoreInfoSection(info: info)
            }
        }
        .hFormAttachToBottom {
            ContinueButton(crossSell: crossSell)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

public enum CrossSellingDetailResult {
    case embark(name: String)
    case chat
}

extension CrossSellingDetail {
    public func journey<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ result: CrossSellingDetailResult) -> Next,
        style: PresentationStyle = .detented(.large),
        options: PresentationOptions = [.defaults]
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: self,
            style: style,
            options: options
        ) { action in
            if case let .openCrossSellingEmbark(name) = action {
                next(.embark(name: name))
            } else if case .openCrossSellingChat = action {
                next(.chat)
            } else if case .crossSellingCoverageDetailNavigation(action: .detail) = action {
                CrossSellingCoverageDetail(crossSell: self.crossSell).journey()
            } else if case .crossSellingFAQListNavigation(action: .list) = action {
                CrossSellingFAQList(crossSell: self.crossSell).journey()
            }
        }
        .withDismissButton
        .scrollEdgeBarButtonItemHandler
    }
}
