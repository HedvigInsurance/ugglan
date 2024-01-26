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
                VStack(alignment: .leading, spacing: 8) {
                    HelpCenterPill(title: L10n.hcQuestionTitle, color: .blue)
                    hText(question.question, style: .body)
                }
                .padding(.horizontal, 16)
                VStack(alignment: .leading, spacing: 8) {
                    HelpCenterPill(title: L10n.hcAnswerTitle, color: .green)
                    CustomTextViewRepresentable(
                        text: question.answer,
                        fixedWidth: UIScreen.main.bounds.width - 32,
                        height: $height,
                        fontStyle: .standardLarge
                    ) { url in
                        Task {
                            do {
                                if let deepLink = DeepLink.getType(from: url), deepLink == .travelCertificate {
                                    _ = try await TravelInsuranceFlowJourney.getTravelCertificate()
                                }
                                store.send(.goToURL(url: url))
                            } catch {}
                        }
                    }
                    .frame(height: height)
                }
                .padding(.horizontal, 16)
                SupportView()
                    .padding(.top, 8)
            }
        }
        .hFormBottomBackgroundColor(.gradient(from: hBackgroundColor.primary, to: hFillColor.opaqueOne))
        .edgesIgnoringSafeArea(.bottom)
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
            } else if case .dismissHelpCenter = action {
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
