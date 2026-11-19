import Foundation
import hCore

@MainActor
public protocol hClaimFollowupClient {
    func getFollowups() async throws -> [ClaimFollowup]
    func answer(followupId: String, questionId: String, answer: ClaimFollowupAnswer) async throws -> ClaimFollowup
    func cantAnswer(followupId: String, questionId: String, comment: String?) async throws -> ClaimFollowup
    func upload(followupId: String, questionId: String, files: [File]) async throws -> [ClaimFollowupUploadedFile]
    func uploadAudio(followupId: String, questionId: String, audioFileURL: URL) async throws -> String
    func send(followupId: String) async throws -> ClaimFollowup
}

public enum ClaimFollowupAnswer: Equatable, Sendable {
    case binary(Bool)
    case freeText(String)
    case audio(fileId: String)
    case date(String)
    case number(String)
    case phoneNumber(String)
    case files(fileIds: [String])
}

public enum ClaimFollowupError: LocalizedError {
    case userError(message: String)
    case noFollowup

    public var errorDescription: String? {
        L10n.General.errorBody
    }
}
