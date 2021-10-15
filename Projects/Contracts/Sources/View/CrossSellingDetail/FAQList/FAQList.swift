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
                    hText(L10n.CrossSell.Info.commonQuestionsTitle)
                }
            }

            hSection {
                VStack(spacing: 20) {
                    hText(L10n.CrossSell.Info.faqChatHeadline, style: .subheadline)

                    hButton.LargeButtonOutlined {
                        store.send(.crossSellingFAQListNavigation(action: .chat))
                    } content: {
                        ZStack {
                            Image(uiImage: hCoreUIAssets.chat.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 16)
                            hText(L10n.CrossSell.Info.faqChatButton)
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
    public func journey<Next: JourneyPresentation>(
        @JourneyBuilder _ next: @escaping (_ result: CrossSellingDetailResult) -> Next,
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
            } else if case .crossSellingFAQListNavigation(action: .chat) = action {
                next(.chat)
            }
        }
        .withJourneyDismissButton
    }
}
