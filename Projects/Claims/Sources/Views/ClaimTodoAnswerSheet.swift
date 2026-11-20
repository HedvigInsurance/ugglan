import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

/// Answers one to-do question. It is hosted outside the claim detail view tree, so it reads the live
/// follow-up from the view model by id instead of taking a snapshot.
struct ClaimTodoAnswerSheet: View {
    let vm: ClaimTodoViewModel
    let followupId: String
    let questionId: String
    @State private var draft = ""
    @State private var dateDraft: Date?
    @State private var fieldError: String?
    @State private var showFileSourcePicker = false
    @State private var tappedAction: Action?

    private enum Action: Equatable {
        case save
        case binary(Bool)
        case cantAnswer
    }

    private var isBusy: Bool {
        vm.savingQuestionIds.contains(questionId) || vm.checkingFilesByQuestionId[questionId] != nil
    }

    var body: some View {
        hForm {
            if let followup = vm.followup(id: followupId),
                let question = followup.questions.first(where: { $0.id == questionId })
            {
                content(question, in: followup)
            }
        }
        .onChange(of: fieldError) { _, error in
            if let error {
                UIAccessibility.post(notification: .announcement, argument: error)
            }
        }
        .hFormContentPosition(.compact)
        .embededInNavigation(options: [.navigationBarHidden], tracking: String(describing: ClaimTodoAnswerSheet.self))
    }

    private func content(_ question: ClaimFollowupQuestion, in followup: ClaimFollowup) -> some View {
        hSection {
            VStack(spacing: .padding8) {
                VStack(alignment: .leading, spacing: .padding2) {
                    hText(question.text)
                        .accessibilityAddTraits(.isHeader)
                    if let hint = question.hint, !hint.isEmpty {
                        ClaimTodoSecondaryLine(text: hint)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, .padding8)
                input(question, in: followup)
                    .disabled(isBusy && !question.isFileQuestion)
                hButton(.large, .ghost, content: .init(title: question.passLabel)) {
                    UIApplication.dismissKeyboard()
                    tappedAction = .cantAnswer
                    await vm.cantAnswer(question, in: followup)
                    tappedAction = nil
                }
                .hButtonIsLoading(isBusy && tappedAction == .cantAnswer)
                .disabled(isBusy)
            }
            .padding(.top, .padding32)
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private func input(_ question: ClaimFollowupQuestion, in followup: ClaimFollowup) -> some View {
        switch question.content {
        case .fileUpload:
            fileInput(question, in: followup)
        case .binary:
            HStack(spacing: .padding8) {
                binaryButton(question, in: followup, value: true)
                binaryButton(question, in: followup, value: false)
            }
        case let .date(_, min, max):
            let isOutOfRange = Self.isOutOfRange(dateDraft, min: min, max: max)
            VStack(spacing: .padding8) {
                hDatePickerField(
                    config: .init(placeholder: L10n.claimFollowupDatePlaceholder, title: question.text),
                    selectedDate: dateDraft,
                    onContinue: { date in
                        dateDraft = date
                    }
                )
                if isOutOfRange {
                    InfoCard(text: L10n.claimFollowupNumberOutOfRange, type: .attention)
                }
            }
            .animation(.defaultSpring, value: isOutOfRange)
            saveButton(isDisabled: dateDraft == nil) {
                if let dateDraft {
                    await vm.answer(.date(dateDraft.localDateString), for: question, in: followup)
                }
            }
        case let .number(_, min, max):
            let isOutOfRange = Self.isOutOfRange(draft, min: min, max: max)
            VStack(spacing: .padding8) {
                hFloatingTextField(
                    masking: .init(type: .digits),
                    value: $draft,
                    placeholder: L10n.claimFollowupAnswerPlaceholder,
                    error: $fieldError
                )
                if isOutOfRange {
                    InfoCard(text: L10n.claimFollowupNumberOutOfRange, type: .attention)
                }
            }
            .animation(.defaultSpring, value: isOutOfRange)
            saveButton(isDisabled: draft.isEmpty) {
                await vm.answer(.number(draft), for: question, in: followup)
            }
        case .phoneNumber:
            hFloatingTextField(
                masking: .init(type: .phoneNumber),
                value: $draft,
                placeholder: L10n.phoneNumberRowTitle,
                error: $fieldError
            )
            saveButton(isDisabled: draft.isEmpty) {
                let masking = Masking(type: .phoneNumber)
                let phoneNumber = masking.unmaskedValue(text: draft)
                if masking.isValid(text: phoneNumber) {
                    await vm.answer(.phoneNumber(phoneNumber), for: question, in: followup)
                } else {
                    fieldError = L10n.claimFollowupPhoneInvalid
                }
            }
        case let .freeText(_, maxLength, _, _):
            hFloatingTextField(
                masking: .init(type: .none),
                value: $draft,
                placeholder: L10n.claimFollowupAnswerPlaceholder,
                error: $fieldError
            )
            .hFieldMultiline(true)
            saveButton(isDisabled: draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                if draft.count > maxLength {
                    fieldError = L10n.claimFollowupTextTooLong(maxLength)
                } else {
                    await vm.answer(.freeText(draft), for: question, in: followup)
                }
            }
        }
    }

    /// The picker sits on the always-present container, because "Choose another" reopens it while the add
    /// button is hidden. The held upload is replaced only when new files arrive.
    private func fileInput(_ question: ClaimFollowupQuestion, in followup: ClaimFollowup) -> some View {
        VStack(spacing: .padding16) {
            if let files = vm.checkingFilesByQuestionId[question.id] {
                HStack(spacing: .padding8) {
                    ClaimTodoFileLine(file: files.first, text: L10n.claimTodoCheckingFile)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ProgressView()
                        .frame(width: 20, height: 20)
                }
            } else if let pendingUpload = vm.pendingUploadByQuestionId[question.id] {
                ClaimTodoFileLine(
                    file: pendingUpload.files.first,
                    text: pendingUpload.files
                        .map(\.name)
                        .joined(separator: ", ")
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                InfoCard(text: L10n.claimTodoNudge, type: .attention)
                    .buttons([
                        .init(buttonTitle: L10n.claimTodoChooseAnother) {
                            showFileSourcePicker = true
                        },
                        .init(buttonTitle: L10n.claimTodoSendAnyway) { [vm, question, followup] in
                            Task { await vm.sendAnyway(question, in: followup) }
                        },
                    ])
                    .disabled(isBusy)
            } else {
                hButton(.large, .primary, content: .init(title: L10n.ClaimStatusDetail.addFiles)) {
                    showFileSourcePicker = true
                }
                .disabled(isBusy)
            }
        }
        .showFileSourcePicker($showFileSourcePicker) { [vm, question, followup] files in
            Task { await vm.upload(files, for: question, in: followup) }
        }
    }

    private func binaryButton(
        _ question: ClaimFollowupQuestion,
        in followup: ClaimFollowup,
        value: Bool
    ) -> some View {
        let title = value ? L10n.General.yes : L10n.General.no
        return hButton(.medium, .ghost, content: .init(title: title)) {
            tappedAction = .binary(value)
            await vm.answer(.binary(value), for: question, in: followup)
            tappedAction = nil
        }
        .hCustomButtonView {
            hText(title, style: .body1)
                .foregroundColor(PillColor.grey.pillTextColor(level: .two))
        }
        .hWrapInPill(color: .grey, colorLevel: .two)
        .hButtonTakeFullWidth(true)
        .hButtonIsLoading(isBusy && tappedAction == .binary(value))
    }

    private func saveButton(isDisabled: Bool, _ action: @escaping @MainActor () async -> Void) -> some View {
        hSaveButton(.primary) {
            UIApplication.dismissKeyboard()
            fieldError = nil
            tappedAction = .save
            await action()
            tappedAction = nil
        }
        .disabled(isDisabled)
        .hButtonIsLoading(isBusy && tappedAction == .save)
    }

    /// Date limits are advisory `yyyy-MM-dd` strings, so they warn like the number range and never block.
    private static func isOutOfRange(_ date: Date?, min: String?, max: String?) -> Bool {
        guard let value = date?.localDateString else { return false }
        let isBeforeMin = min.map { value < $0 } ?? false
        let isAfterMax = max.map { value > $0 } ?? false
        return isBeforeMin || isAfterMax
    }

    private static func isOutOfRange(_ value: String, min: Int?, max: Int?) -> Bool {
        guard let number = Int(value) else { return false }
        let isBelowMin = min.map { number < $0 } ?? false
        let isAboveMax = max.map { number > $0 } ?? false
        return isBelowMin || isAboveMax
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in FetchClaimsClientDemo() })
    Dependencies.shared.add(module: Module { () -> hClaimFollowupClient in ClaimFollowupClientDemo() })
    let store: ClaimsStore = globalAppStateContainer.get()
    store.followups = [
        ClaimFollowup(
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
                )
            ]
        )
    ]
    return ClaimTodoAnswerSheet(vm: ClaimTodoViewModel(), followupId: "followup", questionId: "police")
}
