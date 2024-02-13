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
            VStack(spacing: 40) {
                hSection {
                    VStack(spacing: 40) {
                        QuestionsItems(
                            questions: commonTopic.commonQuestions,
                            questionType: .commonQuestions,
                            source: .topicView
                        )
                        QuestionsItems(
                            questions: commonTopic.allQuestions,
                            questionType: .allQuestions,
                            source: .topicView
                        )
                    }
                }
                .sectionContainerStyle(.transparent)
                SupportView(topic: commonTopic.type)
            }
        }
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hFillColor.opaqueOne))
        .edgesIgnoringSafeArea(.bottom)
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
            questionEn: "When do you charge for my insurance?",
            answer:
                "The total amount of your insurance cost is deducted retrospectively on the 27th of each month, for the current month.\n\nYour insurance starts on 1 June. The first dawn takes place on June 27, for the entire month of June. This means that you pay 27 days in arrears and 3 days in advance.\n\nThe insurance is valid even if the first payment has not been received.\n\nGo to Payments to view your full history.",
            topicType: .payments,
            relatedQuestions: []
        ),
        .init(
            question: "When do you charge for my insurance?",
            questionEn: "When do you charge for my insurance?",
            answer: "",
            topicType: .payments,
            relatedQuestions: []
        ),
        .init(
            question: "How do I make a claim?",
            questionEn: "How do I make a claim?",
            answer: "",
            topicType: .payments,
            relatedQuestions: []
        ),
        .init(
            question: "How can I view my payment history?",
            questionEn: "How can I view my payment history?",
            answer: "",
            topicType: .payments,
            relatedQuestions: []
        ),
        .init(
            question: "What should I do if my payment fails?",
            questionEn: "What should I do if my payment fails?",
            answer: "",
            topicType: .payments,
            relatedQuestions: []
        ),
    ]

    return HelpCenterTopicView(
        commonTopic: .init(
            title: "Payments",
            type: .payments,
            commonQuestions: questions,
            allQuestions: questions
        )
    )
}
