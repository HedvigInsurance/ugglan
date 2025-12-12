import Foundation
import hCore

public enum ClaimIntentType {
    case intent(model: ClaimIntent)
    case outcome(model: ClaimIntentStepOutcome)
}

@MainActor
public protocol ClaimIntentClient {
    func startClaimIntent(input: StartClaimInput) async throws -> ClaimIntentType?
    func claimIntentSubmitAudio(fileId: String?, freeText: String?, stepId: String) async throws -> ClaimIntentType?
    func claimIntentSubmitFile(stepId: String, fildIds: [String]) async throws -> ClaimIntentType?
    func claimIntentSubmitForm(
        fields: [FieldValue],
        stepId: String
    ) async throws -> ClaimIntentType?
    func claimIntentSubmitSelect(stepId: String, selectedValue: String) async throws -> ClaimIntentType?
    func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntentType?
    func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntentType?
    func claimIntentSkipStep(stepId: String) async throws -> ClaimIntentType?
    func claimIntentRegretStep(stepId: String) async throws -> ClaimIntentType?
    func getNextStep(claimIntentId: String) async throws -> ClaimIntentType?
}

public struct StartClaimInput: Equatable, Identifiable {
    public let id: String
    public let sourceMessageId: String?
    public let devFlow: Bool

    public init(sourceMessageId: String?, devFlow: Bool = false) {
        self.id = UUID().uuidString
        self.sourceMessageId = sourceMessageId
        self.devFlow = devFlow
    }
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

    func startClaimIntent(input: StartClaimInput) async throws -> ClaimIntentType? {
        let data = try await client.startClaimIntent(input: input)
        return data
    }

    func claimIntentSubmitAudio(fileId: String?, freeText: String?, stepId: String) async throws -> ClaimIntentType? {
        let data = try await client.claimIntentSubmitAudio(fileId: fileId, freeText: freeText, stepId: stepId)
        return data
    }

    func claimIntentSubmitFile(stepId: String, fildIds: [String]) async throws -> ClaimIntentType? {
        let data = try await client.claimIntentSubmitFile(stepId: stepId, fildIds: fildIds)
        return data
    }

    func claimIntentSubmitForm(
        fields: [FieldValue],
        stepId: String
    ) async throws -> ClaimIntentType? {
        let data = try await client.claimIntentSubmitForm(fields: fields, stepId: stepId)
        return data
    }

    func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntentType? {
        let data = try await client.claimIntentSubmitSummary(stepId: stepId)
        return data
    }

    func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntentType? {
        let data = try await client.claimIntentSubmitTask(stepId: stepId)
        return data
    }

    func claimIntentSubmitSelect(stepId: String, selectedValue: String) async throws -> ClaimIntentType? {
        let data = try await client.claimIntentSubmitSelect(stepId: stepId, selectedValue: selectedValue)
        return data
    }

    func getNextStep(claimIntentId: String) async throws -> ClaimIntentType? {
        let data = try await client.getNextStep(claimIntentId: claimIntentId)
        return data
    }

    func claimIntentSkipStep(stepId: String) async throws -> ClaimIntentType? {
        let data = try await client.claimIntentSkipStep(stepId: stepId)
        return data
    }

    func claimIntentRegretStep(stepId: String) async throws -> ClaimIntentType? {
        let data = try await client.claimIntentRegretStep(stepId: stepId)
        return data
    }
}
