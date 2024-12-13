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
                    }
                } else if let warningText = model.warningText {
                    hSection {
                        InfoCard(text: warningText, type: .attention)
                    }
                }

                ForEach(model.partners, id: \.id) { partner in
                    ClaimContactCard(
                        model: partner
                    )
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
                    .padding(.vertical, .padding56)
            }
            .padding(.top, .padding8)
        }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    let model = FlowClaimDeflectStepModel(
        id: .FlowClaimDeflectEmergencyStep,
        infoText: nil,
        warningText: nil,
        infoSectionText: nil,
        infoSectionTitle: nil,
        infoViewTitle: nil,
        infoViewText: nil,
        questions: [],
        partners: []
    )
    return SubmitClaimDeflectScreen(model: model, openChat: {})
}
