import SwiftUI
import hCore
import hCoreUI

struct CrossSellButtonComponent: View {
    let crossSell: CrossSell
    @EnvironmentObject private var vm: ViewControllerModel

    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: crossSell.buttonText ?? L10n.crossSellButton),
                    {
                        vm.vc?.dismiss(animated: true)
                        if let urlString = crossSell.webActionURL, let url = URL(string: urlString) {
                            Dependencies.urlOpener.open(url)

                        } else {
                            NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                        }
                    }
                )
                .accessibilityHint(L10n.crossSellButton)
                hText(crossSell.buttonDescription, style: .finePrint)
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
        .sectionContainerStyle(.transparent)

    }
}
