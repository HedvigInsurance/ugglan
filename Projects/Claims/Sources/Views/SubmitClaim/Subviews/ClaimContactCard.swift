import Combine
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct ClaimContactCard: View {
    @PresentableStore var store: SubmitClaimStore
    var title: String?
    var image: UIImage
    var label: String
    var buttonText: String

    init(
        image: UIImage,
        label: String,
        buttonText: String,
        title: String? = nil
    ) {
        self.image = image
        self.label = label
        self.buttonText = buttonText
        self.title = title
    }

    var body: some View {
        if let title {
            hSection {
                sectionContent
            }
            .withHeader({
                HStack {
                    hText(title)
                    Spacer()
                    Image(uiImage: hCoreUIAssets.infoSmall.image)
                        .foregroundColor(hTextColorNew.secondary)
                        .fixedSize()
                        .onTapGesture {
                            store.send(
                                .navigationAction(
                                    action: .openInfoScreen(title: L10n.submitClaimPartnerTitle, description: "")
                                )
                            )
                        }
                }
            })
            .sectionContainerStyle(.black)
        } else {
            hSection {
                sectionContent
            }
            .sectionContainerStyle(.black)
        }
    }

    private var sectionContent: some View {
        VStack(spacing: 8) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .foregroundColor(hTextColorNew.negative)
                .padding(.vertical, 16)
            hText(label)
                .multilineTextAlignment(.center)
                .foregroundColor(hTextColorNew.tertiary)
                .padding(.bottom, 8)
                .padding(.horizontal, 8)
            hButton.MediumButtonSecondaryAlt {

            } content: {
                hText(buttonText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)

    }
}

struct ClaimContactCard_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return VStack {
            ClaimContactCard(image: hCoreUIAssets.carGlass.image, label: "LABEL", buttonText: "BUTTON TEXT")
            ClaimContactCard(
                image: hCoreUIAssets.carGlass.image,
                label: "VERY LONG LABEL TEXT VERY LONG LABEL TEXT VERY LONG LABEL TEXT VERY LONG LABEL TEXT",
                buttonText: "BUTTON TEXT"
            )
            ClaimContactCard(
                image: hCoreUIAssets.carGlass.image,
                label: "LABEL",
                buttonText: "VERY LONG BUTTON TEXT VERY LONG BUTTON TEXT VERY LONG BUTTON TEXT"
            )

        }

    }
}
