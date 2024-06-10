import Presentation
import SwiftUI
import TravelCertificate
import hCore
import hCoreUI

struct HelpCenterQuestionView: View {
    private var question: Question
    @State var height: CGFloat = 0
    @PresentableStore var store: HomeStore

    public init(
        question: Question
    ) {
        self.question = question
    }

    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: 32) {
                hSection {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 8) {
                            HelpCenterPill(title: L10n.hcQuestionTitle, color: .blue)
                            hText(question.question, style: .body)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            HelpCenterPill(title: L10n.hcAnswerTitle, color: .green)
                            MarkdownView(
                                config: .init(
                                    text: question.answer,
                                    fontStyle: .standard,
                                    color: hTextColor.Opaque.secondary,
                                    linkColor: hTextColor.Opaque.primary,
                                    linkUnderlineStyle: .single
                                ) { url in
                                    NotificationCenter.default.post(name: .openDeepLink, object: url)
                                }
                            )
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                SupportView(topic: question.topicType)
                    .padding(.top, 8)
            }
        }
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hSurfaceColor.Opaque.primary))
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview{
    HelpCenterQuestionView(
        question: Question(
            question: "When do you charge for my insurance?",
            questionEn: "When do you charge for my insurance?",
            answer:
                "The total amount of your insurance cost is deducted retrospectively on the 27th of each month, for the current month. \n\nYour insurance starts on 1 June. The first dawn takes place on June 27, for the entire month of June. This means that you pay 27 days in arrears and 3 days in advance. \n\nThe insurance is valid even if the first payment has not been received. \n\nGo to Payments to view your full history",
            topicType: .payments,
            relatedQuestions: []
        )
    )
}
