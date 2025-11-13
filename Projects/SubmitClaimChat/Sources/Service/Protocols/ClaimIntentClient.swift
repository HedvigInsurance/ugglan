import Foundation
import hCore

@MainActor
public protocol ClaimIntentClient {
    func startClaimIntent(sourceMessageId: String?) async throws -> ClaimIntent?
    func claimIntentSubmitAudio(fileId: String?, freeText: String?, stepId: String) async throws -> ClaimIntent?
    func claimIntentSubmitFile(stepId: String, fildIds: [String]) async throws -> ClaimIntent?
    func claimIntentSubmitForm(
        fields: [FieldValue],
        stepId: String
    ) async throws -> ClaimIntent?
    func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntent?
    func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntent?
    func getNextStep(claimIntentId: String) async throws -> ClaimIntentStep
}

public struct FieldValue: Codable {
    public let id: String
    public let values: [String]

    public init(id: String, values: [String]) {
        self.id = id
        self.values = values
    }
}

@MainActor
class ClaimIntentService {
    @Inject var client: ClaimIntentClient

    func startClaimIntent(sourceMessageId: String?) async throws -> ClaimIntent? {
        let data = try await client.startClaimIntent(sourceMessageId: sourceMessageId)
        return data
    }

    func claimIntentSubmitAudio(fileId: String?, freeText: String?, stepId: String) async throws -> ClaimIntent? {
        let data = try await client.claimIntentSubmitAudio(fileId: fileId, freeText: freeText, stepId: stepId)
        return data
    }

    func claimIntentSubmitFile(stepId: String, fildIds: [String]) async throws -> ClaimIntent? {
        let data = try await client.claimIntentSubmitFile(stepId: stepId, fildIds: fildIds)
        return data
    }

    func claimIntentSubmitForm(
        fields: [FieldValue],
        stepId: String
    ) async throws -> ClaimIntent? {
        let data = try await client.claimIntentSubmitForm(fields: fields, stepId: stepId)
        return data
    }

    func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntent? {
        let data = try await client.claimIntentSubmitSummary(stepId: stepId)
        return data
    }

    func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntent? {
        let data = try await client.claimIntentSubmitTask(stepId: stepId)
        return data
    }

    func getNextStep(claimIntentId: String) async throws -> ClaimIntentStep {
        let data = try await client.getNextStep(claimIntentId: claimIntentId)
        return data
    }
}
