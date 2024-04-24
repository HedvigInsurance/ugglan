import SwiftUI
import hCore
import hCoreUI
import hGraphQL

enum PillColor {
    case green
    case yellow
    case blue
    case purple
    case pink
}

struct HelpCenterPill: View {
    private let title: String
    private let color: PillColor

    public init(
        title: String,
        color: PillColor
    ) {
        self.title = title
        self.color = color
    }

    @hColorBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                hText(title, style: .standardSmall)
                    .foregroundColor(hTextColor.primaryTranslucent)
                    .colorScheme(.light)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(pillBackgroundColor)
            .border(
                hBorderColor.translucentOne,
                width: 0.5
            )
            .cornerRadius(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @hColorBuilder
    var pillBackgroundColor: some hColor {
        switch color {
        case .blue:
            hHighlightColor.blueFillOne
        case .green:
            hSignalColor.greenFill
        case .yellow:
            hHighlightColor.yellowFillOne
        case .purple:
            hHighlightColor.purpleFillOne
        case .pink:
            hHighlightColor.pinkFillOne
        }
    }
}

enum QuestionType: String {
    case commonQuestions
    case allQuestions
    case relatedQuestions

    var title: String {
        switch self {
        case .commonQuestions:
            return L10n.hcCommonQuestionsTitle
        case .allQuestions:
            return L10n.hcAllQuestionTitle
        case .relatedQuestions:
            return L10n.hcRelatedQuestionsTitle
        }
    }
}

enum HelpViewSource {
    case homeView
    case topicView
    case questionView

    var title: String {
        switch self {
        case .homeView:
            return "home view"
        case .topicView:
            return "topic view"
        case .questionView:
            return "question view"
        }
    }
}

struct QuestionsItems: View {
    let questions: [Question]
    let questionType: QuestionType
    let source: HelpViewSource
    @EnvironmentObject var router: Router

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch questionType {
            case .commonQuestions:
                HelpCenterPill(title: questionType.title, color: .blue)
            case .allQuestions:
                HelpCenterPill(title: questionType.title, color: .purple)
            case .relatedQuestions:
                HelpCenterPill(title: questionType.title, color: .pink)
            }
            VStack(alignment: .leading, spacing: 4) {
                hSection(questions, id: \.self) { item in
                    hRow {
                        hText(item.question)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap {
                        let attributes: [String: String] = [
                            "question": item.questionEn,
                            "answer": item.answer,
                            "sourcePath": source.title,
                            "questionType": questionType.rawValue,
                        ]
                        log.info("question clicked", error: nil, attributes: ["helpCenter": attributes])
                        router.push(item)
                    }
                    .hWithoutHorizontalPadding
                    .hWithoutDividerPadding
                }
                .withoutHorizontalPadding
                .hSectionMinimumPadding
                .sectionContainerStyle(.transparent)
                .padding(.leading, 2)
            }
        }
    }
}

struct SupportView: View {
    let topic: ChatTopicType?

    var body: some View {
        HStack {
            VStack(spacing: 0) {
                hText(L10n.hcChatQuestion)
                    .foregroundColor(hTextColor.primaryTranslucent)
                hText(L10n.hcChatAnswer)
                    .foregroundColor(hTextColor.secondaryTranslucent)
                    .multilineTextAlignment(.center)

                hButton.MediumButton(type: .primary) {
                    NotificationCenter.default.post(name: .openChat, object: topic)
                } content: {
                    hText(L10n.hcChatButton)
                }
                .padding(.top, 24)
                .fixedSize()
            }
            .padding(.vertical, 32)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .background(hFillColor.opaqueOne)
    }
}

#Preview{
    HelpCenterPill(title: L10n.hcQuickActionsTitle, color: .green)
}
