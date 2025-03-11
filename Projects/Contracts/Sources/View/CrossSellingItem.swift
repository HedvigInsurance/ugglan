import Foundation
import Kingfisher
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CrossSellingItem: View {
    @PresentableStore var store: ContractStore
    let crossSell: CrossSell
    @State var fieldIsClicked = false

    @EnvironmentObject var contractsNavigationVm: ContractsNavigationViewModel

    func openExternal() {
        if let urlString = crossSell.webActionURL, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        } else {
            NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
        }
    }

    var body: some View {
        HStack {
            HStack(spacing: 16) {
                Image(uiImage: crossSell.image)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .aspectRatio(contentMode: .fill)
                    .accessibilityHidden(true)
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        hText(crossSell.title, style: .body1).foregroundColor(hTextColor.Opaque.primary)
                        MarqueeText(
                            text: crossSell.description,
                            font: Fonts.fontFor(style: .label),
                            leftFade: 3,
                            rightFade: 3,
                            startDelay: 2
                        )
                        .foregroundColor(hTextColor.Opaque.secondary)
                    }
                    Spacer()
                    hButton.MediumButton(type: .primaryAlt) {
                        fieldIsClicked.toggle()
                        openExternal()
                    } content: {
                        hText(L10n.crossSellGetPrice)
                            .foregroundColor(hTextColor.Opaque.primary).colorScheme(.light)
                    }
                }
            }
            .accessibilityElement(children: .combine)
            .onTapGesture {
                fieldIsClicked.toggle()
                openExternal()
                ImpactGenerator.soft()
            }
        }
        .padding(.vertical, .padding8)
        .modifier(
            BackgorundColorAnimation(
                animationTrigger: $fieldIsClicked,
                color: hBackgroundColor.clear,
                animationColor: hSurfaceColor.Translucent.primary
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXL))
    }
}

#Preview {
    CrossSellingItem(
        crossSell: .init(
            title: "Accident Insurance",
            description: "From 79 SEK/mo.",
            type: .accident
        )
    )
}
