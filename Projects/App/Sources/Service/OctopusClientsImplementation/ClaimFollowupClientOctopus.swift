import Claims
import Foundation
import hCore

// The follow-up schema is not published yet; the operations are parked in GraphQL/Octopus/Claims/Unpublished.
final class ClaimFollowupClientOctopus: hClaimFollowupClient {
    init() {}

    func getFollowups() async throws -> [ClaimFollowup] {
        []
    }

    func answer(
        followupId _: String,
        questionId _: String,
        answer _: ClaimFollowupAnswer
    ) async throws -> ClaimFollowup {
        throw ClaimFollowupError.noFollowup
    }

    func cantAnswer(followupId _: String, questionId _: String, comment _: String?) async throws -> ClaimFollowup {
        throw ClaimFollowupError.noFollowup
    }

    func upload(
        followupId _: String,
        questionId _: String,
        files _: [File]
    ) async throws -> [ClaimFollowupUploadedFile] {
        throw ClaimFollowupError.noFollowup
    }

    func uploadAudio(followupId _: String, questionId _: String, audioFileURL _: URL) async throws -> String {
        throw ClaimFollowupError.noFollowup
    }

    func send(followupId _: String) async throws -> ClaimFollowup {
        throw ClaimFollowupError.noFollowup
    }
}
