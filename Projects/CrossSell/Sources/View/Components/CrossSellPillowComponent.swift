import Kingfisher
import SwiftUI
import hCoreUI

struct CrossSellPillowComponent: View {
    let crossSell: CrossSell
    private let mainImageSize: CGFloat = 140
    private let backgroundImageSize: CGFloat = 96

    var body: some View {
        VStack(spacing: .padding16) {
            ZStack(alignment: .topTrailing) {
                KFImage(crossSell.imageUrl)
                    .placeholder {
                        hCoreUIAssets.bigPillowHome.view
                            .resizable()
                            .frame(width: mainImageSize, height: mainImageSize)
                    }
                    .fade(duration: 0)
                    .resizable()
                if let discountText = crossSell.discountText {
                    hText(discountText, style: .label)
                        .padding(.horizontal, .padding6)
                        .padding(.vertical, .padding3)
                        .background {
                            hHighlightColor.Green.fillOne
                        }
                        .colorScheme(.light)
                        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXS))
                        .offset(x: 4, y: 16)
                }
            }
            .frame(width: mainImageSize, height: mainImageSize)
            .background {
                if let imageUrl = crossSell.leftImage {
                    getImage(for: imageUrl)
                        .offset(x: -75, y: 0)
                }
            }
            .background {
                if let imageUrl = crossSell.rightImage {
                    getImage(for: imageUrl)
                        .offset(x: 75, y: 0)
                }
            }
            VStack {
                hSection {
                    hText(crossSell.title)
                    hText(crossSell.description)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
                .sectionContainerStyle(.transparent)
            }
            .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func getImage(for url: URL) -> some View {
        KFImage(url)
            .resizable()
            .frame(width: backgroundImageSize, height: backgroundImageSize)
    }
}

#Preview {
    CrossSellPillowComponent(
        crossSell: .init(
            id: "id",
            title: "title",
            description: "description",
            buttonTitle: "Save 15%",
            discountText: "50%",
            imageUrl: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F832x832%2F1fe7a75de6%2Fhedvig-pillows-car.png&w=420&q=70&dpl=dpl_5cQgznxvLKNPt4ivb7hDrQ9Gw3di"
            ),
            buttonDescription: "buttonDescription",
            leftImage: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F832x832%2F0f43046205%2Fhedvig-pillows-pet.png&w=420&q=70&dpl=dpl_5cQgznxvLKNPt4ivb7hDrQ9Gw3di"
            ),
            rightImage: URL(
                string:
                    "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F832x832%2Fcdaaa91242%2Fhedvig-pillows-home.png&w=420&q=70&dpl=dpl_5cQgznxvLKNPt4ivb7hDrQ9Gw3di"
            )
        )
    )
}
