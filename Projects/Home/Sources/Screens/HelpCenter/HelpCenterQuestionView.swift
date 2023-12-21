import Presentation
import SwiftUI
import hCore
import hCoreUI

struct HelpCenterQuestionView: View {
    private var question: Question
    @PresentableStore var store: HomeStore

    public init(
        question: Question
    ) {
        self.question = question
    }

    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    HelpCenterPill(title: "Question", color: .blue)
                    hText(question.question, style: .title3)
                }
                VStack(alignment: .leading, spacing: 8) {
                    HelpCenterPill(title: "Answer", color: .green)
                    hText(question.answer, style: .title3)
                        .foregroundColor(hTextColor.secondary)
                }

                QuestionsItems(questions: question.relatedQuestions, questionType: .relatedQuestions)
                SupportView()
            }
            .padding(.horizontal, 16)
        }
    }
}

extension HelpCenterQuestionView {
    static func journey(question: Question, title: String?) -> some JourneyPresentation {
        HostingJourney(
            HomeStore.self,
            rootView: HelpCenterQuestionView(
                question: question
            )
        ) { action in
            if case .openFreeTextChat = action {
                DismissJourney()
            }
        }
        .configureTitle(title ?? "")
        .withJourneyDismissButton
    }
}

#Preview{
    HelpCenterQuestionView(
        question: Question(
            question: "When do you charge for my insurance?",
            answer:
                "The total amount of your insurance cost is deducted retrospectively on the 27th of each month, for the current month. \n\nYour insurance starts on 1 June. The first dawn takes place on June 27, for the entire month of June. This means that you pay 27 days in arrears and 3 days in advance. \n\nThe insurance is valid even if the first payment has not been received. \n\nGo to Payments to view your full history",
            relatedQuestions: []
        )
    )
}
