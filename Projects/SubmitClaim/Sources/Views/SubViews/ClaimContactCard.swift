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
                    .frame(height: CGFloat(model.preferredImageHeight ?? 40))
                    .foregroundColor(hTextColor.Opaque.negative)
                    .accessibilityHidden(true)
                    .padding(.bottom, .padding8)
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
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
            .padding(.horizontal, .padding16)
            .accessibilityElement(children: .combine)
            VStack(spacing: .padding4) {
                if let url = URL(string: model.url) {
                    hSection {
                        hButton(
                            .medium,
                            .secondaryAlt,
                            content: .init(title: model.buttonText ?? ""),
                            {
                                Dependencies.urlOpener.open(url)
                            }
                        )
                        .colorScheme(.light)
                        .hButtonTakeFullWidth(true)
                    }
                }
                if let phoneNumber = model.phoneNumber, let url = URL(string: "tel://" + phoneNumber) {
                    hSection {
                        hButton(
                            .medium,
                            getPhoneNumberButtonType(),
                            content: .init(title: L10n.submitClaimGlobalAssistanceCallLabel(phoneNumber)),
                            {
                                Dependencies.urlOpener.open(url)
                            }
                        )
                        .colorScheme(getPhoneNumberSchema())
                        .hButtonTakeFullWidth(true)
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
                    imageUrl: "https://odyssey.dev.hedvigit.com/logos/mehrwerk-logo.svg",
                    url: "https://odyssey.dev.hedvigit.com/logos/mehrwerk-logo.svg",
                    phoneNumber: nil,
                    title: nil,
                    description: nil,
                    info: nil,
                    buttonText: "Button text",
                    preferredImageHeight: nil
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
                    preferredImageHeight: nil
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
                    preferredImageHeight: nil
                )
            )
        }
    }
}
