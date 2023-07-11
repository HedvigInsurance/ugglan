import Flow
import Foundation
import Presentation
import SafariServices
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct InfoAndTermsView: View {
    @PresentableStore var store: ForeverStore
    @State var potentialDiscount: String

    public init(
        potentialDiscount: String
    ) {
        self.potentialDiscount = potentialDiscount
    }

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 16) {
                    Image(uiImage: hCoreUIAssets.infoAndTermsIllustration.image)
                    L10n.ReferralsInfoSheet.headline.hText(.title1)
                    L10n.ReferralsInfoSheet.body(potentialDiscount).hText().foregroundColor(hLabelColor.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .sectionContainerStyle(.transparent).padding(.top, 16)
        }
        .hFormAttachToBottom {
            hButton.LargeButtonPrimary {
                UIApplication.shared.open(URL(string: L10n.referralsTermsWebsiteUrl)!)
            } content: {
                L10n.ReferralsInfoSheet.fullTermsAndConditions.hText()
            }
            .padding()
        }
        .navigationBarItems(
            trailing: Button(action: {
                store.send(.closeInfoSheet)
            }) {
                L10n.NavBar.close.hText().foregroundColor(hLabelColor.link)
            }
        )
    }
}
