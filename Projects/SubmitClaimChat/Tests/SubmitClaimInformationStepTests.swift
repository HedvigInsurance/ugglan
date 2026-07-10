@preconcurrency import XCTest
import hCore

@testable import SubmitClaimChat

@MainActor
final class SubmitClaimInformationStepTests: XCTestCase {
    weak var sut: MockClaimIntentClient?

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ClaimIntentClient.self)
        try await Task.sleep(nanoseconds: 100)
        XCTAssertNil(sut)
    }

    func testCreateHandlerForInformationContentSuccess() {
        let mockClient = MockData.createMockClaimIntentClient()
        sut = mockClient

        let handler = ClaimIntentStepHandlerFactory.createHandler(
            for: .informationStep(stepId: "step-id", severity: .critical),
            service: ClaimIntentService(),
            alertVm: SubmitClaimChatScreenAlertViewModel(),
            mainHandler: { _ in }
        )

        let informationHandler = handler as? SubmitClaimInformationStep
        XCTAssertNotNil(informationHandler)
        XCTAssertEqual(informationHandler?.informationModel.severity, .critical)
        XCTAssertEqual(informationHandler?.informationModel.buttonTitle, "I understand")
    }

    func testExecuteStepSubmitInformationSuccess() async throws {
        let mockClient = MockData.createMockClaimIntentClient(submitInformation: { _ in
            .intent(model: .informationStep(stepId: "next-step-id", severity: .info))
        })
        sut = mockClient

        let handler = SubmitClaimInformationStep(
            claimIntent: .informationStep(stepId: "step-id", severity: .info),
            service: ClaimIntentService(),
            mainHandler: { _ in }
        )

        let result = try await handler.executeStep()

        XCTAssertEqual(mockClient.events, [.claimIntentSubmitInformation(stepId: "step-id")])
        guard case let .intent(model) = result else {
            XCTFail("Expected the next intent to be returned")
            return
        }
        XCTAssertEqual(model.currentStep.id, "next-step-id")
    }

    func testExecuteStepSubmitInformationFailure() async {
        let mockClient = MockData.createMockClaimIntentClient(submitInformation: { _ in
            throw ClaimIntentError.error(message: "error")
        })
        sut = mockClient

        let handler = SubmitClaimInformationStep(
            claimIntent: .informationStep(stepId: "step-id", severity: .critical),
            service: ClaimIntentService(),
            mainHandler: { _ in }
        )

        do {
            _ = try await handler.executeStep()
            XCTFail("Expected executeStep to throw")
        } catch {
            XCTAssertTrue(error is ClaimIntentError)
        }
        XCTAssertEqual(mockClient.events, [.claimIntentSubmitInformation(stepId: "step-id")])
    }
}
