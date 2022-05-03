import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import SwiftUI

struct FrequentlyAskedQuestionsSection: View {
    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { $0.currentVariant?.bundle.appConfiguration.showFaq ?? false }
        ) { showFAQ in
            if showFAQ {
                FAQList()
            }
        }
    }
}

struct FAQList: View {
    @PresentableStore var store: OfferStore
    
    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { $0.currentVariant?.bundle.frequentlyAskedQuestions ?? [] }
        ) { faqItems in
            hSection(faqItems) { faqItem in
                hRow {
                    faqItem.headline?.hText()
                }.onTap {
                    store.send(.openFAQ(item: faqItem))
                }
            }.withHeader {
                L10n.Offer.faqTitle.hText()
            }.withFooter {
                VStack {
                    L10n.offerFooterSubtitle.hText(.subheadline)
                    hButton.LargeButtonOutlined {
                        store.send(.openChat)
                    } content: {
                        HStack {
                            L10n.offerFooterButtonText.hText()
                            hCoreUIAssets.chat.view.frame(width: 24, height: 24)
                        }
                    }
                }
            }
        }
    }
}
