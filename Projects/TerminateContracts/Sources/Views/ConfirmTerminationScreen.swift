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
            hText("Common questions")
                .padding(.leading, 16)

            VStack(spacing: 4) {
                ForEach(questions, id: \.question) { question in
                    hSection {
                        SwiftUI.Button {
                            if let index = self.selectedQuestions.firstIndex(where: { $0 == question }) {
                                selectedQuestions.remove(at: index)
                            } else {
                                selectedQuestions.append(question)
                            }
                        } label: {
                            EmptyView()
                        }
                        .buttonStyle(
                            ConfirmTerminationButtonStyle(question: question, selectedQuestions: selectedQuestions)
                        )
                    }
                }
            }
        }
    }

    struct TerminationQuestion: Codable, Equatable, Hashable {
        let question: String
        let answer: String
    }

    struct ConfirmTerminationButtonStyle: SwiftUI.ButtonStyle {
        var question: TerminationQuestion
        var selectedQuestions: [TerminationQuestion]
        @State var height: CGFloat = 0
        @PresentableStore var store: TerminationContractStore

        func makeBody(configuration: Configuration) -> some View {
            VStack(alignment: .center, spacing: 11) {
                HStack(spacing: 8) {
                    hText(question.question, style: .body)
                    Spacer()
                    Image(
                        uiImage: selectedQuestions.contains(question)
                            ? hCoreUIAssets.minusSmall.image : hCoreUIAssets.plusSmall.image
                    )
                    .resizable()
                    .frame(width: 16, height: 16)
                    .transition(.opacity.animation(.easeOut))
                    .padding(.trailing, 4)
                }
                .padding(.vertical, 13)

                if selectedQuestions.contains(question) {
                    VStack(alignment: .leading, spacing: 12) {
                        CustomTextViewRepresentable(
                            text: question.answer,
                            fixedWidth: UIScreen.main.bounds.width - 32,
                            fontSize: .body,
                            height: $height
                        ) { url in
                            store.send(.dismissTerminationFlow)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                store.send(.goToUrl(url: url))
                            }
                        }
                        .frame(height: height)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                }
            }
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
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
