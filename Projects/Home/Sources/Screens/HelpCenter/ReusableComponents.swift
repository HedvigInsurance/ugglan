import PresentableStore
import SwiftUI
import hCore
import hCoreUI

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

    var body: some View {
        hPill(text: title, color: color)
            .hFieldSize(.small)
    }
}

enum QuestionType: String {
    case commonQuestions
    case allQuestions
    case relatedQuestions
    case searchQuestions

    var title: String {
        switch self {
        case .commonQuestions:
            return L10n.hcCommonQuestionsTitle
        case .allQuestions:
            return L10n.hcAllQuestionTitle
        case .relatedQuestions:
            return L10n.hcRelatedQuestionsTitle
        case .searchQuestions:
            return L10n.hcQuestionsTitle
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
    let questions: [FAQModel]
    let questionType: QuestionType
    let source: HelpViewSource
    @EnvironmentObject var router: Router

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch questionType {
            case .commonQuestions, .searchQuestions:
                HelpCenterPill(title: questionType.title, color: .blue)
            case .allQuestions:
                HelpCenterPill(title: questionType.title, color: .purple)
            case .relatedQuestions:
                HelpCenterPill(title: questionType.title, color: .pink)
            }
            VStack(alignment: .leading, spacing: .padding4) {
                hSection(questions, id: \.self) { item in
                    hRow {
                        hText(item.question)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap {
                        let attributes: [String: String] = [
                            "question": item.question,
                            "answer": item.answer,
                            "sourcePath": source.title,
                            "questionType": questionType.rawValue,
                        ]
                        log.info("question clicked", error: nil, attributes: ["helpCenter": attributes])
                        router.push(item)
                    }
                    .hWithoutHorizontalPadding([.row, .divider])
                }
                .hWithoutHorizontalPadding([.section])
                .sectionContainerStyle(.transparent)
                .padding(.leading, 2)
            }
        }
    }
}

struct SupportView: View {
    @PresentableStore var store: HomeStore
    @ObservedObject var router: Router
    @SwiftUI.Environment(\.sizeCategory) private var sizeCategory

    var body: some View {
        hSection {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    hText(L10n.hcChatQuestion)
                        .foregroundColor(hTextColor.Translucent.primary)
                    hText(L10n.hcChatAnswer)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .multilineTextAlignment(.center)
                }
                .accessibilityElement(children: .combine)
                PresentableStoreLens(HomeStore.self) { state in
                    state.hasSentOrRecievedAtLeastOneMessage
                } _: { hasSentOrRecievedAtLeastOneMessage in
                    VStack(spacing: .padding8) {
                        if hasSentOrRecievedAtLeastOneMessage {
                            hButton.MediumButton(type: .primary) {
                                router.push(HelpCenterNavigationRouterType.inbox)
                            } content: {
                                hText(L10n.hcChatGoToInbox)
                            }
                        }
                        hButton.MediumButton(type: hasSentOrRecievedAtLeastOneMessage ? .ghost : .primary) {
                            NotificationCenter.default.post(
                                name: .openChat,
                                object: ChatType.newConversation
                            )
                        } content: {
                            hText(L10n.hcChatButton)
                        }
                    }
                    .padding(.top, .padding24)
                }
                .presentableStoreLensAnimation(.default)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, .padding32)
            .padding(.bottom, .padding24)
        }
        .frame(maxWidth: .infinity)
        .background(hSurfaceColor.Opaque.primary)
    }
}

#Preview {
    HelpCenterPill(title: L10n.hcQuickActionsTitle, color: .green)
}

struct QuickActionView: View {
    let quickAction: QuickAction
    let onQuickAction: () -> Void

    var body: some View {
        hSection {
            hRow {
                VStack(alignment: .leading, spacing: 0) {
                    hText(quickAction.displayTitle)

                    hText(quickAction.displaySubtitle, style: .label)
                        .foregroundColor(hTextColor.Opaque.secondary)

                }
                Spacer()
            }
            .withChevronAccessory
            .verticalPadding(.padding12)
            .onTap {
                log.addUserAction(
                    type: .click,
                    name: "help center quick action",
                    attributes: ["action": quickAction.id]
                )
                onQuickAction()
            }
        }
        .hWithoutHorizontalPadding([.section])
        .sectionContainerStyle(.opaque)
    }
}
