import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct DisplayContractTable: View {
    let config: TerminationConfirmConfig?
    let terminationDate: String

    var body: some View {
        hSection {
            if let config = config {
                ContractRow(
                    image: config.image?.bgImage,
                    terminationMessage: L10n.contractStatusToBeTerminated(terminationDate),
                    contractDisplayName: config.contractDisplayName,
                    contractExposureName: config.contractExposureName
                )
            }
        }
    }
}

struct DisplayQuestionView: View {
    @PresentableStore var store: TerminationContractStore
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
                    (store.state.config?.isDeletion ?? false) ? deletionQuestions : terminationQuestions,
                    id: \.question
                ) { question in
                    InfoExpandableView(
                        title: question.question,
                        text: question.answer,
                        questionClicked: {
                            let stringToLog =
                                (store.state.config?.isDeletion ?? false)
                                ? "deletion question clicked" : "termination question clicked"
                            log.info(stringToLog, attributes: ["question": question.questionTranslated])
                        }
                    ) { url in
                        store.send(.goToUrl(url: url))
                    }
                }
            }
        }
        .padding(.bottom, 16)
    }

    struct TerminationQuestion: Codable, Equatable, Hashable {
        let question: String
        let questionTranslated: String
        let answer: String
    }
}

#Preview{
    DisplayQuestionView()
}
