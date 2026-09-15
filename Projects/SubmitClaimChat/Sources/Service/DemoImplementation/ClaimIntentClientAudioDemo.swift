import Foundation
import hCore

/// Demo flow that starts with the (redesigned) description step so the example app can show it.
public final class ClaimIntentClientAudioDemo: ClaimIntentClientDemo {
    public override init() {
        super.init()
    }

    public override func startClaimIntent(input: StartClaimInput) async throws -> ClaimIntentType? {
        .intent(
            model: .init(
                currentStep: .init(
                    content: .audioRecording(
                        model: .init(uploadURI: "/upload", freeTextMinLength: 10, freeTextMaxLength: 1000)
                    ),
                    id: "audio",
                    text: """
                        In order to help you faster we would like you to describe the situation.

                        Please answer the following questions:
                        - What happened?
                        - When did it happen?
                        - Where did it happen?
                        """
                ),
                id: UUID().uuidString,
                isSkippable: true,
                isRegrettable: true,
                progress: 0.3
            )
        )
    }

    public override func claimIntentSubmitAudio(
        fileId: String?,
        freeText: String?,
        stepId: String
    ) async throws -> ClaimIntentType? {
        try await Task.sleep(seconds: 1)
        return .intent(
            model: .init(
                currentStep: .init(
                    content: .singleSelect(
                        model: .init(
                            defaultSelectedId: nil,
                            options: [
                                .init(id: "id1", title: "Option 1"),
                                .init(id: "id2", title: "Option 2"),
                            ],
                            style: .pill
                        )
                    ),
                    id: "select",
                    text: "Thank you. Please confirm what best describes what happened."
                ),
                id: UUID().uuidString,
                isSkippable: true,
                isRegrettable: true,
                progress: 0.6
            )
        )
    }
}

/// Fakes the multipart upload used by the audio and file steps.
public final class SubmitClaimFileUploadClientDemo: hSubmitClaimFileUploadClient {
    public init() {}

    public func upload<T: Codable & Sendable>(
        url: URL,
        multipart: MultipartFormDataRequest,
        withProgress: (@Sendable (_ progress: Double) -> Void)?
    ) async throws -> T {
        for step in 1...5 {
            try await Task.sleep(seconds: 0.2)
            withProgress?(Double(step) / 5)
        }
        let data = try JSONEncoder().encode(["fileIds": ["demo-audio"]])
        return try JSONDecoder().decode(T.self, from: data)
    }
}
