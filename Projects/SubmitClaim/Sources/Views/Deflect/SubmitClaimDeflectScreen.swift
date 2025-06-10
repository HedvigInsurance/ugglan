import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimDeflectScreen: View {
    private let model: FlowClaimDeflectStepModel
    private let openChat: () -> Void

    public init(
        model: FlowClaimDeflectStepModel,
        openChat: @escaping () -> Void
    ) {
        self.model = model
        self.openChat = openChat
    }

    public var body: some View {
        hForm {
            VStack(spacing: 16) {
                if let infoText = model.infoText {
                    hSection {
                        InfoCard(text: infoText, type: .info)
                            .accessibilitySortPriority(2)
                    }
                } else if let warningText = model.warningText {
                    hSection {
                        InfoCard(text: warningText, type: .attention)
                            .accessibilitySortPriority(2)
                    }
                }

                VStack(spacing: .padding16) {
                    if let infoViewTitle = model.infoViewTitle, let infoViewText = model.infoViewText {
                        let title =
                            model.partners.count == 1
                            ? L10n.submitClaimPartnerSingularTitle : L10n.submitClaimPartnerTitle
                        hSection {
                            HStack {
                                hText(title)
                                Spacer()
                                InfoViewHolder(
                                    title: infoViewTitle,
                                    description: infoViewText
                                )
                            }
                        }
                        .sectionContainerStyle(.transparent)
                    }
                    VStack(spacing: .padding8) {
                        ForEach(model.partners, id: \.id) { partner in
                            ClaimContactCard(
                                model: partner
                            )
                        }
                    }
                }

                hSection {
                    VStack(alignment: .leading, spacing: 8) {
                        hText(model.infoSectionTitle ?? "")
                        hText(model.infoSectionText ?? "")
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
                .padding(.top, .padding8)
                .sectionContainerStyle(.transparent)
                .accessibilityElement(children: .combine)

                VStack(spacing: 4) {
                    withAnimation(.easeOut) {
                        ForEach(model.questions, id: \.question) { question in
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
                    .padding(.top, .padding56)
            }
            .padding(.top, .padding8)
        }
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hSurfaceColor.Opaque.primary))
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    let model = FlowClaimDeflectStepModel(
        id: .FlowClaimDeflectEmergencyStep,
        infoText: "info text",
        warningText: nil,
        infoSectionText: "infoSectionText",
        infoSectionTitle: "infoSectionTitle",
        infoViewTitle: "infoViewTitle",
        infoViewText: "infoViewText",
        questions: [],
        partners: [
            .init(
                id: "id",
                imageUrl: nil,
                url: nil,
                phoneNumber: nil,
                title: nil,
                description: nil,
                info: nil,
                buttonText: nil,
                preferredImageHeight: nil
            )
        ]
    )
    return SubmitClaimDeflectScreen(model: model, openChat: {})
}
