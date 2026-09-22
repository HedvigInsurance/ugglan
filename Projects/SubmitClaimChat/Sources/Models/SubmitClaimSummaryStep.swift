import Claims
import SwiftUI
import hCore
import hCoreUI

final class SubmitClaimSummaryStep: ClaimIntentStepHandler {
    override var sender: SubmitClaimChatMessageSender { .hedvig }

    let summaryModel: ClaimIntentStepContentSummary
    let fileGridViewModel: FileGridViewModel
    let audioPlayers: [URL: AudioPlayer]
    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .summary(let model) = claimIntent.currentStep.content else {
            fatalError("SummaryStepHandler initialized with non-summary content")
        }
        self.summaryModel = model
        self.fileGridViewModel = .init(
            files: model.fileUploads.map({
                .init(
                    id: $0.url.absoluteString,
                    size: 0,
                    mimeType: $0.contentType,
                    name: $0.fileName,
                    source: .url(url: $0.url, mimeType: $0.contentType)
                )
            }),
            options: []
        )

        var audioURLs = model.audioRecordings.map(\.url)
        for answer in model.answers {
            if case let .audio(url, _) = answer.value {
                audioURLs.append(url)
            }
        }
        self.audioPlayers = Dictionary(
            audioURLs.map { ($0, AudioPlayer(url: $0)) },
            uniquingKeysWith: { existing, _ in existing }
        )

        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        Task { [weak self] in
            await delay(ClaimChatConstants.Timing.shortDelay)
            self?.state.showResults = true
        }
    }

    override func executeStep() async throws -> ClaimIntentType {
        guard
            let result = try await service.claimIntentSubmitSummary(
                stepId: claimIntent.currentStep.id
            )
        else {
            throw ClaimIntentError.invalidResponse
        }
        return result
    }

    override func accessibilityEditHint() -> String {
        ""
    }
}
