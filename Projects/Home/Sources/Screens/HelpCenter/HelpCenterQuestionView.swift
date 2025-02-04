import PresentableStore
import SwiftUI
import TravelCertificate
import hCore
import hCoreUI

struct HelpCenterQuestionView: View {
    private var question: Question
    @State var height: CGFloat = 0
    @PresentableStore var store: HomeStore
    @ObservedObject var router: Router
    public init(
        question: Question,
        router: Router
    ) {
        self.question = question
        self.router = router
    }

    var body: some View {
        hForm {
            VStack(alignment: .leading, spacing: 32) {
                hSection {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 8) {
                            HelpCenterPill(title: L10n.hcQuestionTitle, color: .blue)
                            hText(question.question, style: .body1)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            HelpCenterPill(title: L10n.hcAnswerTitle, color: .green)
                            MarkdownView(
                                config: .init(
                                    text: question.answer,
                                    fontStyle: .body1,
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
            }
        }
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hSurfaceColor.Opaque.primary))
        .hFormAttachToBottom {
            SupportView(router: router)
                .padding(.top, .padding8)
        }
        .hFormIgnoreBottomPadding
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    HelpCenterQuestionView(
        question: Question(
            question: "When do you charge for my insurance?",
            questionEn: "When do you charge for my insurance?",
            answer:
                "The total amount of your insurance cost is deducted retrospectively on the 27th of each month, for the current month. \n\nYour insurance starts on 1 June. The first dawn takes place on June 27, for the entire month of June. This means that you pay 27 days in arrears and 3 days in advance. \n\nThe insurance is valid even if the first payment has not been received. \n\nGo to Payments to view your full history",
            relatedQuestions: []
        ),
        router: Router()
    )
}
