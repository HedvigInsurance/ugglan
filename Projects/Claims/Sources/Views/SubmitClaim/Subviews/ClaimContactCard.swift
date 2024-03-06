import Combine
import Foundation
import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct ClaimContactCard: View {
    @PresentableStore var store: SubmitClaimStore
    var title: String?
    var imageUrl: String
    var label: String
    var url: String?
    var buttonText: String
    var infoViewTitle: String
    var infoViewText: String

    init(
        imageUrl: String,
        label: String,
        url: String,
        title: String? = nil,
        buttonText: String,
        infoViewTitle: String,
        infoViewText: String
    ) {
        self.imageUrl = imageUrl
        self.label = label
        self.url = url
        self.title = title
        self.buttonText = buttonText
        self.infoViewTitle = infoViewTitle
        self.infoViewText = infoViewText
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
                    InfoViewHolder(
                        title: infoViewTitle,
                        description: infoViewText
                    )
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
            if let imageUrl = URL(string: imageUrl) {
                KFImage(imageUrl)
                    .setProcessor(SVGImageProcessor())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .foregroundColor(hTextColor.negative)
                    .padding(.vertical, 16)
            }

            hText(label)
                .fixedSize()
                .multilineTextAlignment(.center)
                .foregroundColor(hTextColor.tertiary)
                .padding(.bottom, 8)
                .padding(.horizontal, 8)

            hSection {
                hButton.MediumButton(type: .secondaryAlt) {
                    if let url = URL(string: url) {
                        UIApplication.shared.open(url)
                    }
                } content: {
                    hText(buttonText)
                        .multilineTextAlignment(.center)
                        .foregroundColor(hTextColor.primary)
                        .colorScheme(.light)
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .padding(.vertical, 16)
    }
}

struct ClaimEmergencyContactCard: View {
    @PresentableStore var store: SubmitClaimStore
    var cardTitle: String?
    var footnote: String?
    var imageUrl: String?
    var image: UIImage?
    var label: String
    var phoneNumber: String?

    init(
        imageUrl: String? = nil,
        image: UIImage? = nil,
        label: String,
        phoneNumber: String? = nil,
        cardTitle: String? = nil,
        footnote: String? = nil
    ) {
        self.imageUrl = imageUrl
        self.image = image
        self.label = label
        self.phoneNumber = phoneNumber
        self.cardTitle = cardTitle
        self.footnote = footnote
    }

    var body: some View {
        hSection {
            VStack(spacing: 16) {
                Group {
                    if let imageUrl = URL(string: imageUrl) {
                        KFImage(imageUrl)
                            .setProcessor(SVGImageProcessor())
                            .resizable()
                    } else if let image {
                        Image(uiImage: image)
                            .resizable()
                    }
                }
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
                .foregroundColor(hTextColor.negative)
                .colorScheme(.light)
                .padding(.vertical, 8)
                VStack(spacing: 0) {
                    if let cardTitle = cardTitle {
                        hText(cardTitle)
                            .foregroundColor(hColorScheme(light: hTextColor.negative, dark: hTextColor.primary))
                    }
                    hText(label)
                        .foregroundColor(hTextColor.tertiary)
                        .colorScheme(.light)
                        .padding(.horizontal, 24)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 8)
                hSection {
                    hButton.MediumButton(type: .secondaryAlt) {
                        if let phoneNumber {
                            let tel = "tel://"
                            let formattedString = tel + phoneNumber
                            if let url = URL(string: formattedString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    } content: {
                        hText(L10n.submitClaimGlobalAssistanceCallLabel(phoneNumber ?? ""))
                            .foregroundColor(hTextColor.primary)
                            .colorScheme(.light)
                    }
                }
                .sectionContainerStyle(.transparent)

                if let footnote = footnote {
                    hText(footnote, style: .caption1)
                        .foregroundColor(hTextColor.tertiary)
                        .colorScheme(.light)
                }
            }
            .padding(.vertical, 24)
        }
        .sectionContainerStyle(.black)

    }
}

struct ClaimContactCard_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return VStack {
            ClaimContactCard(
                imageUrl: "",
                label: "LABEL",
                url: "BUTTON TEXT",
                buttonText: "",
                infoViewTitle: "",
                infoViewText: ""
            )
            ClaimContactCard(
                imageUrl: "",
                label: "VERY LONG LABEL TEXT VERY LONG LABEL TEXT VERY LONG LABEL TEXT VERY LONG LABEL TEXT",
                url: "BUTTON TEXT",
                buttonText: "",
                infoViewTitle: "",
                infoViewText: ""
            )
            ClaimContactCard(
                imageUrl: "",
                label: "LABEL",
                url: "VERY LONG BUTTON TEXT VERY LONG BUTTON TEXT VERY LONG BUTTON TEXT",
                buttonText: "",
                infoViewTitle: "",
                infoViewText: ""
            )

        }

    }
}
