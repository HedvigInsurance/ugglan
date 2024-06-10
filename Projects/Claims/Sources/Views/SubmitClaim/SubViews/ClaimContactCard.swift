import Combine
import Foundation
import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct ClaimContactCard: View {
    @PresentableStore var store: SubmitClaimStore
    var model: FlowClaimDeflectStepModel
    var title: String?
    var imageUrl: String?
    var url: String?
    var phoneNumber: String?

    init(
        imageUrl: String?,
        url: String,
        phoneNumber: String?,
        title: String? = nil,
        model: FlowClaimDeflectStepModel?
    ) {
        self.imageUrl = imageUrl
        self.url = url
        self.phoneNumber = phoneNumber
        self.title = title
        self.model = model ?? .init(id: .Unknown, isEmergencyStep: false)
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
                        title: model.config?.infoViewTitle ?? "",
                        description: model.config?.infoViewText ?? ""
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
                    .foregroundColor(hTextColor.Opaque.negative)
                    .padding(.vertical, 16)
            }

            hText(model.config?.cardText ?? "")
                .fixedSize()
                .multilineTextAlignment(.center)
                .foregroundColor(hTextColor.Opaque.tertiary)
                .padding(.bottom, 8)
                .padding(.horizontal, 8)

            hSection {
                hButton.MediumButton(type: .secondaryAlt) {
                    if let url = URL(string: url) {
                        UIApplication.shared.open(url)
                    } else if let phoneNumber {
                        let tel = "tel://"
                        let formattedString = tel + phoneNumber
                        if let url = URL(string: formattedString) {
                            UIApplication.shared.open(url)
                        }
                    }
                } content: {
                    hText(model.config?.buttonText ?? "")
                        .multilineTextAlignment(.center)
                        .foregroundColor(hTextColor.Opaque.primary)
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
    var label: String?
    var phoneNumber: String?

    init(
        imageUrl: String? = nil,
        label: String?,
        phoneNumber: String? = nil,
        cardTitle: String? = nil,
        footnote: String? = nil
    ) {
        self.imageUrl = imageUrl
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
                    } else {
                        hCoreUIAssets.hedvigCircleLogo.view
                            .resizable()
                    }
                }
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
                .foregroundColor(hTextColor.Opaque.negative)
                .colorScheme(.light)
                .padding(.vertical, 8)
                VStack(spacing: 0) {
                    if let cardTitle = cardTitle {
                        hText(cardTitle)
                            .foregroundColor(
                                hColorScheme(light: hTextColor.Opaque.negative, dark: hTextColor.Opaque.primary)
                            )
                    }
                    hText(label ?? "")
                        .foregroundColor(hTextColor.Opaque.tertiary)
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
                            .foregroundColor(hTextColor.Opaque.primary)
                    }
                }
                .sectionContainerStyle(.transparent)
                .hUseLightMode

                if let footnote = footnote {
                    hText(footnote, style: .caption1)
                        .foregroundColor(hTextColor.Opaque.tertiary)
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
                url: "BUTTON TEXT",
                phoneNumber: "",
                model: nil
            )
            ClaimContactCard(
                imageUrl: "",
                url: "BUTTON TEXT",
                phoneNumber: "",
                model: nil
            )
            ClaimContactCard(
                imageUrl: "",
                url: "VERY LONG BUTTON TEXT VERY LONG BUTTON TEXT VERY LONG BUTTON TEXT",
                phoneNumber: "",
                model: nil
            )

        }

    }
}
