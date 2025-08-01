import hCore
import hCoreUI
import SwiftUI

struct DisplayQuestionView: View {
    @EnvironmentObject var navigationVm: TerminationFlowNavigationViewModel

    let terminationQuestions: [TerminationQuestion] = [
        TerminationQuestion(
            question: L10n.terminationQ01,
            questionTranslated: L10n.terminationQ01_en,
            answer: L10n.terminationA01
        ),
        TerminationQuestion(
            question: L10n.terminationQ02,
            questionTranslated: L10n.terminationQ02_en,
            answer: L10n.terminationA02
        ),
        TerminationQuestion(
            question: L10n.terminationQ03,
            questionTranslated: L10n.terminationQ03_en,
            answer: L10n.terminationA03
        ),
    ]

    let deletionQuestions: [TerminationQuestion] = [
        TerminationQuestion(
            question: L10n.terminationQ02,
            questionTranslated: L10n.terminationQ02_en,
            answer: L10n.terminationA02
        ),
        TerminationQuestion(
            question: L10n.terminationQ03,
            questionTranslated: L10n.terminationQ03_en,
            answer: L10n.terminationA03
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            hSection {
                hText(L10n.terminateContractCommonQuestions)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .sectionContainerStyle(.transparent)
            VStack(spacing: 4) {
                ForEach(
                    navigationVm.isDeletion ? deletionQuestions : terminationQuestions,
                    id: \.question
                ) { question in
                    InfoExpandableView(
                        title: question.question,
                        text: question.answer,
                        questionClicked: {
                            let stringToLog =
                                navigationVm.isDeletion
                                    ? "deletion question clicked" : "termination question clicked"
                            log.info(stringToLog, attributes: ["question": question.questionTranslated])
                        }
                    ) { _ in
                        //                        store.send(.goToUrl(url: url))
                    }
                }
            }
        }
        .padding(.bottom, .padding16)
    }

    struct TerminationQuestion: Codable, Equatable, Hashable {
        let question: String
        let questionTranslated: String
        let answer: String
    }
}

#Preview {
    DisplayQuestionView()
}
