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
                    image: config.image?.getPillowType.bgImage,
                    terminationMessage: L10n.contractStatusToBeTerminated(terminationDate),
                    contractDisplayName: config.contractDisplayName,
                    contractExposureName: config.contractExposureName
                )
            }
        }
    }
}

struct DisplayQuestionView: View {
    let questions: [TerminationQuestion] = [
        TerminationQuestion(question: L10n.terminationQ01, answer: L10n.terminationA01),
        TerminationQuestion(question: L10n.terminationQ02, answer: L10n.terminationA02),
        TerminationQuestion(question: L10n.terminationQ03, answer: L10n.terminationA03),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            hText(L10n.terminateContractCommonQuestions)
                .padding(.leading, 16)
            VStack(spacing: 4) {
                ForEach(questions, id: \.question) { question in
                    InfoExpandableView(title: question.question, text: question.answer)
                }
            }
        }
    }

    struct TerminationQuestion: Codable, Equatable, Hashable {
        let question: String
        let answer: String
    }
}

#Preview{
    DisplayQuestionView()
}
