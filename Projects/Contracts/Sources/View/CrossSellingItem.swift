import Foundation
import Kingfisher
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
            NotificationCenter.default.post(name: .openChat, object: nil)
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
                    VStack(alignment: .leading, spacing: 0) {
                        hText(crossSell.title, style: .body1).foregroundColor(hTextColor.Opaque.primary)
                        MarqueeText(
                            text: crossSell.description,
                            font: Fonts.fontFor(style: .standardSmall),
                            leftFade: 3,
                            rightFade: 3,
                            startDelay: 2
                        )
                        .foregroundColor(hTextColor.Opaque.secondary)
                    }
                    Spacer()
                    hButton.MediumButton(type: .primaryAlt) {
                        withAnimation(.easeIn(duration: 2.0)) {
                            fieldIsClicked = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeOut(duration: 2.0)) {
                                fieldIsClicked = false
                            }
                        }
                        openExternal()
                    } content: {
                        hText(L10n.crossSellGetPrice)
                            .foregroundColor(hTextColor.Opaque.primary).colorScheme(.light)
                    }
                    .fixedSize(horizontal: true, vertical: true)
                }
            }
            .onTapGesture {
                withAnimation(.easeIn(duration: 2.0)) {
                    fieldIsClicked = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 2.0)) {
                        fieldIsClicked = false
                    }
                }
                openExternal()
                ImpactGenerator.soft()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: .cornerRadiusXL)
                .fill(getBackgroundColor)
        )
    }

    @hColorBuilder
    var getBackgroundColor: some hColor {
        if fieldIsClicked {
            hSurfaceColor.Translucent.primary
        } else {
            hBackgroundColor.clear
        }
    }
}

struct CrossSellingItemPreviews: PreviewProvider {
    static var itemWithImage = CrossSellingItem(
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
    static var previews: some View {
        itemWithImage.previewLayout(.sizeThatFits)
    }
}
