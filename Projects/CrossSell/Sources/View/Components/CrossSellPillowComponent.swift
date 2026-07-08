import Kingfisher
import SwiftUI
import hCoreUI

struct CrossSellPillowComponent: View {
    let crossSell: RecommendedCrossSell
    private let mainImageSize: CGFloat = 140
    private let backgroundImageSize: CGFloat = 96

    var body: some View {
        VStack(spacing: .padding16) {
            switch crossSell {
            case .insurance(let insurance):
                ZStack(alignment: .topTrailing) {
                    KFImage(insurance.imageUrl)
                        .placeholder {
                            hCoreUIAssets.bigPillowHome.view
                                .resizable()
                                .frame(width: mainImageSize, height: mainImageSize)
                        }
                        .fade(duration: 0)
                        .resizable()
                    if let discountText = insurance.discountText {
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
                    if let imageUrl = insurance.leftImage {
                        getImage(for: imageUrl)
                            .offset(x: -75, y: 0)
                    }
                }
                .background {
                    if let imageUrl = insurance.rightImage {
                        getImage(for: imageUrl)
                            .offset(x: 75, y: 0)
                    }
                }
                VStack {
                    hSection {
                        hText(insurance.title)
                        hText(insurance.description)
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }
                    .sectionContainerStyle(.transparent)
                }
                .multilineTextAlignment(.center)
            case .addon(let addon):
                ZStack(alignment: .topTrailing) {
                    KFImage(addon.imageUrl)
                        .placeholder {
                            hCoreUIAssets.bigPillowHome.view
                                .resizable()
                                .frame(width: mainImageSize, height: mainImageSize)
                        }
                        .fade(duration: 0)
                        .resizable()
                    ZStack {
                        Circle()
                            .foregroundColor(hFillColor.Opaque.negative)
                            .frame(width: 30, height: 30)
                            .overlay {
                                Circle()
                                    .stroke(hBorderColor.primary, lineWidth: 1)
                            }
                        hCoreUIAssets.plus.view
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .offset(x: -5, y: 4)
                }
                .frame(width: mainImageSize, height: mainImageSize)
                VStack {
                    hSection {
                        hText(addon.title)
                        hText(addon.description)
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }
                    .sectionContainerStyle(.transparent)
                }
                .multilineTextAlignment(.center)
                if !addon.benefits.isEmpty {
                    VStack(alignment: .leading, spacing: .padding10) {
                        ForEach(Array(addon.benefits.enumerated()), id: \.offset) { _, benefit in
                            HStack(alignment: .top, spacing: .padding12) {
                                hCoreUIAssets.checkmark.view
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .accessibilityHidden(true)
                                hText(benefit)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .padding(.horizontal, .padding24)
                    .padding(.top, .padding16)
                }
            }
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

#Preview("insurance") {
    CrossSellPillowComponent(
        crossSell: .insurance(
            .init(
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
    )
}

#Preview("addon") {
    CrossSellPillowComponent(
        crossSell: .addon(
            .init(
                id: "id",
                title: "Travel Insurance Plus",
                description: "For a safer trip abroad",
                buttonText: "button title",
                deepLink: "https://link.dev.hedvigit.com/travel-addon",
                banner: "Add extra safety when traveling",
                benefits: [
                    "Travel up to 60 days in a row",
                    "Delayed bags and flights",
                    "Applies to all co-insured",
                ],
                imageUrl: URL(
                    string:
                        "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F832x832%2F0f43046205%2Fhedvig-pillows-pet.png&w=420&q=70&dpl=dpl_5cQgznxvLKNPt4ivb7hDrQ9Gw3di"
                )
            )
        )
    )
}
