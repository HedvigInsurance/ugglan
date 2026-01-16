import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct CrossSellingItem: View {
    let crossSell: CrossSell
    let discountAvailable: Bool
    @State var fieldIsClicked = false

    func openExternal() {
        if let urlString = crossSell.webActionURL, let url = URL(string: urlString) {
            Dependencies.urlOpener.open(url)
        } else {
            NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
        }
    }

    var body: some View {
        ZStack {
            ColorAnimationView(
                animationTrigger: $fieldIsClicked,
                color: hBackgroundColor.clear,
                animationColor: hSurfaceColor.Translucent.primary
            )
            HStack {
                HStack(spacing: .padding16) {
                    KFImage(crossSell.imageUrl)
                        .placeholder {
                            hCoreUIAssets.bigPillowHome.view
                                .resizable()
                                .frame(width: 48, height: 48)
                        }
                        .fade(duration: 0.25)
                        .resizable()
                        .frame(width: 48, height: 48)
                        .aspectRatio(contentMode: .fill)
                        .accessibilityHidden(true)
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            hText(crossSell.title, style: .body1).foregroundColor(hTextColor.Translucent.primary)
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

                        hButton(
                            .small,
                            discountAvailable ? .primaryAlt : .secondary,
                            content: .init(title: crossSell.buttonTitle),
                            {
                                fieldIsClicked.toggle()
                                openExternal()
                            }
                        )
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityValue(L10n.voiceoverPressTo + L10n.crossSellGetPrice)
                .onTapGesture {
                    fieldIsClicked.toggle()
                    openExternal()
                    ImpactGenerator.soft()
                }
            }
            .padding(.vertical, .padding8)
        }
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXL))
    }
}

#Preview {
    CrossSellingItem(
        crossSell: .init(
            id: "id",
            title: "Accident Insurance",
            description: "From 79 SEK/mo.",
            buttonTitle: "Save 50%",
            imageUrl: nil,
            buttonDescription: "button description"
        ),
        discountAvailable: true
    )
}
