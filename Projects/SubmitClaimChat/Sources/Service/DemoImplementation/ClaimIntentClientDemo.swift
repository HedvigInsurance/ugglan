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
                isRegrettable: true
            ),
            service: ClaimIntentService()
        ) { _ in
        }
        model.fileUploadVm.fileGridViewModel.files.append(
            .init(
                id: "id1",
                size: 0,
                mimeType: .PNG,
                name: "name",
                source: .url(
                    url: URL(
                        string:
                            "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fassets.hedvig.com%2Ff%2F165473%2F2694x1200%2F017b95ad16%2Fhander-mobiltelefon-app-hedvig-2700.jpg&w=3840&q=70"
                    )!,
                    mimeType: .PNG
                )
            )
        )
        model.fileUploadVm.fileGridViewModel.files.append(
            .init(
                id: "id2",
                size: 0,
                mimeType: .PNG,
                name: "name 2",
                source: .url(
                    url: URL(
                        string:
                            "https://www.hedvig.com/_next/image?url=https%3A%2F%2Fa.storyblok.com%2Ff%2F165473%2F1080x1080%2Fa44c261f97%2Fbetyg-konsumenternas-hedvig.png&w=3840&q=75"
                    )!,
                    mimeType: .PNG
                )
            )
        )
        return model
    }()
}
