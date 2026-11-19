import AppStateContainer
import Claims
import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ClaimFollowupScreen: View {
    @State private var vm: ClaimFollowupViewModel
    @Environment(NavigationRouter.self) private var router

    public init(followup: ClaimFollowup) {
        _vm = State(wrappedValue: ClaimFollowupViewModel(followup: followup))
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerSection
            hForm {
                VStack(spacing: .padding16) {
                    ForEach(vm.followup.questions) { question in
                        ClaimFollowupQuestionCard(vm: vm, question: question)
                    }
                }
                .padding(.vertical, .padding16)
            }
            .hFormAlwaysAttachToBottom {
                if vm.editingQuestionId == nil && vm.voiceQuestionId == nil {
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
            }
        }
        .background {
            hBackgroundColor.primary
                .ignoresSafeArea()
        }
        .navigationTitle(L10n.claimFollowupTitle)
        .detent(item: $vm.cantAnswerQuestion, presentationStyle: .detent(style: [.height])) { question in
            ClaimFollowupCantAnswerSheet(vm: vm, question: question)
        }
        .task {
            await vm.reload()
        }
    }

    private var headerSection: some View {
        hSection {
            VStack(alignment: .leading, spacing: .padding8) {
                HStack(alignment: .firstTextBaseline, spacing: .padding8) {
                    hText(L10n.homeTodoSectionTitle)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    hText(L10n.claimFollowupQuestionsLeft(vm.followup.questionsLeft), style: .label)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                progressBar
                hText(L10n.claimFollowupIntro, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .sectionContainerStyle(.transparent)
        .padding(.top, .padding8)
        .padding(.bottom, .padding8)
        // hForm does not clip its scroll content, so the header needs its own surface above the list.
        .background { hBackgroundColor.primary.ignoresSafeArea(edges: .top) }
        .zIndex(1)
    }

    private var progressBar: some View {
        let questionsCount = vm.followup.questions.count
        let questionsDone = questionsCount - vm.followup.questionsLeft
        let progress = questionsCount == 0 ? 0 : CGFloat(questionsDone) / CGFloat(questionsCount)
        return Capsule()
            .fill(hSurfaceColor.Opaque.secondary)
            .frame(height: .padding4)
            .overlay(alignment: .leading) {
                GeometryReader { geometry in
                    Capsule()
                        .fill(hFillColor.Opaque.primary)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .animation(.defaultSpring, value: progress)
            .accessibilityHidden(true)
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

    var followup: ClaimFollowup
    var cantAnswerQuestion: ClaimFollowupQuestion?
    var savingQuestionId: String?
    var isSending = false
    var pendingFilesByQuestionId: [String: [PendingFile]] = [:]
    private(set) var voiceQuestionId: String?
    private(set) var editingQuestionId: String?
    let voiceRecorder = VoiceRecorder()
    @ObservationIgnored @Inject private var client: hClaimFollowupClient

    init(followup: ClaimFollowup) {
        self.followup = followup
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

    func cantAnswer(_ question: ClaimFollowupQuestion, comment: String?) async {
        do {
            followup = try await client.cantAnswer(
                followupId: followup.id,
                questionId: question.id,
                comment: comment
            )
            pendingFilesByQuestionId[question.id] = nil
            if editingQuestionId == question.id {
                editingQuestionId = nil
            }
            if voiceQuestionId == question.id {
                closeVoice()
            }
            cantAnswerQuestion = nil
        } catch {
            showError(error)
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
        editingQuestionId = nil
        voiceRecorder.startOver()
        voiceQuestionId = question.id
    }

    func startEditing(_ question: ClaimFollowupQuestion) {
        if voiceQuestionId != nil {
            closeVoice()
        }
        editingQuestionId = question.id
    }

    func stopEditing() {
        editingQuestionId = nil
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
