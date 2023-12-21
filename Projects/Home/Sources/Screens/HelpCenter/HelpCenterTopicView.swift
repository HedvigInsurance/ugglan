import Presentation
import SwiftUI
import hCore
import hCoreUI

struct HelpCenterTopicView: View {
    private var commonTopic: CommonTopic
    @PresentableStore var store: HomeStore

    public init(
        commonTopic: CommonTopic
    ) {
        self.commonTopic = commonTopic
    }

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                VStack(spacing: 40) {
                    QuestionsItems(questions: commonTopic.commonQuestions, questionType: .commonQuestions, source: .topicView)
                    QuestionsItems(questions: commonTopic.allQuestions, questionType: .allQuestions, source: .topicView)
                }
                SupportView()
            }
            .padding(.horizontal, 16)
        }
    }
}

extension HelpCenterTopicView {
    static func journey(commonTopic: CommonTopic) -> some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: HelpCenterTopicView(
                commonTopic: commonTopic
            )
        ) { action in
            if case .openFreeTextChat = action {
                DismissJourney()
            } else if case let .openHelpCenterQuestionView(question) = action {
                HelpCenterQuestionView.journey(question: question, title: commonTopic.title)
            }
        }
        .configureTitle(commonTopic.title)
        .withJourneyDismissButton
    }
}

#Preview{
    let questions: [Question] = [
        .init(
            question: "When do you charge for my insurance?",
            answer:
                "The total amount of your insurance cost is deducted retrospectively on the 27th of each month, for the current month.\n\nYour insurance starts on 1 June. The first dawn takes place on June 27, for the entire month of June. This means that you pay 27 days in arrears and 3 days in advance.\n\nThe insurance is valid even if the first payment has not been received.\n\nGo to Payments to view your full history.",
            relatedQuestions: []
        ),
        .init(
            question: "When do you charge for my insurance?",
            answer: "",
            relatedQuestions: []
        ),
        .init(
            question: "How do I make a claim?",
            answer: "",
            relatedQuestions: []
        ),
        .init(
            question: "How can I view my payment history?",
            answer: "",
            relatedQuestions: []
        ),
        .init(
            question: "What should I do if my payment fails?",
            answer: "",
            relatedQuestions: []
        ),
    ]

    return HelpCenterTopicView(
        commonTopic: .init(
            title: "Payments",
            commonQuestions: questions,
            allQuestions: questions
        )
    )
}
