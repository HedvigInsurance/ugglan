import AppStateContainer
import Claims
import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ClaimFollowupScreen: View {
    @State private var vm: ClaimFollowupViewModel
    @State private var didPositionStart = false
    /// Loading until the member actually lands on question 1, so it never flashes by on the way to a later one.
    @State private var rootState: ProcessingState = .loading
    @Environment(NavigationRouter.self) private var router

    public init(followup: ClaimFollowup) {
        _vm = State(wrappedValue: ClaimFollowupViewModel(followup: followup))
    }

    public var body: some View {
        Group {
            if let firstQuestion = vm.followup.questions.first {
                ClaimFollowupQuestionPage(vm: vm, questionId: firstQuestion.id, returnsToOverview: false)
            } else {
                ClaimFollowupOverview(vm: vm)
            }
        }
        .loading($rootState)
        .routerDestination(for: ClaimFollowupStep.self) { step in
            destination(for: step)
                .withDismissButton()
        }
        .addStepProgressBar(with: $vm.progress)
        .onAppear {
            if didPositionStart {
                rootState = .success
            }
        }
        .task {
            // .task re-runs whenever the root page re-appears after a pop.
            guard !didPositionStart else { return }
            await vm.reload()
            // Pushes made while the modal is still presenting are dropped by the NavigationStack.
            if vm.startStepCount > 0 {
                await delay(0.5)
            }
            withTransaction(\.disablesAnimations, true) {
                positionStart()
            }
            vm.isStartPositioned = true
            didPositionStart = true
            if vm.startStepCount == 0 {
                rootState = .success
            }
        }
    }

    @ViewBuilder
    private func destination(for step: ClaimFollowupStep) -> some View {
        switch step {
        case let .question(id, returnsToOverview):
            ClaimFollowupQuestionPage(vm: vm, questionId: id, returnsToOverview: returnsToOverview)
        case .overview:
            ClaimFollowupOverview(vm: vm)
        }
    }

    /// Lands on the first unanswered question with the earlier ones behind it, or on the overview.
    private func positionStart() {
        let questions = vm.followup.questions
        guard !questions.isEmpty else { return }
        let firstTodoIndex = questions.firstIndex { $0.state == .todo }
        for question in questions.prefix((firstTodoIndex ?? questions.count) + 1).dropFirst() {
            router.push(ClaimFollowupStep.question(id: question.id, returnsToOverview: false))
        }
        if firstTodoIndex == nil {
            router.push(ClaimFollowupStep.overview)
        }
    }
}

@MainActor
@Observable
final class ClaimFollowupViewModel {
    struct PendingFile: Identifiable {
        let file: File
        let uploaded: ClaimFollowupUploadedFile
        var id: String { uploaded.fileId }
    }

    var followup: ClaimFollowup {
        didSet {
            // Home says "continue" once something is answered, and it reads the store, not this view model.
            guard oldValue != followup else { return }
            Task {
                let store: ClaimsStore = globalAppStateContainer.get()
                await store.fetchFollowups()
            }
        }
    }
    var savingQuestionId: String?
    var isSending = false
    var pendingFilesByQuestionId: [String: [PendingFile]] = [:]
    var progress: StepProgressModel
    private(set) var voiceQuestionId: String?
    let voiceRecorder = VoiceRecorder()
    @ObservationIgnored @Inject private var client: hClaimFollowupClient

    init(followup: ClaimFollowup) {
        self.followup = followup
        let firstTodoIndex = followup.questions.firstIndex { $0.state == .todo }
        progress = .init(
            currentStep: (firstTodoIndex ?? followup.questions.count - 1) + 1,
            totalSteps: followup.questions.count
        )
    }

    /// The hidden root page appears before the start pushes, so it must not move the bar back to step 1.
    var isStartPositioned = false

    /// How many pages `positionStart` pushes: one per answered question before the first to-do, or all plus the overview.
    var startStepCount: Int {
        followup.questions.firstIndex { $0.state == .todo } ?? followup.questions.count
    }

    func step(after questionId: String) -> ClaimFollowupStep {
        let questions = followup.questions
        guard let index = questions.firstIndex(where: { $0.id == questionId }), index + 1 < questions.count else {
            return .overview
        }
        return .question(id: questions[index + 1].id, returnsToOverview: false)
    }

    func showStep(questionId: String) {
        guard isStartPositioned else { return }
        let index = followup.questions.firstIndex { $0.id == questionId } ?? 0
        withAnimation { progress = .init(currentStep: index + 1, totalSteps: followup.questions.count) }
    }

    /// The overview has no segment of its own, so it keeps the last one lit.
    func showOverviewStep() {
        guard isStartPositioned else { return }
        withAnimation {
            progress = .init(currentStep: followup.questions.count, totalSteps: followup.questions.count)
        }
    }

    func reload() async {
        guard let followups = try? await client.getFollowups(),
            let reloaded = followups.first(where: { $0.id == followup.id })
        else { return }
        followup = reloaded
    }

    @discardableResult
    func answer(_ question: ClaimFollowupQuestion, _ answer: ClaimFollowupAnswer) async -> Bool {
        savingQuestionId = question.id
        defer { savingQuestionId = nil }
        do {
            followup = try await client.answer(followupId: followup.id, questionId: question.id, answer: answer)
            return true
        } catch {
            showError(error)
            return false
        }
    }

    func cantAnswer(_ question: ClaimFollowupQuestion, comment: String?) async -> Bool {
        do {
            followup = try await client.cantAnswer(
                followupId: followup.id,
                questionId: question.id,
                comment: comment
            )
            pendingFilesByQuestionId[question.id] = nil
            if voiceQuestionId == question.id {
                closeVoice()
            }
            return true
        } catch {
            showError(error)
            return false
        }
    }

    /// A mismatching file is held back until the member confirms it, the question stays to-do meanwhile.
    func upload(_ question: ClaimFollowupQuestion, files: [File], currentFileIds: [String]) async {
        savingQuestionId = question.id
        defer { savingQuestionId = nil }
        do {
            let uploaded = try await client.upload(followupId: followup.id, questionId: question.id, files: files)
            let newPendingFiles = zip(files, uploaded).map { PendingFile(file: $0, uploaded: $1) }
            let pendingFiles = (pendingFilesByQuestionId[question.id] ?? []) + newPendingFiles
            let hasMismatch = pendingFiles.contains { $0.uploaded.relevance == .mismatch }
            if hasMismatch {
                pendingFilesByQuestionId[question.id] = pendingFiles
            } else {
                let fileIds = currentFileIds + pendingFiles.map(\.id)
                followup = try await client.answer(
                    followupId: followup.id,
                    questionId: question.id,
                    answer: .files(fileIds: fileIds)
                )
                pendingFilesByQuestionId[question.id] = nil
            }
        } catch {
            showError(error)
        }
    }

    func useFilesAnyway(_ question: ClaimFollowupQuestion, currentFileIds: [String]) async {
        let pendingFileIds = (pendingFilesByQuestionId[question.id] ?? []).map(\.id)
        let saved = await answer(question, .files(fileIds: currentFileIds + pendingFileIds))
        if saved {
            pendingFilesByQuestionId[question.id] = nil
        }
    }

    func send() async -> Bool {
        isSending = true
        defer { isSending = false }
        do {
            followup = try await client.send(followupId: followup.id)
        } catch {
            showError(error)
            return false
        }
        let store: ClaimsStore = globalAppStateContainer.get()
        await store.fetchFollowups()
        Toasts.shared.displayToastBar(
            toast: .init(
                type: .campaign,
                icon: hCoreUIAssets.checkmark.view,
                text: L10n.claimFollowupSuccessTitle
            )
        )
        return true
    }

    func startVoice(_ question: ClaimFollowupQuestion) {
        voiceRecorder.startOver()
        voiceQuestionId = question.id
    }

    func closeVoice() {
        voiceRecorder.isCountingDown = false
        voiceRecorder.stopRecording()
        voiceRecorder.stopPlayback()
        voiceQuestionId = nil
    }

    /// Throws so the voice card shows its own sending-failed state.
    func sendAudio(_ question: ClaimFollowupQuestion) async throws {
        guard let audioFileURL = voiceRecorder.recordedFileURL else { return }
        let audioFileId = try await client.uploadAudio(
            followupId: followup.id,
            questionId: question.id,
            audioFileURL: audioFileURL
        )
        followup = try await client.answer(
            followupId: followup.id,
            questionId: question.id,
            answer: .audio(fileId: audioFileId)
        )
        closeVoice()
        voiceRecorder.isSending = false
    }

    private func showError(_ error: Error) {
        Toasts.shared.displayToastBar(toast: .init(type: .error, text: error.localizedDescription))
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> hFetchClaimsClient in FetchClaimsClientDemo() })
    Dependencies.shared.add(module: Module { () -> hClaimFollowupClient in ClaimFollowupClientDemo() })
    return ClaimFollowupScreen(followup: .previewFollowup)
        .embededInNavigation(tracking: "ClaimFollowupScreenPreview")
}

extension ClaimFollowup {
    static let previewFollowup = ClaimFollowup(
        id: "followup",
        claimId: "claim",
        status: .submitted,
        questions: [
            .init(
                id: "binary",
                text: "Was anyone else involved?",
                state: .answered,
                cantAnswerComment: nil,
                content: .binary(currentValue: true)
            ),
            .init(
                id: "text",
                text: "Describe what happened",
                state: .todo,
                cantAnswerComment: nil,
                content: .freeText(minLength: 1, maxLength: 200, currentValue: nil, currentAudio: nil)
            ),
            .init(
                id: "number",
                text: "How many items were damaged?",
                state: .todo,
                cantAnswerComment: nil,
                content: .number(currentValue: nil, min: 1, max: 5)
            ),
            .init(
                id: "phone",
                text: "Which number can we reach you on?",
                state: .cantAnswer,
                cantAnswerComment: "I do not have it",
                content: .phoneNumber(currentValue: nil)
            ),
            .init(
                id: "date",
                text: "When did it happen?",
                state: .todo,
                cantAnswerComment: nil,
                content: .date(currentValue: nil)
            ),
            .init(
                id: "files",
                text: "Upload the receipt",
                state: .todo,
                cantAnswerComment: nil,
                content: .fileUpload(currentFiles: [])
            ),
        ]
    )
}
