import Foundation
import hCore

@testable import SubmitClaimChat

@MainActor
struct MockData {
    @discardableResult
    static func createMockClaimIntentClient(
        submitInformation: @escaping SubmitInformation = { _ in
            .intent(model: .informationStep(stepId: "next-step-id", severity: .info))
        }
    ) -> MockClaimIntentClient {
        let client = MockClaimIntentClient(submitInformation: submitInformation)
        Dependencies.shared.add(module: Module { () -> ClaimIntentClient in client })
        return client
    }
}

typealias SubmitInformation = @MainActor (String) async throws -> ClaimIntentType?

@MainActor
class MockClaimIntentClient: ClaimIntentClient {
    var events = [Event]()
    var submitInformation: SubmitInformation

    enum Event: Equatable {
        case claimIntentSubmitInformation(stepId: String)
    }

    init(submitInformation: @escaping SubmitInformation) {
        self.submitInformation = submitInformation
    }

    func startClaimIntent(input: StartClaimInput) async throws -> ClaimIntentType? {
        throw ClaimIntentError.invalidResponse
    }

    func claimIntentSubmitAudio(fileId: String?, freeText: String?, stepId: String) async throws -> ClaimIntentType? {
        throw ClaimIntentError.invalidResponse
    }

    func claimIntentSubmitFile(stepId: String, fileIds: [String]) async throws -> ClaimIntentType? {
        throw ClaimIntentError.invalidResponse
    }

    func claimIntentSubmitForm(fields: [FieldValue], stepId: String) async throws -> ClaimIntentType? {
        throw ClaimIntentError.invalidResponse
    }

    func claimIntentSubmitSelect(stepId: String, selectedValue: String) async throws -> ClaimIntentType? {
        throw ClaimIntentError.invalidResponse
    }

    func claimIntentSubmitSummary(stepId: String) async throws -> ClaimIntentType? {
        throw ClaimIntentError.invalidResponse
    }

    func claimIntentSubmitTask(stepId: String) async throws -> ClaimIntentType? {
        throw ClaimIntentError.invalidResponse
    }

    func claimIntentSubmitInformation(stepId: String) async throws -> ClaimIntentType? {
        events.append(.claimIntentSubmitInformation(stepId: stepId))
        return try await submitInformation(stepId)
    }

    func claimIntentSkipStep(stepId: String) async throws -> ClaimIntentType? {
        throw ClaimIntentError.invalidResponse
    }

    func claimIntentRegretStep(stepId: String) async throws -> ClaimIntentType? {
        throw ClaimIntentError.invalidResponse
    }

    func getNextStep(claimIntentId: String) async throws -> ClaimIntentType? {
        throw ClaimIntentError.invalidResponse
    }

    func claimIntentFormFieldSearch(
        stepId: String,
        fieldId: String,
        query: String
    ) async throws -> FormFieldSearchResult {
        throw ClaimIntentError.invalidResponse
    }
}

extension ClaimIntent {
    static func informationStep(
        stepId: String,
        severity: ClaimIntentStepContentInformation.Severity
    ) -> ClaimIntent {
        .init(
            currentStep: .init(
                content: .information(
                    model: .init(
                        notice: "Seek emergency accommodation.",
                        severity: severity,
                        buttonTitle: "I understand"
                    )
                ),
                id: stepId,
                text: nil
            ),
            id: "intent-id",
            isSkippable: false,
            isRegrettable: false,
            progress: 0.8
        )
    }
}
