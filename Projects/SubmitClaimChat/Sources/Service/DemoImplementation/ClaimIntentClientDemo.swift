import Foundation

public class ClaimIntentClientDemo: ClaimIntentClient {
    public init() {}
    var claimIntentSubmitTaskCounter = 0
    public func startClaimIntent(input: StartClaimInput) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(
                    content: .singleSelect(
                        model: .init(
                            defaultSelectedId: nil,
                            options: [
                                .init(
                                    id: "id1",
                                    title: "Option 1"
                                ),
                                .init(
                                    id: "id2",
                                    title: "Option 2"
                                ),
                            ],
                            style: .pill
                        )
                    ),
                    id: "1",
                    text: "Select one"
                ),
                id: UUID().uuidString,
                isSkippable: true,
                isRegrettable: true,
                progress: 0
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
                currentStep: .init(
                    content: .form(
                        model: .init(
                            fields: []
                        )
                    ),
                    id: "id",
                    text: ""
                ),
                id: "",
                isSkippable: false,
                isRegrettable: false,
                progress: 0
            )
        )
    }

    public func claimIntentSubmitFile(stepId: String, fildIds: [String]) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(
                    content: .form(
                        model: .init(
                            fields: []
                        )
                    ),
                    id: "id",
                    text: ""
                ),
                id: "",
                isSkippable: false,
                isRegrettable: false,
                progress: 0
            )
        )
    }

    public func claimIntentSubmitForm(fields: [FieldValue], stepId: String) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(
                    content: .task(model: .init(description: "Processing....", isCompleted: false)),
                    id: UUID().uuidString,
                    text: "Task Step"
                ),
                id: UUID().uuidString,
                isSkippable: false,
                isRegrettable: false,
                progress: 0
            )
        )
    }

    public func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntentType? {
        .intent(
            model:
                .init(
                    currentStep: .init(
                        content: .form(
                            model: .init(
                                fields: []
                            )
                        ),
                        id: "id",
                        text: ""
                    ),
                    id: "",
                    isSkippable: false,
                    isRegrettable: false,
                    progress: 0
                )
        )
    }

    public func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(
                    content: .form(
                        model: .init(
                            fields: []
                        )
                    ),
                    id: "id",
                    text: ""
                ),
                id: "",
                isSkippable: false,
                isRegrettable: false,
                progress: 0
            )
        )
    }

    public func claimIntentSubmitSelect(stepId: String, selectedValue: String) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(
                    content: .form(
                        model: .init(
                            fields: [
                                .init(
                                    defaultValues: ["text"],
                                    id: "1",
                                    isRequired: false,
                                    maxValue: nil,
                                    minValue: nil,
                                    options: [],
                                    suffix: nil,
                                    title: "Text field",
                                    type: .text
                                ),
                                .init(
                                    defaultValues: ["22"],
                                    id: "2",
                                    isRequired: false,
                                    maxValue: nil,
                                    minValue: nil,
                                    options: [],
                                    suffix: nil,
                                    title: "Number field",
                                    type: .number
                                ),
                                .init(
                                    defaultValues: ["1"],
                                    id: "3",
                                    isRequired: false,
                                    maxValue: nil,
                                    minValue: nil,
                                    options: [
                                        .init(title: "Option 1", value: "1"),
                                        .init(title: "Option 2", value: "2"),
                                        .init(title: "Option 3", value: "3"),
                                    ],
                                    suffix: nil,
                                    title: "Single select",
                                    type: .singleSelect
                                ),
                                .init(
                                    defaultValues: ["1", "2"],
                                    id: "4",
                                    isRequired: false,
                                    maxValue: nil,
                                    minValue: nil,
                                    options: [
                                        .init(title: "Option 1", value: "1"),
                                        .init(title: "Option 2", value: "2"),
                                        .init(title: "Option 3", value: "3"),
                                    ],
                                    suffix: nil,
                                    title: "Multi select",
                                    type: .multiSelect
                                ),
                            ]
                        )
                    ),
                    id: UUID().uuidString,
                    text: "Form"
                ),
                id: UUID().uuidString,
                isSkippable: true,
                isRegrettable: true,
                progress: 0
            )
        )
    }

    public func claimIntentSkipStep(stepId: String) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(
                    content: .form(
                        model: .init(
                            fields: []
                        )
                    ),
                    id: "id",
                    text: ""
                ),
                id: "",
                isSkippable: false,
                isRegrettable: false,
                progress: 0
            )
        )
    }

    public func claimIntentRegretStep(stepId: String) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(
                    content: .form(
                        model: .init(
                            fields: []
                        )
                    ),
                    id: "id",
                    text: ""
                ),
                id: "",
                isSkippable: false,
                isRegrettable: false,
                progress: 0
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
                isRegrettable: false,
                progress: 0
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
            isRegrettable: false,
            progress: 0
        ),
        service: ClaimIntentService()
    ) { _ in
    }

    var demoFileUploadModel = {
        let model = SubmitClaimFileUploadStep(
            claimIntent: .init(
                currentStep: .init(
                    content: .fileUpload(model: .init(uploadURI: "")),
                    id: "id",
                    text: "text to display"
                ),
                id: "id",
                isSkippable: true,
                isRegrettable: true,
                progress: 0
            ),
            service: ClaimIntentService()
        ) { _ in
        }
        return model
    }()
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
            isRegrettable: true,
            progress: 0
        ),
        service: ClaimIntentService(),
        mainHandler: { _ in
        }
    )
}
