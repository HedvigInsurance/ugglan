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
    let multiplier = HFontTextStyle.body1.multiplier

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
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: multiplier != 1 ? .padding4 * multiplier : 0) {
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
                    .fixedSize(horizontal: true, vertical: true)
                }
            }
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
            imageURL: URL(
                string:
                    "https://images.unsplash.com/photo-1599501887769-a945a7e4fece?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8"
            )!,
            blurHash: "LEHV6nWB2yk8pyo0adR*.7kCMdnj",
            typeOfContract: "SE_ACCIDENT",
            type: .accident
        )
    )
}
