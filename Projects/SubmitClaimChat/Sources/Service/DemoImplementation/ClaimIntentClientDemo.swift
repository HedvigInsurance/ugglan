import Foundation

public class ClaimIntentClientDemo: ClaimIntentClient {
    public init() {}
    var claimIntentSubmitTaskCounter = 0
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
        try await Task.sleep(seconds: 1)
        claimIntentSubmitTaskCounter += 1
        return .intent(
            model: .init(
                currentStep: .init(
                    content: .task(
                        model: .init(
                            description: "Text updated \(claimIntentSubmitTaskCounter)",
                            isCompleted: claimIntentSubmitTaskCounter > 3
                        )
                    ),
                    id: "id\(claimIntentSubmitTaskCounter)",
                    text: "text \(claimIntentSubmitTaskCounter)"
                ),
                id: "id\(claimIntentSubmitTaskCounter)",
                isSkippable: false,
                isRegrettable: false
            )
        )
    }
    let taskDemoStep = SubmitClaimTaskStep(
        claimIntent: .init(
            currentStep: .init(
                content: .task(
                    model: .init(
                        description: "Description",
                        isCompleted: false
                    )
                ),
                id: "id",
                text: "Text to show"
            ),
            id: "id",
            isSkippable: false,
            isRegrettable: false
        ),
        service: ClaimIntentService()
    ) { _ in
    }
}
