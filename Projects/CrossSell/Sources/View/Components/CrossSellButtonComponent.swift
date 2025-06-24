import SwiftUI
import hCore
import hCoreUI

struct CrossSellButtonComponent: View {
    let crossSell: CrossSell

    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: crossSell.buttonText ?? L10n.crossSellButton),
                    {
                        if let urlString = crossSell.webActionURL, let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        } else {
                            NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                        }
                    }
                )
                hText(
                    crossSell.buttonDescription,
                    style: .finePrint
                )
                .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
