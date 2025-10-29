import Chat
import SwiftUI
import hCore
import hCoreUI

public struct HelpCenterTopicNavigation: View {
    private let router = Router()
    let topic: FaqTopic

    public init(topic: FaqTopic) {
        self.topic = topic
    }

    public var body: some View {
        RouterHost(router: router, options: [.navigationType(type: .large)], tracking: topic) {
            HelpCenterTopicView(topic: topic, router: router)
                .navigationTitle(topic.title)
                .withDismissButton()
                .routerDestination(for: FAQModel.self) { question in
                    HelpCenterQuestionView(question: question, router: router)
                }
                .routerDestination(for: HelpCenterNavigationRouterType.self) { _ in
                    InboxView()
                        .configureTitle(L10n.chatConversationInbox)
                }
        }
    }
}

struct HelpCenterTopicView: View {
    private var topic: FaqTopic
    @ObservedObject var router: Router
    init(
        topic: FaqTopic,
        router: Router
    ) {
        self.topic = topic
        self.router = router
    }

    var body: some View {
        hForm {
            VStack(spacing: 40) {
                hSection {
                    VStack(spacing: 40) {
                        QuestionsItems(
                            questions: topic.commonQuestions,
                            questionType: .commonQuestions,
                            source: .topicView
                        )
                        QuestionsItems(
                            questions: topic.allQuestions,
                            questionType: .allQuestions,
                            source: .topicView
                        )
                    }
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .hFormAttachToBottom {
            SupportView(router: router)
        }
        .hFormIgnoreBottomPadding
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hSurfaceColor.Opaque.primary))
    }
}

#Preview {
    let questions: [FAQModel] = [
        .init(
            id: "id1",
            question: "When do you charge for my insurance?",
            answer:
                "The total amount of your insurance cost is deducted retrospectively on the 27th of each month, for the current month.\n\nYour insurance starts on 1 June. The first dawn takes place on June 27, for the entire month of June. This means that you pay 27 days in arrears and 3 days in advance.\n\nThe insurance is valid even if the first payment has not been received.\n\nGo to Payments to view your full history."
        ),
        .init(
            id: "id2",
            question: "When do you charge for my insurance?",
            answer: ""
        ),
        .init(
            id: "id3",
            question: "How do I make a claim?",
            answer: ""
        ),
        .init(
            id: "id3",
            question: "How can I view my payment history?",
            answer: ""
        ),
        .init(
            id: "id4",
            question: "What should I do if my payment fails?",
            answer: ""
        ),
    ]

    return HelpCenterTopicView(
        topic: .init(
            id: "id",
            title: "Payments",
            commonQuestions: questions,
            allQuestions: questions
        ),
        router: Router()
    )
}
