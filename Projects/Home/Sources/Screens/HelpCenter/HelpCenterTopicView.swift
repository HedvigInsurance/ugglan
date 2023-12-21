import Presentation
import SwiftUI
import hCore
import hCoreUI

struct HelpCenterTopicView: View {

    private var commonTopic: CommonTopic

    public init(
        commonTopic: CommonTopic
    ) {
        self.commonTopic = commonTopic
    }

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                VStack(spacing: 40) {
                    QuestionsItems(questions: commonTopic.commonQuestions, isCommonQuestions: true)
                    QuestionsItems(questions: commonTopic.allQuestions, isCommonQuestions: false)
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
            }
        }
        .configureTitle(commonTopic.title)
        .withJourneyDismissButton
    }
}

#Preview{
    HelpCenterTopicView(
        commonTopic: .init(
            title: "Payments",
            commonQuestions: [
                .init(
                    question: "When do you charge for my insurance?",
                    answer: ""
                ),
                .init(
                    question: "When do you charge for my insurance?",
                    answer: ""
                ),
                .init(
                    question: "How do I make a claim?",
                    answer: ""
                ),
                .init(
                    question: "How can I view my payment history?",
                    answer: ""
                ),
                .init(
                    question: "What should I do if my payment fails?",
                    answer: ""
                ),
            ],
            allQuestions: [
                .init(
                    question: "When do you charge for my insurance?",
                    answer: ""
                ),
                .init(
                    question: "When do you charge for my insurance?",
                    answer: ""
                ),
                .init(
                    question: "How do I make a claim?",
                    answer: ""
                ),
                .init(
                    question: "How can I view my payment history?",
                    answer: ""
                ),
                .init(
                    question: "What should I do if my payment fails?",
                    answer: ""
                ),
            ]
        )
    )
}
