import SwiftUI
import hCore
import hCoreUI

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
        TerminationQuestion(question: L10n.terminationQ01, answer: L10n.terminationA01),
        TerminationQuestion(question: L10n.terminationQ02, answer: L10n.terminationA02),
        TerminationQuestion(question: L10n.terminationQ03, answer: L10n.terminationA03),
    ]

    let deletionQuestions: [TerminationQuestion] = [
        TerminationQuestion(question: L10n.terminationQ02, answer: L10n.terminationA02),
        TerminationQuestion(question: L10n.terminationQ03, answer: L10n.terminationA03),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            hText(L10n.terminateContractCommonQuestions)
                .padding(.leading, 16)
            VStack(spacing: 4) {
                ForEach(
                    (store.state.config?.isDeletion ?? false) ? deletionQuestions : terminationQuestions,
                    id: \.question
                ) { question in
                    InfoExpandableView(title: question.question, text: question.answer) { url in
                        store.send(.goToUrl(url: url))
                    }
                }
            }
        }
        .padding(.bottom, 16)
    }

    struct TerminationQuestion: Codable, Equatable, Hashable {
        let question: String
        let answer: String
    }
}

#Preview{
    DisplayQuestionView()
}
