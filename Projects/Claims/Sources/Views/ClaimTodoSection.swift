import SwiftUI
import hCore
import hCoreUI

struct ClaimTodoSection: View {
    @Bindable var vm: ClaimTodoViewModel
    let followup: ClaimFollowup

    var body: some View {
        hSection(header: header) {
            VStack(spacing: 0) {
                ForEach(followup.questions) { question in
                    ClaimTodoRow(vm: vm, question: question)
                    if question.id != followup.questions.last?.id {
                        hRowDivider()
                            .hWithoutHorizontalPadding([.divider])
                    }
                }
            }
        }
        .sectionContainerStyle(.negative)
        .sectionContainerDecorations([.border, .shadow])
        .detent(
            item: $vm.answeringQuestion,
            presentationStyle: .detent(style: [.height])
        ) { [vm, followup] question in
            ClaimTodoAnswerSheet(vm: vm, followupId: followup.id, questionId: question.id)
        }
    }

    /// `withHeader` has no trailing slot, so this rebuilds its title row with the count on the right.
    private var header: some View {
        HStack {
            hText(L10n.homeTodoSectionTitle)
            Spacer()
            if followup.questionsLeft > 0 {
                hText(L10n.claimTodoLeft(followup.questionsLeft), style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
        .padding(.bottom, .padding8)
        .accessibilityElement(children: .combine)
    }
}

private struct ClaimTodoRow: View {
    let vm: ClaimTodoViewModel
    let question: ClaimFollowupQuestion

    private var isOpen: Bool {
        question.state == .todo
    }

    private var isBusy: Bool {
        vm.savingQuestionIds.contains(question.id) || vm.checkingFilesByQuestionId[question.id] != nil
    }

    var body: some View {
        hRow {
            HStack(spacing: .padding16) {
                (question.isFileQuestion ? hCoreUIAssets.document.view : hCoreUIAssets.infoOutlined.view)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)
                textColumn
                    .frame(maxWidth: .infinity, alignment: .leading)
                trailing
            }
        }
    }

    private var textColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(question.text, style: .body1)
                .fixedSize(horizontal: false, vertical: true)
            if let checkingFiles = vm.checkingFilesByQuestionId[question.id] {
                ClaimTodoFileLine(file: checkingFiles.first, text: L10n.claimTodoCheckingFile)
                    .padding(.top, .padding6)
            } else if isOpen {
                hText(L10n.homeTodoRequiresActionSubtitle, style: .label)
                    .foregroundColor(hSignalColor.Red.text)
                if let hint = question.hint, !hint.isEmpty {
                    ClaimTodoSecondaryLine(text: hint)
                }
            } else {
                doneLine
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(doneValue)
    }

    private var doneValue: String {
        guard question.state == .answered else { return "" }
        return question.isFileQuestion ? L10n.claimFollowupFileAdded : L10n.generalDoneButton
    }

    private var passedText: String {
        if let cantAnswerLabel = question.cantAnswerLabel, !cantAnswerLabel.isEmpty {
            return cantAnswerLabel
        }
        return question.isFileQuestion ? L10n.claimTodoDontHaveDone : L10n.claimFollowupCantAnswerState
    }

    @ViewBuilder
    private var doneLine: some View {
        switch (question.state, question.content) {
        case let (.answered, .fileUpload(currentFiles)):
            if !currentFiles.isEmpty {
                ClaimTodoFileLine(
                    file: currentFiles.first?.asFile,
                    text:
                        currentFiles
                        .map(\.fileName)
                        .joined(separator: ", ")
                )
                .padding(.top, .padding6)
            }
        case (.cantAnswer, _):
            ClaimTodoSecondaryLine(text: passedText)
        default:
            ClaimTodoSecondaryLine(text: answerText)
        }
    }

    @ViewBuilder
    private var trailing: some View {
        if isBusy {
            ProgressView()
                .frame(width: 20, height: 20)
        } else if isOpen {
            hButton(
                .small,
                .secondary,
                content: .init(title: question.isFileQuestion ? L10n.generalAddButton : L10n.claimTodoAnswer)
            ) {
                vm.open(question)
            }
            .accessibilityHint(question.text)
        } else {
            hCoreUIAssets.checkmarkFilled.view
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(hSignalColor.Green.element)
                .accessibilityHidden(true)
        }
    }

    private var answerText: String {
        switch question.content {
        case let .binary(currentValue):
            guard let currentValue else { return "" }
            return currentValue ? L10n.General.yes : L10n.General.no
        case let .freeText(_, _, currentValue, currentAudio):
            return currentAudio != nil ? L10n.claimFollowupAudioAdded : currentValue ?? ""
        case let .date(currentValue, _, _):
            return currentValue?.localDateToDate?.displayDateDDMMMYYYYFormat ?? currentValue ?? ""
        case let .number(currentValue, _, _), let .phoneNumber(currentValue):
            return currentValue ?? ""
        case .fileUpload:
            return ""
        }
    }
}

struct ClaimTodoSecondaryLine: View {
    let text: String

    var body: some View {
        hText(text, style: .label)
            .foregroundColor(hTextColor.Opaque.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct ClaimTodoFileLine: View {
    let file: File?
    let text: String

    var body: some View {
        HStack(spacing: .padding10) {
            if let file {
                thumbnail(file)
            }
            ClaimTodoSecondaryLine(text: text)
        }
    }

    /// `FileView` draws a non-image as an icon plus its name, which does not fit in 40pt.
    private func thumbnail(_ file: File) -> some View {
        Group {
            if file.mimeType.isImage {
                FileView(file: file) {}
            } else {
                hCoreUIAssets.document.view
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .frame(width: 40, height: 40)
        .background { hSurfaceColor.Opaque.primary }
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusS))
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in FetchClaimsClientDemo() })
    Dependencies.shared.add(module: Module { () -> hClaimFollowupClient in ClaimFollowupClientDemo() })
    return hForm {
        ClaimTodoSection(
            vm: ClaimTodoViewModel(),
            followup: ClaimFollowup(
                id: "followup",
                claimId: "claim",
                status: .submitted,
                questions: [
                    .init(
                        id: "police",
                        text: "Police report",
                        hint: "The confirmation from the police is enough, as a PDF or a photo.",
                        state: .todo,
                        cantAnswerComment: nil,
                        content: .fileUpload(currentFiles: [])
                    ),
                    .init(
                        id: "receipt",
                        text: "Receipt for the bike",
                        state: .answered,
                        cantAnswerComment: nil,
                        content: .fileUpload(currentFiles: [
                            .init(
                                id: "receipt-file",
                                url: URL(string: "https://example.com/orderbekraftelse.pdf")!,
                                contentType: "application/pdf",
                                fileName: "orderbekraftelse.pdf",
                                relevance: .match
                            )
                        ])
                    ),
                    .init(
                        id: "locked",
                        text: "Was the bike locked?",
                        state: .answered,
                        cantAnswerComment: nil,
                        content: .binary(currentValue: true)
                    ),
                ]
            )
        )
    }
}
