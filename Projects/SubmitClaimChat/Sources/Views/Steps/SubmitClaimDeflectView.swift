import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimDeflectStepView: View {
    private let model: ClaimIntentOutcomeDeflection
    @EnvironmentObject var router: Router
    public init(
        model: ClaimIntentOutcomeDeflection,
    ) {
        self.model = model
    }

    public var body: some View {
        hSection {
            hButton(
                .large,
                .primary,
                content: .init(title: model.buttonTitle)
            ) {
                router.push(model)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

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
        hForm {
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
                            MarkdownView(
                                config: .init(
                                    text: model.content.description,
                                    fontStyle: .body1,
                                    color: hTextColor.Opaque.primary,
                                    linkColor: hTextColor.Opaque.primary,
                                    linkUnderlineStyle: .thick,
                                    isSelectable: true,
                                    onUrlClicked: { url in
                                        NotificationCenter.default.post(name: .openDeepLink, object: url)
                                    }
                                )
                            )
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
                            .sectionContainerStyle(.opaque)
                            .hWithoutHorizontalPadding([])
                        }
                    }
                    .padding(.top, .padding8)
                }
                .padding(.top, .padding8)
            }
            .sectionContainerStyle(.negative)
            .hWithoutHorizontalPadding([.section])
        }
        .hFormAttachToBottom {
            bottomAttachedView
        }
        .hFormBottomBackgroundColor(
            model.hasSupportView
                ? .gradient(from: hBackgroundColor.primary, to: hSurfaceColor.Opaque.primary) : .default
        )
        .edgesIgnoringSafeArea(.bottom)
    }

    @ViewBuilder var bottomAttachedView: some View {
        if model.hasSupportView {
            SupportView(openChat: openChat)
                .padding(.bottom, -.padding16)
        } else {
            VStack(spacing: .padding8) {
                ForEach(model.linkOnlyPartners, id: \.url) { partner in
                    if let url = URL(string: partner.url) {
                        hSection {
                            hButton(
                                .large,
                                .primary,
                                content: .init(
                                    title: partner.buttonText,
                                    buttonImage: .init(
                                        image: hCoreUIAssets.arrowNorthEast.view,
                                        alignment: .trailing
                                    )
                                ),
                                {
                                    Dependencies.urlOpener.open(url)
                                }
                            )
                        }
                        .sectionContainerStyle(.transparent)
                    }
                }
            }
            .padding(.bottom, .padding24)
        }
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
        ],
        linkOnlyPartners: [],
        buttonTitle: "Open deflect"
    )

    return SubmitClaimDeflectScreen(model: model, openChat: {})
        .preferredColorScheme(.dark)
}
