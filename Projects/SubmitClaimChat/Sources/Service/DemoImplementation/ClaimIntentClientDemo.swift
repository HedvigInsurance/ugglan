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
    @MainActor
    let demoFormModel = SubmitClaimFormStep(
        claimIntent: .init(
            currentStep: .init(
                content: .form(
                    model: .init(
                        fields: [
                            .init(
                                defaultValues: [],
                                id: "id1",
                                isRequired: true,
                                maxValue: nil,
                                minValue: nil,
                                options: [],
                                suffix: "test",
                                title: "text",
                                type: .text
                            ),
                            .init(
                                defaultValues: [],
                                id: "id2",
                                isRequired: true,
                                maxValue: nil,
                                minValue: nil,
                                options: [],
                                suffix: nil,
                                title: "number",
                                type: .number
                            ),
                            .init(
                                defaultValues: [],
                                id: "id3",
                                isRequired: true,
                                maxValue: nil,
                                minValue: nil,
                                options: [
                                    .init(title: "Opt 1", value: "opt1"),
                                    .init(title: "Opt 2", value: "opt2"),
                                ],
                                suffix: nil,
                                title: "binary",
                                type: .binary
                            ),
                            .init(
                                defaultValues: [],
                                id: "id4",
                                isRequired: true,
                                maxValue: nil,
                                minValue: nil,
                                options: [],
                                suffix: nil,
                                title: "date",
                                type: .date
                            ),
                            .init(
                                defaultValues: ["opt1"],
                                id: "id5",
                                isRequired: true,
                                maxValue: nil,
                                minValue: nil,
                                options: [
                                    .init(title: "Opt 1", value: "opt1"),
                                    .init(title: "Opt 2", value: "opt2"),
                                ],
                                suffix: nil,
                                title: "single select",
                                type: .singleSelect
                            ),
                            .init(
                                defaultValues: [],
                                id: "id6",
                                isRequired: true,
                                maxValue: nil,
                                minValue: nil,
                                options: [
                                    .init(title: "Opt 1", value: "opt1"),
                                    .init(title: "Opt 2", value: "opt2"),
                                ],
                                suffix: nil,
                                title: "multi select",
                                type: .multiSelect
                            ),
                        ]
                    )
                ),
                id: "id1",
                text: "text"
            ),
            id: "stepId",
            isSkippable: true,
            isRegrettable: true
        ),
        service: ClaimIntentService(),
        mainHandler: { _ in
        }
    )
}
