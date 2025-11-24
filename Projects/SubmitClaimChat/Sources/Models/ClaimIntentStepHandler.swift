import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
class ClaimIntentStepHandler: ObservableObject, @MainActor Identifiable {
    var id: String { claimIntent.currentStep.id }
    var claimIntent: ClaimIntent
    var sender: SubmitClaimChatMesageSender { .member }
    var isSkippable: Bool { claimIntent.isSkippable }
    var isRegrettable: Bool { claimIntent.isRegrettable }

    @Published var isLoading: Bool = false
    @Published var isEnabled: Bool = true
    @Published var error: Error?

    let service: ClaimIntentService
    let mainHandler: (SubmitClaimEvent) -> Void

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        self.claimIntent = claimIntent
        self.service = service
        self.mainHandler = mainHandler
    }

    func validateInput() -> Bool {
        true
    }

    func executeStep() async throws -> ClaimIntentType {
        fatalError("submitResponse must be overridden")
    }

    final func submitResponse() async {
        withAnimation {
            isLoading = true
            isEnabled = false
        }
        defer {
            withAnimation {
                isEnabled = self.error != nil
                isLoading = false
            }
        }
        do {
            let result = try await executeStep()

            switch result {
            case let .intent(model):
                mainHandler(.goToNext(claimIntent: model))
            case let .outcome(model):
                mainHandler(.outcome(model: model))
            }

        } catch let error {
            self.error = error
        }
    }

    func skip() async {
        withAnimation {
            isLoading = true
            isEnabled = false
        }
        defer {
            withAnimation {
                isEnabled = true
                isLoading = false
            }
        }
        do {
            let result = try await service.claimIntentSkipStep(stepId: id)
            guard let result else {
                throw ClaimIntentError.invalidResponse
            }
            switch result {
            case let .intent(model):
                mainHandler(.goToNext(claimIntent: model))
            case let .outcome(model):
                mainHandler(.outcome(model: model))
            }
        } catch let ex {
            self.error = ex
        }
    }

    func regret() async {
        withAnimation {
            isLoading = true
            isEnabled = false
        }
        defer {
            withAnimation {
                isEnabled = true
                isLoading = false
            }
        }

        do {
            let result = try await service.claimIntentRegretStep(stepId: id)
            guard let result else {
                throw ClaimIntentError.invalidResponse
            }
            withAnimation {
                isLoading = false
                isEnabled = false
            }

            switch result {
            case let .intent(model):
                mainHandler(.regret(currentClaimIntent: claimIntent, newclaimIntent: model))
            case .outcome:
                break
            }
        } catch let ex {
            self.error = ex
        }
    }
}

enum ClaimIntentStepHandlerFactory {
    @MainActor
    static func createHandler(
        for claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping ((SubmitClaimEvent) -> Void)
    ) -> ClaimIntentStepHandler {
        switch claimIntent.currentStep.content {
        case .form:
            return SubmitClaimFormStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .task:
            return SubmitClaimTaskStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .audioRecording:
            return SubmitClaimAudioStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .summary:
            return SubmitClaimSummaryStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .text:
            return SubmitClaimTextStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .singleSelect:
            return SubmitClaimSingleSelectStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .fileUpload:
            return SubmitClaimFileUploadStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        case .unknown:
            return SubmitClaimUnknownStep(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
        }
    }
}

enum SubmitClaimEvent {
    case goToNext(claimIntent: ClaimIntent)
    case regret(currentClaimIntent: ClaimIntent, newclaimIntent: ClaimIntent)
    case outcome(model: ClaimIntentStepOutcome)
}

// MARK: - Errors
enum ClaimIntentError: Error {
    case invalidInput
    case invalidResponse
    case unknown
}
