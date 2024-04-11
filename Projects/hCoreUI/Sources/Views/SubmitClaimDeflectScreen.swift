import Kingfisher
import SwiftUI
import hCore

public struct SubmitClaimDeflectScreen: View {
    private let isEmergencyStep: Bool
    private let openChat: () -> Void

    private let partners: [Partner]
    private let config: FlowClaimDeflectConfig?

    public init(
        openChat: @escaping () -> Void,

        isEmergencyStep: Bool?,
        partners: [Partner],
        config: FlowClaimDeflectConfig?
    ) {
        self.isEmergencyStep = isEmergencyStep ?? false
        self.openChat = openChat

        self.partners = partners
        self.config = config
    }

    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                hSection {
                    let type: InfoCardType = isEmergencyStep ? .attention : .info
                    InfoCard(text: config?.infoText ?? "", type: type)
                }
                if isEmergencyStep {
                    ForEach(partners, id: \.id) { partner in
                        ClaimEmergencyContactCard(
                            imageUrl: partner.imageUrl,
                            label: config?.cardText ?? "",
                            phoneNumber: partner.phoneNumber,
                            cardTitle: config?.cardTitle ?? "",
                            footnote: L10n.submitClaimGlobalAssistanceFootnote
                        )
                    }
                } else {
                    let title =
                        partners.count == 1 ? L10n.submitClaimPartnerSingularTitle : L10n.submitClaimPartnerTitle

                    VStack(spacing: 8) {
                        ForEach(Array((partners).enumerated()), id: \.element) { index, partner in
                            ClaimContactCard(
                                imageUrl: partner.imageUrl,
                                url: partner.url ?? "",
                                phoneNumber: partner.phoneNumber,
                                title: index == 0 ? title : nil,
                                config: config
                            )
                        }
                    }
                }

                hSection {
                    VStack(alignment: .leading, spacing: 8) {
                        hText(config?.infoSectionTitle ?? "")
                        hText(config?.infoSectionText ?? "")
                            .foregroundColor(hTextColor.secondary)
                    }
                }
                .padding(.top, 8)
                .sectionContainerStyle(.transparent)

                VStack(spacing: 4) {
                    ForEach(config?.questions ?? [], id: \.question) { question in
                        withAnimation(.easeOut) {
                            InfoExpandableView(
                                title: question.question,
                                text: question.answer
                            )
                        }
                    }
                }
                .padding(.top, 8)

                SupportView(openChat: openChat)
                    .padding(.vertical, 56)
            }
            .padding(.top, 8)
        }
    }
}

struct ClaimContactCard: View {
    private let config: FlowClaimDeflectConfig?

    var title: String?
    var imageUrl: String?
    var url: String?
    var phoneNumber: String?

    init(
        imageUrl: String?,
        url: String,
        phoneNumber: String?,
        title: String? = nil,

        config: FlowClaimDeflectConfig?
    ) {
        self.imageUrl = imageUrl
        self.url = url
        self.phoneNumber = phoneNumber
        self.title = title

        self.config = config
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
                        title: config?.infoViewTitle ?? "",
                        description: config?.infoViewText ?? ""
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

            hText(config?.cardText ?? "")
                .fixedSize()
                .multilineTextAlignment(.center)
                .foregroundColor(hTextColor.tertiary)
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
                    hText(config?.buttonText ?? "")
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
                        hCoreUIAssets.hedvigBigLogo.view
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
                    hText(label ?? "")
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

struct SupportView: View {
    let openChat: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 0) {
                hText(L10n.submitClaimNeedHelpTitle)
                    .foregroundColor(hTextColor.primaryTranslucent)
                hText(L10n.submitClaimNeedHelpLabel)
                    .foregroundColor(hTextColor.secondary)
                    .multilineTextAlignment(.center)
            }
            hButton.MediumButton(type: .primary) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    openChat()
                }
            } content: {
                hText(L10n.CrossSell.Info.faqChatButton)
            }
            .fixedSize(horizontal: true, vertical: true)
        }
    }
}
