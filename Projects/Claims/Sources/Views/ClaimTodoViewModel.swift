import AppStateContainer
import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
@Observable
final class ClaimTodoViewModel {
    struct PendingUpload {
        let files: [File]
        let fileIds: [String]
    }

    /// The question whose answer sheet is open; the sheet reads the live question by this id.
    var answeringQuestion: ClaimFollowupQuestion?
    private(set) var checkingFilesByQuestionId: [String: [File]] = [:]
    private(set) var pendingUploadByQuestionId: [String: PendingUpload] = [:]
    private(set) var savingQuestionIds: Set<String> = []
    private(set) var isSending = false
    /// A follow-up fetch that started before a mutation would overwrite the newer answer with stale data.
    @ObservationIgnored private var mutationCount = 0
    @ObservationIgnored @AppState private var store: ClaimsStore
    @ObservationIgnored @Inject private var client: hClaimFollowupClient

    func followup(for claim: ClaimModel) -> ClaimFollowup? {
        store.todoFollowup(for: claim)
    }

    /// Claim detail does not fetch follow-ups otherwise, and the upload needs the URIs this fetch caches.
    func start(claim: ClaimModel) async {
        guard claim.status != .closed, !claim.isPartnerClaim else { return }
        let mutationCountAtStart = mutationCount
        guard let fetched = try? await client.getFollowups(), mutationCount == mutationCountAtStart else { return }
        store.followups = fetched
        if let followup = store.todoFollowup(for: claim) {
            await sendIfComplete(followup)
        }
    }

    /// The answer sheet is presented outside the view tree, so it looks the follow-up up here to stay live.
    func followup(id: String) -> ClaimFollowup? {
        store.followups.first { $0.id == id }
    }

    func open(_ question: ClaimFollowupQuestion) {
        answeringQuestion = question
    }

    func answer(_ answer: ClaimFollowupAnswer, for question: ClaimFollowupQuestion, in followup: ClaimFollowup) async {
        mutationCount += 1
        savingQuestionIds.insert(question.id)
        do {
            let updated = try await client.answer(followupId: followup.id, questionId: question.id, answer: answer)
            apply(updated)
            savingQuestionIds.remove(question.id)
            closeSheet(for: question.id)
            announce(L10n.generalDoneButton)
            await sendIfComplete(updated)
        } catch {
            savingQuestionIds.remove(question.id)
            showError(error)
        }
    }

    /// A mismatching file is held back until the member confirms it, the question stays to-do meanwhile.
    func upload(_ files: [File], for question: ClaimFollowupQuestion, in followup: ClaimFollowup) async {
        guard !files.isEmpty else { return }
        let questionId = question.id
        mutationCount += 1
        let previousPendingUpload = pendingUploadByQuestionId[questionId]
        pendingUploadByQuestionId[questionId] = nil
        checkingFilesByQuestionId[questionId] = files
        announce(L10n.claimTodoCheckingFile)
        do {
            let uploaded = try await client.upload(followupId: followup.id, questionId: questionId, files: files)
            let fileIds =
                uploaded
                .map(\.fileId)
            if uploaded.contains(where: { $0.relevance == .mismatch }) {
                pendingUploadByQuestionId[questionId] = .init(files: files, fileIds: fileIds)
                checkingFilesByQuestionId[questionId] = nil
                announce(L10n.claimTodoNudge)
                return
            }
            let updated = try await client.answer(
                followupId: followup.id,
                questionId: questionId,
                answer: .files(fileIds: question.currentFileIds + fileIds)
            )
            apply(updated)
            checkingFilesByQuestionId[questionId] = nil
            closeSheet(for: questionId)
            announce(L10n.claimFollowupFileAdded)
            await sendIfComplete(updated)
        } catch {
            pendingUploadByQuestionId[questionId] = previousPendingUpload
            checkingFilesByQuestionId[questionId] = nil
            showError(error)
        }
    }

    func sendAnyway(_ question: ClaimFollowupQuestion, in followup: ClaimFollowup) async {
        guard let pendingUpload = pendingUploadByQuestionId[question.id] else { return }
        mutationCount += 1
        savingQuestionIds.insert(question.id)
        do {
            let updated = try await client.answer(
                followupId: followup.id,
                questionId: question.id,
                answer: .files(fileIds: question.currentFileIds + pendingUpload.fileIds)
            )
            pendingUploadByQuestionId[question.id] = nil
            apply(updated)
            savingQuestionIds.remove(question.id)
            closeSheet(for: question.id)
            announce(L10n.claimFollowupFileAdded)
            await sendIfComplete(updated)
        } catch {
            savingQuestionIds.remove(question.id)
            showError(error)
        }
    }

    func cantAnswer(_ question: ClaimFollowupQuestion, in followup: ClaimFollowup) async {
        mutationCount += 1
        savingQuestionIds.insert(question.id)
        do {
            let updated = try await client.cantAnswer(followupId: followup.id, questionId: question.id, comment: nil)
            apply(updated)
            savingQuestionIds.remove(question.id)
            closeSheet(for: question.id)
            announce(question.isFileQuestion ? L10n.claimTodoDontHaveDone : L10n.claimFollowupCantAnswerState)
            await sendIfComplete(updated)
        } catch {
            savingQuestionIds.remove(question.id)
            showError(error)
        }
    }

    /// The follow-up goes to the handler as soon as nothing is left to do; the info card retries a failed send.
    func sendIfComplete(_ followup: ClaimFollowup) async {
        guard followup.canSend, !isSending else { return }
        mutationCount += 1
        isSending = true
        defer { isSending = false }
        do {
            let completed = try await client.send(followupId: followup.id)
            apply(completed)
            announce(L10n.claimTodoInfoDone)
        } catch {
            if !Task.isCancelled { showError(error) }
        }
    }

    /// The claim card pill, the Home to-do and this section all read the store.
    private func apply(_ updated: ClaimFollowup) {
        store.followups = store.followups
            .map { $0.id == updated.id ? updated : $0 }
    }

    /// A slow call can finish after the member has moved on to another question's sheet.
    private func closeSheet(for questionId: String) {
        if answeringQuestion?.id == questionId {
            answeringQuestion = nil
        }
    }

    private func showError(_ error: Error) {
        Toasts.shared.displayToastBar(toast: .init(type: .error, text: error.localizedDescription))
        announce(error.localizedDescription)
    }

    /// Queued, so an announcement does not cut off the one before it.
    private func announce(_ message: String) {
        UIAccessibility.post(
            notification: .announcement,
            argument: NSAttributedString(string: message, attributes: [.accessibilitySpeechQueueAnnouncement: true])
        )
    }
}

extension ClaimsStore {
    /// The newest open follow-up, else the newest completed one: the backend lists them oldest first.
    func todoFollowup(for claim: ClaimModel) -> ClaimFollowup? {
        guard claim.status != .closed, !claim.isPartnerClaim else { return nil }
        let claimFollowups =
            followups
            .filter { $0.claimId == claim.id }
        return claimFollowups.last(where: \.isOpen) ?? claimFollowups.last
    }
}

extension ClaimFollowupQuestion {
    var isFileQuestion: Bool {
        if case .fileUpload = content {
            return true
        }
        return false
    }

    var passLabel: String {
        if let cantAnswerLabel, !cantAnswerLabel.isEmpty {
            return cantAnswerLabel
        }
        return isFileQuestion ? L10n.claimTodoDontHave : L10n.claimTodoDontKnow
    }

    var currentFileIds: [String] {
        guard case let .fileUpload(currentFiles) = content else { return [] }
        return
            currentFiles
            .map(\.id)
    }
}

extension ClaimFollowupFile {
    var asFile: File {
        let mimeType = MimeType.findBy(mimeType: contentType)
        return File(id: id, size: 0, mimeType: mimeType, name: fileName, source: .url(url: url, mimeType: mimeType))
    }
}
