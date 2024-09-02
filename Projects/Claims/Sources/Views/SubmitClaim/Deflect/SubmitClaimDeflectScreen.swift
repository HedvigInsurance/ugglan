import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimDeflectScreen: View {
    private let model: FlowClaimDeflectStepModel?
    private let isEmergencyStep: Bool
    private let openChat: () -> Void

    public init(
        model: FlowClaimDeflectStepModel?,
        openChat: @escaping () -> Void
    ) {
        self.model = model
        self.isEmergencyStep = model?.isEmergencyStep ?? false
        self.openChat = openChat
    }

    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                hSection {
                    let type: NotificationType = isEmergencyStep ? .attention : .info
                    InfoCard(text: model?.config?.infoText ?? "", type: type)
                }
                if isEmergencyStep {
                    ForEach(model?.partners ?? [], id: \.id) { partner in
                        ClaimEmergencyContactCard(
                            imageUrl: partner.imageUrl,
                            label: model?.config?.cardText,
                            phoneNumber: partner.phoneNumber,
                            url: URL(string: partner.url),
                            cardTitle: model?.config?.cardTitle,
                            footnote: L10n.submitClaimGlobalAssistanceFootnote
                        )
                    }
                } else {
                    let title =
                        model?.partners.count == 1 ? L10n.submitClaimPartnerSingularTitle : L10n.submitClaimPartnerTitle

                    VStack(spacing: 8) {
                        ForEach(Array((model?.partners ?? []).enumerated()), id: \.element) { index, partner in
                            ClaimContactCard(
                                imageUrl: partner.imageUrl,
                                url: partner.url ?? "",
                                phoneNumber: partner.phoneNumber,
                                title: index == 0 ? title : nil,
                                model: model
                            )
                        }
                    }
                }

                hSection {
                    VStack(alignment: .leading, spacing: 8) {
                        hText(model?.config?.infoSectionTitle ?? "")
                        hText(model?.config?.infoSectionText ?? "")
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
                .padding(.top, .padding8)
                .sectionContainerStyle(.transparent)

                VStack(spacing: 4) {
                    withAnimation(.easeOut) {
                        ForEach(model?.config?.questions ?? [], id: \.question) { question in

                            InfoExpandableView(
                                title: question.question,
                                text: question.answer,
                                onMarkDownClick: { url in
                                    NotificationCenter.default.post(name: .openDeepLink, object: url)
                                }
                            )
                        }
                    }
                }
                .padding(.top, .padding8)

                SupportView(openChat: openChat)
                    .padding(.vertical, .padding56)
            }
            .padding(.top, .padding8)
        }
    }
}

#Preview{
    Localization.Locale.currentLocale.send(.en_SE)
    let model = FlowClaimDeflectStepModel(
        id: .FlowClaimDeflectEmergencyStep,
        partners: [
            .init(
                id: "",
                imageUrl: "",
                url: "",
                phoneNumber: "+46177272727"
            )
        ],
        isEmergencyStep: true
    )
    return SubmitClaimDeflectScreen(model: model, openChat: {})
}
