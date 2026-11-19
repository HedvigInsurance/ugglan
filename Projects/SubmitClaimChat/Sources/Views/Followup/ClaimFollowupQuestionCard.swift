import Claims
import SwiftUI
import hCore
import hCoreUI

struct ClaimFollowupQuestionCard: View {
    let vm: ClaimFollowupViewModel
    let question: ClaimFollowupQuestion
    @State private var draft = ""
    @State private var fieldError: String?
    @State private var showFileSourcePicker = false
    @State private var datePicker: DatePickerViewModel?
    @State private var pickedDate = Date()

    var body: some View {
        hSection {
            VStack(alignment: .leading, spacing: .padding16) {
                header
                if isEditing {
                    inputCard
                } else if isRecording {
                    voiceCard
                } else {
                    savedAnswer
                    actions
                }
                skipButton
            }
            .padding(.padding16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay {
                RoundedRectangle(cornerRadius: .cornerRadiusXL)
                    .strokeBorder(hBorderColor.primary, lineWidth: 1)
            }
        }
        .sectionContainerStyle(.transparent)
        .disabled(isSaving)
        .animation(.defaultSpring, value: isEditing)
        .animation(.defaultSpring, value: isRecording)
        .detent(item: $datePicker, presentationStyle: .detent(style: [.height])) { datePickerVm in
            DatePickerView(vm: datePickerVm)
                .embededInNavigation(options: .largeNavigationBar, tracking: String(describing: DatePickerView.self))
        }
    }

    private var isSaving: Bool { vm.savingQuestionId == question.id }
    private var isEditing: Bool { vm.editingQuestionId == question.id }
    private var isRecording: Bool { vm.voiceQuestionId == question.id }

    private var header: some View {
        HStack(alignment: .top, spacing: .padding12) {
            stateMark
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: .padding2) {
                hText(question.text)
                    .fixedSize(horizontal: false, vertical: true)
                hText(stateText, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var stateMark: some View {
        switch question.state {
        case .todo:
            Circle()
                .fill(hSignalColor.Amber.element)
                .frame(width: 10, height: 10)
        case .answered:
            hCoreUIAssets.checkmarkFilled.view
                .foregroundColor(hSignalColor.Green.element)
        case .cantAnswer:
            Circle()
                .fill(hFillColor.Opaque.disabled)
                .frame(width: 10, height: 10)
        }
    }

    private var stateText: String {
        switch question.state {
        case .todo: L10n.claimFollowupStateTodo
        case .answered: L10n.claimFollowupStateAnswered
        case .cantAnswer: L10n.claimFollowupCantAnswerState
        }
    }

    @ViewBuilder
    private var savedAnswer: some View {
        switch question.state {
        case .answered:
            answerValue
        case .cantAnswer:
            if let comment = question.cantAnswerComment, !comment.isEmpty {
                hText(comment, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .todo:
            EmptyView()
        }
    }

    @ViewBuilder
    private var answerValue: some View {
        switch question.content {
        case .binary, .fileUpload:
            EmptyView()
        case let .freeText(_, _, currentValue, currentAudio):
            if currentAudio != nil {
                valueField(L10n.claimFollowupAudioAdded)
            } else if let currentValue {
                valueField(currentValue)
            }
        case let .date(currentValue):
            if let currentValue {
                valueField(currentValue.localDateToDate?.displayDateDDMMMYYYYFormat ?? currentValue)
            }
        case let .number(currentValue, min, max):
            if let currentValue {
                VStack(alignment: .leading, spacing: .padding8) {
                    valueField(currentValue)
                    if Self.isOutOfRange(currentValue, min: min, max: max) {
                        hText(L10n.claimFollowupNumberOutOfRange, style: .label)
                            .foregroundColor(hSignalColor.Amber.text)
                    }
                }
            }
        case let .phoneNumber(currentValue):
            if let currentValue {
                valueField(currentValue)
            }
        }
    }

    private func valueField(_ value: String) -> some View {
        valueFieldContainer {
            hText(value)
                .lineLimit(4)
        }
        .accessibilityElement(children: .combine)
    }

    private func valueFieldContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: .padding2) {
            hText(L10n.claimFollowupAnswerPlaceholder, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
            content()
        }
        .padding(.horizontal, .padding16)
        .padding(.vertical, .padding12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: .cornerRadiusL)
                .fill(hSurfaceColor.Opaque.primary)
        }
    }

    @ViewBuilder
    private var actions: some View {
        switch question.content {
        case let .binary(currentValue):
            HStack(spacing: .padding8) {
                binaryButton(value: true, title: L10n.General.yes, currentValue: currentValue)
                binaryButton(value: false, title: L10n.General.no, currentValue: currentValue)
            }
        case .freeText:
            HStack(spacing: .padding8) {
                actionButton(
                    L10n.claimsWrite,
                    buttonImage: hButtonContent.hButtonImage(image: hCoreUIAssets.penEdit.view, alignment: .leading)
                ) {
                    startEditing()
                }
                actionButton(
                    L10n.claimsRecord,
                    buttonImage: hButtonContent.hButtonImage(image: hCoreUIAssets.mic.view, alignment: .leading)
                ) {
                    vm.startVoice(question)
                }
            }
        case let .number(currentValue, _, _), let .phoneNumber(currentValue):
            actionButton(currentValue == nil ? L10n.claimsWrite : L10n.General.edit) {
                startEditing()
            }
        case let .date(currentValue):
            actionButton(currentValue == nil ? L10n.claimFollowupDatePlaceholder : L10n.General.edit) {
                showDatePicker(currentValue: currentValue)
            }
        case let .fileUpload(currentFiles):
            fileActions(currentFiles: currentFiles)
        }
    }

    private func actionButton(
        _ title: String,
        buttonImage: hButtonContent.hButtonImage? = nil,
        action: @escaping @MainActor () async -> Void
    ) -> some View {
        hButton(.medium, .secondary, content: .init(title: title, buttonImage: buttonImage), action)
            .hButtonTakeFullWidth(true)
    }

    private func binaryButton(value: Bool, title: String, currentValue: Bool?) -> some View {
        let isSelected = question.state == .answered && currentValue == value
        return hButton(.medium, isSelected ? .primary : .secondary, content: .init(title: title)) {
            await vm.answer(question, .binary(value))
        }
        .hButtonTakeFullWidth(true)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var inputCard: some View {
        ClaimFollowupInputCard(
            text: $draft,
            error: fieldError,
            masking: inputMasking,
            isMultiline: isFreeText,
            isSaving: isSaving,
            onCancel: { vm.stopEditing() },
            onSave: { await saveDraft() }
        )
    }

    private var inputMasking: Masking {
        switch question.content {
        case .number: Masking(type: .digits)
        case .phoneNumber: Masking(type: .phoneNumber)
        case .binary, .freeText, .date, .fileUpload: Masking(type: .none)
        }
    }

    private var isFreeText: Bool {
        if case .freeText = question.content {
            return true
        }
        return false
    }

    private var voiceCard: some View {
        VoiceRecordingCardContent(
            voiceRecorder: vm.voiceRecorder,
            title: question.text,
            onSend: { try await vm.sendAudio(question) },
            onClose: { vm.closeVoice() }
        )
        .overlay {
            RoundedRectangle(cornerRadius: .cornerRadiusXXXL)
                .strokeBorder(hBorderColor.primary, lineWidth: 1)
        }
    }

    private func startEditing() {
        draft = Self.savedText(of: question)
        fieldError = nil
        vm.startEditing(question)
    }

    private func saveDraft() async {
        switch question.content {
        case let .freeText(_, maxLength, _, _):
            let isBlank = draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if isBlank {
                fieldError = L10n.claimFollowupTextEmpty
            } else if draft.count > maxLength {
                fieldError = L10n.claimFollowupTextTooLong(maxLength)
            } else {
                await save(.freeText(draft))
            }
        case .number:
            if draft.isEmpty {
                fieldError = L10n.claimFollowupTextEmpty
            } else {
                await save(.number(draft))
            }
        case .phoneNumber:
            let masking = Masking(type: .phoneNumber)
            let phoneNumber = masking.unmaskedValue(text: draft)
            if masking.isValid(text: phoneNumber) {
                await save(.phoneNumber(phoneNumber))
            } else {
                fieldError = L10n.claimFollowupPhoneInvalid
            }
        case .binary, .date, .fileUpload:
            break
        }
    }

    private func save(_ answer: ClaimFollowupAnswer) async {
        fieldError = nil
        if await vm.answer(question, answer) {
            vm.stopEditing()
        }
    }

    private func showDatePicker(currentValue: String?) {
        pickedDate = currentValue?.localDateToDate ?? Date()
        datePicker = .init(
            id: question.id,
            continueAction: {
                let date = pickedDate
                datePicker = nil
                Task { await vm.answer(question, .date(date.localDateString)) }
            },
            cancelAction: {
                datePicker = nil
            },
            date: $pickedDate,
            config: .init(
                placeholder: L10n.claimFollowupDatePlaceholder,
                title: question.text
            )
        )
    }

    private func fileActions(currentFiles: [ClaimFollowupFile]) -> some View {
        let currentFileIds = currentFiles.map(\.id)
        let pendingFiles = vm.pendingFilesByQuestionId[question.id] ?? []
        let hasPendingMismatch = pendingFiles.contains { $0.uploaded.relevance == .mismatch }
        return VStack(alignment: .leading, spacing: .padding16) {
            if !currentFiles.isEmpty || !pendingFiles.isEmpty {
                valueFieldContainer {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: .padding8) {
                            ForEach(currentFiles) { file in
                                thumbnail(file: file.asFile)
                            }
                            ForEach(pendingFiles) { pendingFile in
                                thumbnail(file: pendingFile.file)
                            }
                        }
                    }
                    if !currentFiles.isEmpty {
                        hText(L10n.claimFollowupFileAdded, style: .label)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
            }
            if hasPendingMismatch {
                InfoCard(text: L10n.claimFollowupFileMismatchHint, type: .attention)
                    .buttons([
                        .init(buttonTitle: L10n.claimFollowupFileUseAnyway) {
                            Task { await vm.useFilesAnyway(question, currentFileIds: currentFileIds) }
                        },
                        .init(buttonTitle: L10n.claimFollowupFileReplace) {
                            vm.pendingFilesByQuestionId[question.id] = nil
                            showFileSourcePicker = true
                        },
                    ])
            }
            actionButton(L10n.ClaimStatusDetail.addFiles) {
                showFileSourcePicker = true
            }
            .hButtonIsLoading(isSaving)
        }
        .showFileSourcePicker($showFileSourcePicker) { files in
            Task { await vm.upload(question, files: files, currentFileIds: currentFileIds) }
        }
    }

    private func thumbnail(file: File) -> some View {
        FileView(file: file) {}
            .frame(width: 100, height: 116)
            .background { hBackgroundColor.primary }
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
    }

    private var skipButton: some View {
        hButton(.medium, .ghost, content: .init(title: L10n.claimFollowupCantAnswerButton)) {
            vm.cantAnswerQuestion = question
        }
        .hButtonTakeFullWidth(true)
    }

    private static func isOutOfRange(_ value: String, min: Int?, max: Int?) -> Bool {
        guard let number = Int(value) else { return false }
        let isBelowMin = min.map { number < $0 } ?? false
        let isAboveMax = max.map { number > $0 } ?? false
        return isBelowMin || isAboveMax
    }

    private static func savedText(of question: ClaimFollowupQuestion) -> String {
        switch question.content {
        case let .freeText(_, _, currentValue, _), let .number(currentValue, _, _), let .phoneNumber(currentValue):
            return currentValue ?? ""
        case .binary, .date, .fileUpload:
            return ""
        }
    }
}

private struct ClaimFollowupInputCard: View {
    @Binding var text: String
    let error: String?
    let masking: Masking
    let isMultiline: Bool
    let isSaving: Bool
    let onCancel: () -> Void
    let onSave: @MainActor () async -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: .padding16) {
            VStack(alignment: .leading, spacing: .padding4) {
                hText(L10n.claimFollowupAnswerPlaceholder, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .accessibilityHidden(true)
                TextField(L10n.chatInputPlaceholder, text: $text, axis: isMultiline ? .vertical : .horizontal)
                    .font(Font(Fonts.fontFor(style: .body1)))
                    .foregroundColor(hTextColor.Opaque.primary)
                    .lineLimit(1...6)
                    .keyboardType(masking.keyboardType)
                    .textContentType(masking.textContentType)
                    .focused($isFocused)
                    .accessibilityLabel(L10n.claimFollowupAnswerPlaceholder)
                if let error {
                    hText(error, style: .label)
                        .foregroundColor(hSignalColor.Red.text)
                        .transition(.opacity)
                }
            }
            .animation(.defaultSpring, value: error)
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: .padding8) {
                Spacer()
                hButton(.medium, .secondary, content: .init(title: L10n.generalCancelButton)) {
                    onCancel()
                }
                .disabled(isSaving)
                hButton(.medium, .primary, content: .init(title: L10n.generalSaveButton)) {
                    await onSave()
                }
                .hButtonIsLoading(isSaving)
            }
        }
        .padding(.padding16)
        .claimInputCardBackground()
        .overlay {
            RoundedRectangle(cornerRadius: .cornerRadiusXXXL)
                .strokeBorder(hBorderColor.primary, lineWidth: 1)
        }
        .onAppear {
            Task {
                // Focus after the card has landed so the keyboard reliably opens with it.
                await delay(ClaimChatConstants.Timing.layoutUpdate)
                isFocused = true
            }
        }
        .onChange(of: text) { oldValue, newValue in
            let maskedValue = masking.maskValue(text: newValue, previousText: oldValue)
            if maskedValue != newValue {
                text = maskedValue
            }
        }
    }
}

extension ClaimFollowupFile {
    fileprivate var asFile: File {
        let mimeType = MimeType.findBy(mimeType: contentType)
        return File(id: id, size: 0, mimeType: mimeType, name: fileName, source: .url(url: url, mimeType: mimeType))
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in FetchClaimsClientDemo() })
    Dependencies.shared.add(module: Module { () -> hClaimFollowupClient in ClaimFollowupClientDemo() })
    let vm = ClaimFollowupViewModel(followup: .previewFollowup)
    return hForm {
        VStack(spacing: .padding16) {
            ForEach(vm.followup.questions) { question in
                ClaimFollowupQuestionCard(vm: vm, question: question)
            }
        }
    }
    .embededInNavigation(tracking: "ClaimFollowupQuestionCardPreview")
}
