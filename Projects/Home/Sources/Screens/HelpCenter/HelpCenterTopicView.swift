import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct HelpCenterTopicView: View {
    private var topic: FaqTopic
    @PresentableStore var store: HomeStore
    @ObservedObject var router: Router
    public init(
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
                SupportView(router: router)
            }
        }
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hSurfaceColor.Opaque.primary))
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    let questions: [FAQModel] = [
        .init(
            id: "id1",
            question: "When do you charge for my insurance?",
            answer:
                "The total amount of your insurance cost is deducted retrospectively on the 27th of each month, for the current month.\n\nYour insurance starts on 1 June. The first dawn takes place on June 27, for the entire month of June. This means that you pay 27 days in arrears and 3 days in advance.\n\nThe insurance is valid even if the first payment has not been received.\n\nGo to Payments to view your full history.",
            relatedQuestions: []
        ),
        .init(
            id: "id2",
            question: "When do you charge for my insurance?",
            answer: "",
            relatedQuestions: []
        ),
        .init(
            id: "id3",
            question: "How do I make a claim?",
            answer: "",
            relatedQuestions: []
        ),
        .init(
            id: "id3",
            question: "How can I view my payment history?",
            answer: "",
            relatedQuestions: []
        ),
        .init(
            id: "id4",
            question: "What should I do if my payment fails?",
            answer: "",
            relatedQuestions: []
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
