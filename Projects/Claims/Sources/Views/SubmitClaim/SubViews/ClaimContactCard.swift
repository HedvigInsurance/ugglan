import Combine
import Foundation
import Kingfisher
import SwiftUI
import hCore
import hCoreUI

struct ClaimContactCard: View {
    var model: Partner
    var body: some View {
        hSection {
            sectionContent
        }
        .sectionContainerStyle(.black)

    }

    private var sectionContent: some View {
        VStack(spacing: 24) {
            if let imageUrl = URL(string: model.imageUrl) {
                KFImage(imageUrl)
                    .setProcessor(SVGImageProcessor())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: model.largerImageSize ? 80 : 40)
                    .foregroundColor(hTextColor.Opaque.negative)
            }
            VStack(spacing: 0) {
                if let title = model.title {
                    hText(title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(hTextColor.Opaque.primary)
                }
                if let description = model.description {
                    hText(description)
                        .multilineTextAlignment(.center)
                        .foregroundColor(hTextColor.Opaque.tertiary)
                }
            }
            .padding(.horizontal, .padding16)
            VStack(spacing: 4) {
                if let url = URL(string: model.url) {
                    hSection {
                        hButton.MediumButton(type: .secondaryAlt) {
                            UIApplication.shared.open(url)
                        } content: {
                            hText(model.buttonText ?? "")
                                .multilineTextAlignment(.center)
                                .foregroundColor(hTextColor.Opaque.primary)
                        }
                        .colorScheme(.light)
                    }
                }
                if let phoneNumber = model.phoneNumber, let url = URL(string: "tel://" + phoneNumber) {
                    hSection {
                        hButton.MediumButton(type: getPhoneNumberButtonType()) {
                            UIApplication.shared.open(url)
                        } content: {
                            hText(L10n.submitClaimGlobalAssistanceCallLabel(phoneNumber))
                                .multilineTextAlignment(.center)
                                .foregroundColor(hTextColor.Opaque.primary)
                        }
                        .colorScheme(getPhoneNumberSchema())
                    }
                }
                if let info = model.info {
                    hText(info, style: .label)
                        .foregroundColor(hTextColor.Opaque.tertiary)
                        .padding(.top, .padding16)
                }

            }
            .sectionContainerStyle(.transparent)
        }
        .padding(.top, .padding32)
        .padding(.bottom, .padding16)
        .colorScheme(.dark)
    }

    private func getPhoneNumberButtonType() -> hButtonConfigurationType {
        if URL(string: model.url) == nil {
            return hCoreUI.hButtonConfigurationType.secondaryAlt
        } else {
            return hCoreUI.hButtonConfigurationType.ghost
        }
    }

    private func getPhoneNumberSchema() -> ColorScheme {
        if URL(string: model.url) == nil {
            return .light
        } else {
            return .dark
        }
    }
}

struct ClaimContactCard_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return VStack {
            ClaimContactCard(
                model: .init(
                    id: "id",
                    imageUrl: nil,
                    url: "https://www.hedvig.com",
                    phoneNumber: nil,
                    title: nil,
                    description: nil,
                    info: nil,
                    buttonText: "Button text",
                    largerImageSize: false
                )
            )
            ClaimContactCard(
                model: .init(
                    id: "id1",
                    imageUrl: nil,
                    url: nil,
                    phoneNumber: nil,
                    title: nil,
                    description: nil,
                    info: nil,
                    buttonText: nil,
                    largerImageSize: false
                )
            )
            ClaimContactCard(
                model: .init(
                    id: "id2",
                    imageUrl: nil,
                    url: nil,
                    phoneNumber: nil,
                    title: nil,
                    description: nil,
                    info: nil,
                    buttonText: nil,
                    largerImageSize: false
                )
            )
        }

    }
}
