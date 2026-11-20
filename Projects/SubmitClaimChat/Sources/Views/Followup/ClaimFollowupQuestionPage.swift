import Claims
import SwiftUI
import hCore
import hCoreUI

enum ClaimFollowupStep: Hashable, TrackingViewNameProtocol {
    /// `returnsToOverview` is set when the member opened the question from the overview, so continuing goes back there.
    case question(id: String, returnsToOverview: Bool)
    case overview

    var nameForTracking: String {
        switch self {
        case .question: "ClaimFollowupQuestion"
        case .overview: "ClaimFollowupOverview"
        }
    }
}

struct ClaimFollowupQuestionPage: View {
    let vm: ClaimFollowupViewModel
    let questionId: String
    let returnsToOverview: Bool
    @Environment(NavigationRouter.self) private var router
    @State private var draft = ""
    @State private var binaryDraft: Bool?
    @State private var dateDraft: Date?
    @State private var isWriting = false
    @State private var fieldError: String?
    @State private var showFileSourcePicker = false
    @State private var skipQuestion: ClaimFollowupQuestion?
    @State private var didLoadDraft = false
    /// Saved files the member removed; the removal is sent with the next save, since an empty list is refused.
    @State private var removedFileIds: Set<String> = []

    var body: some View {
        if let question = vm.followup.questions.first(where: { $0.id == questionId }) {
            page(question)
        }
    }

    private func page(_ question: ClaimFollowupQuestion) -> some View {
        hForm {
            EmptyView()
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    // The question sits right above its answer; the recorder card shows it itself.
                    if !isRecording(question) {
                        VStack(alignment: .leading, spacing: .padding2) {
                            hText(question.text)
                                .accessibilityAddTraits(.isHeader)
                            if let hint = question.hint, !hint.isEmpty {
                                hText(hint, style: .label)
                                    .foregroundColor(hTextColor.Translucent.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, .padding8)
                    }
                    middleContent(question)
                    if !isRecording(question) {
                        bottomInput(question)
                        primaryButton(question)
                        hButton(.large, .ghost, content: .init(title: L10n.claimFollowupCantAnswerButton)) {
                            UIApplication.dismissKeyboard()
                            skipQuestion = question
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .animation(.defaultSpring, value: isWriting)
        .animation(.defaultSpring, value: vm.voiceQuestionId)
        .detent(item: $skipQuestion, presentationStyle: .detent(style: [.height])) { skippedQuestion in
            ClaimFollowupCantAnswerSheet(
                vm: vm,
                question: skippedQuestion,
                onSkipped: {
                    skipQuestion = nil
                    advance()
                },
                onCancel: { skipQuestion = nil }
            )
        }
        .onAppear {
            vm.showStep(questionId: questionId)
            if !didLoadDraft {
                didLoadDraft = true
                loadDraft(from: question)
            }
        }
        // The root page appears before the reload, and a skip clears the saved answer.
        .onChange(of: question.content) {
            loadDraft(from: question)
        }
        .onDisappear {
            if isRecording(question) {
                vm.closeVoice()
            }
        }
    }

    /// Yes/no saves on tap, and a file question without files has nothing to save yet, so its primary action adds files.
    @ViewBuilder
    private func primaryButton(_ question: ClaimFollowupQuestion) -> some View {
        let isSaving = vm.savingQuestionId == question.id
        let hasPendingFiles = !(vm.pendingFilesByQuestionId[question.id] ?? []).isEmpty
        if case .binary = question.content {
            EmptyView()
        } else if case .fileUpload = question.content, keptFileIds(question).isEmpty, !hasPendingFiles {
            hButton(.large, .primary, content: .init(title: L10n.ClaimStatusDetail.addFiles)) {
                showFileSourcePicker = true
            }
            .hButtonIsLoading(isSaving)
            .showFileSourcePicker($showFileSourcePicker) { files in upload(question, files: files) }
        } else {
            hSaveButton(.primary) {
                await continueTapped(question)
            }
            .disabled(!canContinue(question))
            .hButtonIsLoading(isSaving)
        }
    }

    // MARK: - Content per answer kind

    @ViewBuilder
    private func middleContent(_ question: ClaimFollowupQuestion) -> some View {
        switch question.content {
        case .binary:
            HStack(spacing: .padding8) {
                binaryPill(question, value: true, title: L10n.General.yes)
                binaryPill(question, value: false, title: L10n.General.no)
            }
            .disabled(vm.savingQuestionId == question.id)
        case let .freeText(_, _, _, currentAudio):
            if isRecording(question) {
                VoiceRecordingCardContent(
                    voiceRecorder: vm.voiceRecorder,
                    title: question.text,
                    onSend: {
                        try await vm.sendAudio(question)
                        advance()
                    },
                    onClose: { vm.closeVoice() }
                )
                .overlay {
                    RoundedRectangle(cornerRadius: .cornerRadiusXXXL)
                        .strokeBorder(hBorderColor.primary, lineWidth: 1)
                }
            } else {
                VStack(spacing: .padding8) {
                    if currentAudio != nil {
                        hText(L10n.claimFollowupAudioAdded, style: .label)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                    HStack(spacing: .padding8) {
                        if !isWriting {
                            writeButton
                        }
                        recordButton(question)
                    }
                }
            }
        case let .fileUpload(currentFiles):
            fileContent(question, currentFiles: currentFiles)
        case .date, .number, .phoneNumber:
            EmptyView()
        }
    }

    /// Fields sit right above the buttons, next to the keyboard, as in the onboarding phone screen.
    @ViewBuilder
    private func bottomInput(_ question: ClaimFollowupQuestion) -> some View {
        switch question.content {
        case .freeText:
            if isWriting {
                hFloatingTextField(
                    masking: .init(type: .none),
                    value: $draft,
                    placeholder: L10n.claimFollowupAnswerPlaceholder,
                    error: $fieldError
                )
                .hFieldMultiline(true)
            }
        case let .number(_, min, max):
            VStack(spacing: .padding8) {
                if Self.isOutOfRange(draft, min: min, max: max) {
                    InfoCard(text: L10n.claimFollowupNumberOutOfRange, type: .attention)
                }
                hFloatingTextField(
                    masking: .init(type: .digits),
                    value: $draft,
                    placeholder: L10n.claimFollowupAnswerPlaceholder,
                    error: $fieldError
                )
            }
            .animation(.defaultSpring, value: Self.isOutOfRange(draft, min: min, max: max))
        case .phoneNumber:
            hFloatingTextField(
                masking: .init(type: .phoneNumber),
                value: $draft,
                placeholder: L10n.phoneNumberRowTitle,
                error: $fieldError
            )
        case let .date(_, min, max):
            let isOutOfRange = Self.isOutOfRange(dateDraft, min: min, max: max)
            VStack(spacing: .padding8) {
                if isOutOfRange {
                    InfoCard(text: L10n.claimFollowupNumberOutOfRange, type: .attention)
                }
                hDatePickerField(
                    config: .init(placeholder: L10n.claimFollowupDatePlaceholder, title: question.text),
                    selectedDate: dateDraft,
                    onContinue: { date in
                        dateDraft = date
                    }
                )
            }
            .animation(.defaultSpring, value: isOutOfRange)
        case .binary, .fileUpload:
            EmptyView()
        }
    }

    /// Same pills as the claim flow's yes/no step (`SubmitClaimSingleSelectView.binaryInputView`).
    private func binaryPill(_ question: ClaimFollowupQuestion, value: Bool, title: String) -> some View {
        let pillColor: PillColor = binaryDraft == value ? .green : .grey
        return hButton(.medium, .ghost, content: .init(title: title)) {
            ImpactGenerator.soft()
            binaryDraft = value
            await continueTapped(question)
        }
        .hCustomButtonView {
            hText(title, style: .body1)
                .foregroundColor(pillColor.pillTextColor(level: .two))
        }
        .hWrapInPill(color: pillColor, colorLevel: .two)
        .hButtonTakeFullWidth(true)
        .accessibilityAddTraits(binaryDraft == value ? .isSelected : [])
    }

    private var writeButton: some View {
        hButton(
            .large,
            .secondary,
            content: .init(
                title: L10n.claimsWrite,
                buttonImage: .init(image: hCoreUIAssets.penEdit.view, alignment: .leading, size: .large)
            )
        ) {
            isWriting = true
        }
    }

    private func recordButton(_ question: ClaimFollowupQuestion) -> some View {
        hButton(
            .large,
            .secondary,
            content: .init(
                title: L10n.claimsRecord,
                buttonImage: .init(image: hCoreUIAssets.mic.view, alignment: .leading, size: .large)
            )
        ) {
            UIApplication.dismissKeyboard()
            vm.startVoice(question)
        }
    }

    private func fileContent(_ question: ClaimFollowupQuestion, currentFiles: [ClaimFollowupFile]) -> some View {
        let pendingFiles = vm.pendingFilesByQuestionId[question.id] ?? []
        let hasPendingMismatch = pendingFiles.contains { $0.uploaded.relevance == .mismatch }
        return VStack(spacing: .padding16) {
            if !keptFileIds(question).isEmpty || !pendingFiles.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .padding8) {
                        ForEach(currentFiles.filter { !removedFileIds.contains($0.id) }) { file in
                            thumbnail(file: file.asFile) {
                                removedFileIds.insert(file.id)
                            }
                        }
                        ForEach(pendingFiles) { pendingFile in
                            thumbnail(file: pendingFile.file) {
                                vm.pendingFilesByQuestionId[question.id]?.removeAll { $0.id == pendingFile.id }
                            }
                        }
                        // A mismatch offers "Välj en annan fil" instead, so there is one way to add.
                        if !hasPendingMismatch {
                            addFileTile
                                .showFileSourcePicker($showFileSourcePicker) { files in upload(question, files: files) }
                        }
                    }
                    // Room for the remove badges, which sit half outside the thumbnails.
                    .padding(.top, .padding8)
                    .padding(.trailing, .padding8)
                }
            }
            if hasPendingMismatch {
                InfoCard(
                    title: L10n.claimFollowupFileMismatchTitle,
                    text: L10n.claimFollowupFileMismatchHint,
                    type: .attention
                )
                .buttons([
                    .init(buttonTitle: L10n.claimFollowupFileUseAnyway) {
                        Task { await vm.useFilesAnyway(question, currentFileIds: keptFileIds(question)) }
                    },
                    .init(buttonTitle: L10n.claimFollowupFileReplace) {
                        vm.pendingFilesByQuestionId[question.id] = nil
                        showFileSourcePicker = true
                    },
                ])
                .showFileSourcePicker($showFileSourcePicker) { files in upload(question, files: files) }
            }
        }
    }

    /// The picker is attached to whichever control opened it, so its popover points at that control.
    private func upload(_ question: ClaimFollowupQuestion, files: [File]) {
        Task { await vm.upload(question, files: files, currentFileIds: keptFileIds(question)) }
    }

    private var addFileTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .cornerRadiusL)
                .fill(hSurfaceColor.Opaque.primary)
            RoundedRectangle(cornerRadius: .cornerRadiusL)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                .foregroundColor(hBorderColor.secondary)
            Circle()
                .fill(hFillColor.Opaque.primary)
                .frame(width: 48, height: 48)
                .overlay {
                    hCoreUIAssets.plus.view
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hTextColor.Opaque.negative)
                }
        }
        .frame(width: 100, height: 116)
        .contentShape(Rectangle())
        .onTapGesture {
            ImpactGenerator.soft()
            showFileSourcePicker = true
        }
        .accessibilityElement()
        .accessibilityLabel(L10n.ClaimStatusDetail.addFiles)
        .accessibilityAddTraits(.isButton)
    }

    private func keptFileIds(_ question: ClaimFollowupQuestion) -> [String] {
        question.currentFileIds.filter { !removedFileIds.contains($0) }
    }

    /// The remove badge copies the claim flow's (`FilesGridView`).
    private func thumbnail(file: File, onRemove: @escaping () -> Void) -> some View {
        FileView(file: file) {}
            .frame(width: 100, height: 116)
            .background { hSurfaceColor.Opaque.primary }
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(hBackgroundColor.primary)
                    .frame(width: 24, height: 24)
                    .hShadow()
                    .overlay {
                        hCoreUIAssets.closeSmall.view
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                    .frame(width: 30, height: 30)
                    .contentShape(Circle())
                    .offset(x: 8, y: -8)
                    .onTapGesture {
                        withAnimation(.defaultSpring) { onRemove() }
                    }
                    .accessibilityElement()
                    .accessibilityLabel(L10n.General.remove + " " + file.name)
                    .accessibilityAddTraits(.isButton)
            }
    }

    // MARK: - Continue

    private func isRecording(_ question: ClaimFollowupQuestion) -> Bool {
        vm.voiceQuestionId == question.id
    }

    private func hasInput(_ question: ClaimFollowupQuestion) -> Bool {
        switch question.content {
        case .freeText:
            isWriting && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .number, .phoneNumber:
            !draft.isEmpty
        case .binary:
            binaryDraft != nil
        case .date:
            dateDraft != nil
        case .fileUpload:
            !keptFileIds(question).isEmpty
        }
    }

    /// A question already answered or skipped can be passed without new input.
    private func canContinue(_ question: ClaimFollowupQuestion) -> Bool {
        let hasPendingFiles = !(vm.pendingFilesByQuestionId[question.id] ?? []).isEmpty
        return !hasPendingFiles && (hasInput(question) || question.state != .todo)
    }

    private func continueTapped(_ question: ClaimFollowupQuestion) async {
        guard hasInput(question), !isUnchanged(question) else {
            advance()
            return
        }
        fieldError = nil
        switch question.content {
        case let .freeText(_, maxLength, _, _):
            if draft.count > maxLength {
                fieldError = L10n.claimFollowupTextTooLong(maxLength)
            } else {
                await save(question, .freeText(draft))
            }
        case .number:
            await save(question, .number(draft))
        case .phoneNumber:
            let masking = Masking(type: .phoneNumber)
            let phoneNumber = masking.unmaskedValue(text: draft)
            if masking.isValid(text: phoneNumber) {
                await save(question, .phoneNumber(phoneNumber))
            } else {
                fieldError = L10n.claimFollowupPhoneInvalid
            }
        case .binary:
            if let binaryDraft {
                await save(question, .binary(binaryDraft))
            }
        case .date:
            if let dateDraft {
                await save(question, .date(dateDraft.localDateString))
            }
        case .fileUpload:
            await save(question, .files(fileIds: keptFileIds(question)))
        }
    }

    private func isUnchanged(_ question: ClaimFollowupQuestion) -> Bool {
        guard question.state == .answered else { return false }
        switch question.content {
        case let .freeText(_, _, currentValue, _):
            return draft == currentValue
        case let .number(currentValue, _, _):
            return draft == currentValue
        case let .phoneNumber(currentValue):
            return Masking(type: .phoneNumber).unmaskedValue(text: draft) == currentValue
        case let .binary(currentValue):
            return binaryDraft == currentValue
        case let .date(currentValue, _, _):
            return dateDraft?.localDateString == currentValue
        case .fileUpload:
            return removedFileIds.isEmpty
        }
    }

    private func save(_ question: ClaimFollowupQuestion, _ answer: ClaimFollowupAnswer) async {
        if await vm.answer(question, answer) {
            advance()
        }
    }

    private func advance() {
        UIApplication.dismissKeyboard()
        if returnsToOverview {
            router.pop()
        } else {
            router.push(vm.step(after: questionId))
        }
    }

    private func loadDraft(from question: ClaimFollowupQuestion) {
        fieldError = nil
        switch question.content {
        case let .freeText(_, _, currentValue, _):
            draft = currentValue ?? ""
            isWriting = currentValue != nil
        case let .number(currentValue, _, _), let .phoneNumber(currentValue):
            draft = currentValue ?? ""
        case let .binary(currentValue):
            binaryDraft = currentValue
        case let .date(currentValue, _, _):
            dateDraft = currentValue?.localDateToDate
        case .fileUpload:
            removedFileIds = []
        }
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

/// Laid out like the claim flow summary (`SubmitClaimSummaryView`): a card with short answers and "Show all answers".
struct ClaimFollowupOverview: View {
    let vm: ClaimFollowupViewModel
    @Environment(NavigationRouter.self) private var router
    @State private var showAllAnswers = false

    var body: some View {
        hForm {
            hSection {
                hRow {
                    VStack(alignment: .leading, spacing: .padding16) {
                        VStack(alignment: .leading, spacing: .padding8) {
                            hText(L10n.claimFollowupOverviewTitle)
                                .accessibilityAddTraits(.isHeader)
                            VStack(spacing: .padding4) {
                                ForEach(vm.followup.questions) { question in
                                    row(question)
                                }
                            }
                        }
                        hButton(.medium, .ghost, content: .init(title: L10n.ClaimStatus.showAllAnswers)) {
                            showAllAnswers = true
                        }
                        .hButtonTakeFullWidth(true)
                        .hButtonWithBorder
                    }
                }
            }
            .sectionContainerStyle(.negative)
            .hCardShadow()
            .hWithoutHorizontalPadding([.section])
            .overlay {
                RoundedRectangle(cornerRadius: .cornerRadiusXL)
                    .inset(by: 0.5)
                    .stroke(hBorderColor.primary, lineWidth: 1)
            }
            .padding(.horizontal, .padding16)
            .padding(.top, .padding8)
        }
        .hFormAttachToBottom {
            hSection {
                hButton(.large, .primary, content: .init(title: L10n.claimFollowupSendButton)) {
                    if await vm.send() {
                        router.dismiss()
                    }
                }
                .disabled(!vm.followup.canSend)
                .hButtonIsLoading(vm.isSending)
            }
            .sectionContainerStyle(.transparent)
        }
        .detent(presented: $showAllAnswers, presentationStyle: .detent(style: [.height])) {
            ClaimFollowupAnswersView(questions: vm.followup.questions)
                .navigationTitle(L10n.claimFollowupTitle)
                .embededInNavigation(tracking: String(describing: ClaimFollowupAnswersView.self))
        }
        .onAppear {
            vm.showOverviewStep()
        }
    }

    /// Tapping a row opens that question, and saving it comes back here.
    private func row(_ question: ClaimFollowupQuestion) -> some View {
        HStack(alignment: .top) {
            hText(question.text)
                .multilineTextAlignment(.leading)
                .foregroundColor(hTextColor.Opaque.secondary)
            Spacer(minLength: .padding8)
            answerText(question)
                .lineLimit(1)
                .multilineTextAlignment(.trailing)
                .layoutPriority(-1)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            router.push(ClaimFollowupStep.question(id: question.id, returnsToOverview: true))
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private func answerText(_ question: ClaimFollowupQuestion) -> some View {
        switch question.state {
        case .todo:
            hText(L10n.claimFollowupStateTodo)
                .foregroundColor(hSignalColor.Amber.text)
        case .cantAnswer:
            hText(L10n.claimFollowupCantAnswerState)
                .foregroundColor(hTextColor.Translucent.tertiary)
        case .answered:
            hText(question.content.shortAnswer)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
    }
}

/// The detailed list behind "Show all answers", like `SubmitClaimSummaryAnswersView`.
private struct ClaimFollowupAnswersView: View {
    @Environment(\.dismiss) private var dismiss
    let questions: [ClaimFollowupQuestion]

    var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding16) {
                    ForEach(questions) { question in
                        VStack(alignment: .leading, spacing: 0) {
                            hText(question.text, style: .label)
                                .foregroundColor(hTextColor.Opaque.secondary)
                                .accessibilityAddTraits(.isHeader)
                            answer(question)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.bottom, .padding32)
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            hSection {
                hButton(.large, .secondary, content: .init(title: L10n.generalCloseButton)) {
                    dismiss()
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder
    private func answer(_ question: ClaimFollowupQuestion) -> some View {
        switch (question.state, question.content) {
        case (.todo, _):
            hText(L10n.claimFollowupStateTodo)
                .foregroundColor(hSignalColor.Amber.text)
        case (.cantAnswer, _):
            VStack(alignment: .leading, spacing: 0) {
                hText(L10n.claimFollowupCantAnswerState)
                if let comment = question.cantAnswerComment, !comment.isEmpty {
                    hText(comment)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
        case let (.answered, .fileUpload(currentFiles)):
            ClaimFollowupAnswerFilesView(files: currentFiles.map(\.asFile))
                .padding(.top, .padding8)
        case (.answered, _):
            hText(question.content.shortAnswer)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct ClaimFollowupAnswerFilesView: View {
    @State private var vm: FileGridViewModel

    init(files: [File]) {
        _vm = State(wrappedValue: FileGridViewModel(files: files, options: []))
    }

    var body: some View {
        FilesGridView(vm: vm)
            .hFileGridAlignment(alignment: .leading)
    }
}

@MainActor
extension ClaimFollowupQuestion.Content {
    fileprivate var shortAnswer: String {
        switch self {
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
            return L10n.claimFollowupFileAdded
        }
    }
}

extension ClaimFollowupQuestion {
    fileprivate var currentFileIds: [String] {
        guard case let .fileUpload(currentFiles) = content else { return [] }
        return currentFiles.map(\.id)
    }
}

extension ClaimFollowupFile {
    fileprivate var asFile: File {
        let mimeType = MimeType.findBy(mimeType: contentType)
        return File(id: id, size: 0, mimeType: mimeType, name: fileName, source: .url(url: url, mimeType: mimeType))
    }
}
