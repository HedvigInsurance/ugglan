import Flow
import Foundation
import Presentation
import SafariServices
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct CrossSellingFAQList: View {
    @PresentableStore var store: ContractStore
    var crossSell: CrossSell

    public init(
        crossSell: CrossSell
    ) {
        self.crossSell = crossSell
    }

    public var body: some View {
        hForm {
            if let faqs = crossSell.info?.faqs {
                hSection(faqs, id: \.title) { faq in
                    hRow {
                        hText(faq.title)
                    }
                    .onTap {
                        store.send(.crossSellingFAQListNavigation(action: .detail(faq: faq)))
                    }
                }
                .withHeader {
                    hText("Common questions")
                }
            }

            hSection {
                VStack(spacing: 20) {
                    hText("Can’t find the answer you’re looking for?", style: .subheadline)

                    hButton.LargeButtonOutlined {

                    } content: {
                        ZStack {
                            Image(uiImage: hCoreUIAssets.chat.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 16)
                            hText("Chat with us")
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            ContinueButton(crossSell: crossSell)
        }
    }
}

extension CrossSellingFAQList {
    public func journey(
        style: PresentationStyle = .default,
        options: PresentationOptions = [.defaults]
    ) -> some JourneyPresentation {
        HostingJourney(
            ContractStore.self,
            rootView: self,
            style: style,
            options: options
        ) { action in
            if case let .crossSellingFAQListNavigation(action: .detail(faq)) = action {
                HostingJourney(
                    rootView: FAQDetail(faq: faq),
                    style: .detented(.scrollViewContentSize)
                )
                .withDismissButton
            }
        }
        .withJourneyDismissButton
    }
}
