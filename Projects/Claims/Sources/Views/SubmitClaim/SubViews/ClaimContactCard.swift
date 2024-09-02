import Combine
import Foundation
import Kingfisher
import StoreContainer
import SwiftUI
import hCore
import hCoreUI

struct ClaimContactCard: View {
    @hPresentableStore var store: SubmitClaimStore
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
                    .padding(.vertical, .padding16)
            }

            hText(model.config?.cardText ?? "")
                .fixedSize()
                .multilineTextAlignment(.center)
                .foregroundColor(hTextColor.Opaque.tertiary)
                .padding(.bottom, .padding8)
                .padding(.horizontal, .padding8)
            VStack(spacing: 8) {
                if let url = URL(string: url) {
                    hSection {
                        hButton.MediumButton(type: .secondaryAlt) {
                            UIApplication.shared.open(url)
                        } content: {
                            hText(model.config?.buttonText ?? "")
                                .multilineTextAlignment(.center)
                                .foregroundColor(hTextColor.Opaque.primary)
                        }
                    }
                }
                if let phoneNumber, let url = URL(string: "tel://" + phoneNumber) {
                    hSection {
                        hButton.MediumButton(type: .secondaryAlt) {
                            UIApplication.shared.open(url)
                        } content: {
                            hText(model.config?.buttonText ?? "")
                                .multilineTextAlignment(.center)
                                .foregroundColor(hTextColor.Opaque.primary)
                        }
                    }
                }

            }
            .sectionContainerStyle(.transparent)
        }
        .padding(.vertical, .padding16)
    }
}

struct ClaimEmergencyContactCard: View {
    @hPresentableStore var store: SubmitClaimStore
    let cardTitle: String?
    let footnote: String?
    let imageUrl: String?
    let label: String?
    let phoneNumber: String?
    let url: URL?

    init(
        imageUrl: String? = nil,
        label: String?,
        phoneNumber: String? = nil,
        url: URL?,
        cardTitle: String? = nil,
        footnote: String? = nil
    ) {
        self.imageUrl = imageUrl
        self.label = label
        self.phoneNumber = phoneNumber
        self.url = url
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
                        hCoreUIAssets.bigPillowBlack.view
                            .resizable()
                    }
                }
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
                .foregroundColor(hTextColor.Opaque.negative)
                .colorScheme(.light)
                .padding(.vertical, .padding8)
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
                        .padding(.horizontal, .padding24)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, .padding8)
                urlButton
                phoneButton
                if let footnote = footnote {
                    hText(footnote, style: .finePrint)
                        .foregroundColor(hTextColor.Opaque.tertiary)
                        .colorScheme(.light)

                }
            }
            .padding(.vertical, .padding24)
        }
        .sectionContainerStyle(.black)

    }

    @ViewBuilder
    private var urlButton: some View {
        if let url = url {
            hSection {
                hButton.MediumButton(type: .secondaryAlt) {
                    UIApplication.shared.open(url)
                } content: {
                    hText(L10n.submitClaimGlobalAssistanceUrlLabel)
                        .foregroundColor(hTextColor.Opaque.primary)
                }
                .sectionContainerStyle(.transparent)
                .hUseLightMode
            }
        }
    }

    @ViewBuilder
    private var phoneButton: some View {
        if let phoneNumber {
            hSection {
                hButton.MediumButton(type: url == nil ? .secondaryAlt : .ghost) {
                    let tel = "tel://"
                    let formattedString = tel + phoneNumber
                    if let url = URL(string: formattedString) {
                        UIApplication.shared.open(url)
                    }
                } content: {
                    hText(L10n.submitClaimGlobalAssistanceCallLabel(phoneNumber))
                        .foregroundColor(hTextColor.Opaque.primary)
                }
            }
            .sectionContainerStyle(.transparent)
            .colorScheme(url == nil ? .light : .dark)

        }
    }
}

struct ClaimContactCard_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
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
