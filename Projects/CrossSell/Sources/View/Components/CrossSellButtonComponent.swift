import SwiftUI
import hCore
import hCoreUI

struct CrossSellButtonComponent: View {
    let crossSell: CrossSell
    @EnvironmentObject private var vm: ViewControllerModel
    @State private var isCrossSellLoading = false
    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: crossSell.buttonText ?? L10n.crossSellButton),
                    {
                        if let urlString = crossSell.webActionURL, let url = URL(string: urlString) {
                            Task {
                                isCrossSellLoading = true
                                await Dependencies.urlOpener.openWithAuthorizationCode(url)
                                isCrossSellLoading = false
                                vm.vc?.dismiss(animated: true)
                            }
                        } else {
                            NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                            vm.vc?.dismiss(animated: true)
                        }
                    }
                )
                .disabled(isCrossSellLoading)
                .hButtonIsLoading(isCrossSellLoading)
                .animation(.default, value: isCrossSellLoading)
                .accessibilityHint(L10n.crossSellButton)
                hText(crossSell.buttonDescription, style: .finePrint)
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

#Preview {
    CrossSellButtonComponent(
        crossSell: .init(
            id: "id1",
            title: "title",
            description: "description",
            buttonTitle: "Save 15%",
            imageUrl: nil,
            buttonDescription: "button"
        )
    )
}
