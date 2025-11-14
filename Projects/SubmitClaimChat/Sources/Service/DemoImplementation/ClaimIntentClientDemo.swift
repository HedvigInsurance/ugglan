import Foundation

public class ClaimIntentClientDemo: ClaimIntentClient {
    public init() {}

    public func startClaimIntent(input: StartClaimInput) async throws -> ClaimIntent? {
        .init(currentStep: .init(content: .text, id: "id", text: ""), id: "", sourceMessages: [])
    }

    public func claimIntentSubmitAudio(
        fileId: String?,
        freeText: String?,
        stepId: String
    ) async throws -> ClaimIntent? {
        .init(currentStep: .init(content: .text, id: "id", text: ""), id: "", sourceMessages: [])
    }

    public func claimIntentSubmitForm(fields: [FieldValue], stepId: String) async throws -> ClaimIntent? {
        .init(currentStep: .init(content: .text, id: "id", text: ""), id: "", sourceMessages: [])
    }

    public func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntent? {
        .init(currentStep: .init(content: .text, id: "id", text: ""), id: "", sourceMessages: [])
    }

    public func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntent? {
        .init(currentStep: .init(content: .text, id: "id", text: ""), id: "", sourceMessages: [])
    }

    public func getNextStep(claimIntentId: String) async throws -> ClaimIntentStep {
        .init(content: .text, id: "id", text: "")
    }
}
