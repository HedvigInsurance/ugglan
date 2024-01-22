import SwiftUI
import hCore
import hCoreUI

struct ConfirmTerminationScreen: View {
    @PresentableStore var store: TerminationContractStore
    let config: TerminationConfirmConfig?
    let questions: [TerminationQuestion] = [
        TerminationQuestion(question: L10n.terminationQ01, answer: L10n.terminationA01),
        TerminationQuestion(question: L10n.terminationQ02, answer: L10n.terminationA02),
        TerminationQuestion(question: L10n.terminationQ03, answer: L10n.terminationA03),
    ]

    @State var selectedQuestions: [TerminationQuestion] = []
    let onSelected: () -> Void

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                displayContractTable
                displayQuestionView
            }
        }
        .hFormAttachToBottom {
            VStack(spacing: 8) {
                hButton.LargeButton(type: .alert) {
                    onSelected()
                } content: {
                    hText(L10n.terminationConfirmButton)
                }
                hButton.LargeButton(type: .ghost) {
                    store.send(.dismissTerminationFlow)
                } content: {
                    hText(L10n.generalCancelButton)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    var displayContractTable: some View {
        hSection {
            if let config = config {
                ContractRow(
                    image: config.image?.getPillowType.bgImage,
                    terminationMessage: L10n.contractStatusToBeTerminated(
                        store.state.terminationDateStep?.date?.displayDateDDMMMYYYYFormat ?? ""
                    ),
                    contractDisplayName: config.contractDisplayName,
                    contractExposureName: config.contractExposureName
                )
            }
        }
    }

    var displayQuestionView: some View {
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

public struct TerminationConfirmConfig: Codable & Equatable & Hashable {
    public var image: String?
    public var contractDisplayName: String
    public var contractExposureName: String

    public init(
        image: String?,
        contractDisplayName: String,
        contractExposureName: String
    ) {
        self.image = image
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
    }
}

#Preview{
    ConfirmTerminationScreen(
        config: .init(image: hCoreUIAssets.pillowHome.name, contractDisplayName: "", contractExposureName: ""),
        onSelected: {}
    )
}
