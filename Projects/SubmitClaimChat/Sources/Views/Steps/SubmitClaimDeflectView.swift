import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimDeflectScreen: View {
    private let model: ClaimIntentOutcomeDeflection
    private let openChat: () -> Void

    public init(
        model: ClaimIntentOutcomeDeflection,
        openChat: @escaping () -> Void
    ) {
        self.model = model
        self.openChat = openChat
    }

    public var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                if let warningText = model.warningText {
                    hRow {
                        InfoCard(text: warningText, type: .attention)
                            .accessibilitySortPriority(2)
                    }
                    .verticalPadding(0)
                }

                hRow {
                    VStack(spacing: .padding16) {
                        if let infoViewTitle = model.title, let infoViewText = model.infoText {
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
                }
                .verticalPadding(0)
                hRow {
                    VStack(alignment: .leading, spacing: 8) {
                        hText(model.content.title)
                        hText(model.content.description)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                    .padding(.top, .padding8)
                    .accessibilityElement(children: .combine)
                }
                .verticalPadding(0)
                VStack(spacing: .padding4) {
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
                .padding(.top, .padding8)
                ForEach(model.linkOnlyPartners, id: \.id) { partner in
                    hRow {
                        ParnerButtonView(model: partner, overrideColorSchema: false)
                    }
                }
                SupportView(openChat: openChat)
                    .padding(.top, .padding56)
            }
            .padding(.top, .padding8)
        }
        .sectionContainerStyle(.negative)
        .hWithoutHorizontalPadding([.section])
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)

    let model = ClaimIntentOutcomeDeflection(
        title: "title",
        content: .init(
            title: "content title",
            description: "content description"
        ),
        partners: [
            .init(
                id: "partnerId1",
                imageUrl: nil,
                url: nil,
                phoneNumber: nil,
                title: "partner title",
                description: "partner description",
                info: "info",
                buttonText: "button",
                preferredImageHeight: nil
            )
        ],
        infoText: "info text",
        warningText: "warning text",
        questions: [
            .init(question: "question 1", answer: "answer 1"),
            .init(question: "question 2", answer: "answer 2"),
        ]
    )

    return SubmitClaimDeflectScreen(model: model, openChat: {})
        .preferredColorScheme(.dark)
}
