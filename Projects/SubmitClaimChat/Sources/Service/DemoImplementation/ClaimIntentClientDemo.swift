import Foundation

public class ClaimIntentClientDemo: ClaimIntentClient {
    public init() {}

    public func startClaimIntent(input: StartClaimInput) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(content: .unknown, id: "id", text: ""),
                id: "",
                isSkippable: false,
                isRegrettable: false
            )
        )
    }

    public func claimIntentSubmitAudio(
        fileId: String?,
        freeText: String?,
        stepId: String
    ) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(content: .unknown, id: "id", text: ""),
                id: "",
                isSkippable: false,
                isRegrettable: false
            )
        )
    }

    public func claimIntentSubmitFile(stepId: String, fildIds: [String]) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(content: .unknown, id: "id", text: ""),
                id: "",
                isSkippable: false,
                isRegrettable: false
            )
        )
    }

    public func claimIntentSubmitForm(fields: [FieldValue], stepId: String) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(content: .unknown, id: "id", text: ""),
                id: "",
                isSkippable: false,
                isRegrettable: false
            )
        )
    }

    public func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntentType? {
        .intent(
            model:
                .init(
                    currentStep: .init(content: .unknown, id: "id", text: ""),
                    id: "",
                    isSkippable: false,
                    isRegrettable: false
                )
        )
    }

    public func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(content: .unknown, id: "id", text: ""),
                id: "",
                isSkippable: false,
                isRegrettable: false
            )
        )
    }

    public func claimIntentSubmitSelect(stepId: String, selectedValue: String) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(content: .unknown, id: "id", text: ""),
                id: "",
                isSkippable: false,
                isRegrettable: false
            )
        )
    }

    public func claimIntentSkipStep(stepId: String) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(content: .unknown, id: "id", text: ""),
                id: "",
                isSkippable: false,
                isRegrettable: false
            )
        )
    }

    public func claimIntentRegretStep(stepId: String) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(content: .unknown, id: "id", text: ""),
                id: "",
                isSkippable: false,
                isRegrettable: false
            )
        )
    }

    public func getNextStep(claimIntentId: String) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(content: .unknown, id: "id", text: ""),
                id: "",
                isSkippable: false,
                isRegrettable: false
            )
        )
    }
}
