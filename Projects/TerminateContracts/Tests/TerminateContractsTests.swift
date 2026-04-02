import XCTest
import hCore

@testable import TerminateContracts

@MainActor
final class TerminateContractsTests: XCTestCase {
    private var mockClient: MockTerminateContractsClient!

    override func setUp() async throws {
        try await super.setUp()
        mockClient = MockTerminateContractsClient()
        Dependencies.shared.add(module: Module { () -> TerminateContractsClient in self.mockClient })
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testGetTerminationSurvey_success() async throws {
        mockClient.surveyDataToReturn = MockTerminationData.terminateSurveyData
        let service = TerminateContractsService()
        let result = try await service.getTerminationSurvey(contractId: "contract-123")
        XCTAssertEqual(result.options.count, 2)
        XCTAssertEqual(result.options.first?.title, "Better price")
    }

    func testGetTerminationSurvey_error() async {
        mockClient.errorToThrow = NSError(domain: "test", code: 1)
        let service = TerminateContractsService()
        do {
            _ = try await service.getTerminationSurvey(contractId: "contract-123")
            XCTFail("Expected error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testTerminateContract_success() async throws {
        mockClient.terminateResultToReturn = .success
        let service = TerminateContractsService()
        let result = try await service.terminateContract(
            contractId: "contract-123",
            terminationDate: "2026-04-01",
            surveyOptionId: "opt1",
            comment: nil
        )
        XCTAssertEqual(result, .success)
    }

    func testTerminateContract_userError() async throws {
        mockClient.terminateResultToReturn = .userError(message: "Cannot terminate")
        let service = TerminateContractsService()
        let result = try await service.terminateContract(
            contractId: "contract-123",
            terminationDate: "2026-04-01",
            surveyOptionId: "opt1",
            comment: nil
        )
        XCTAssertEqual(result, .userError(message: "Cannot terminate"))
    }

    func testDeleteContract_success() async throws {
        mockClient.deleteResultToReturn = .success
        let service = TerminateContractsService()
        let result = try await service.deleteContract(
            contractId: "contract-123",
            surveyOptionId: "opt1",
            comment: "Goodbye"
        )
        XCTAssertEqual(result, .success)
    }

    func testDeleteContract_userError() async throws {
        mockClient.deleteResultToReturn = .userError(message: "Cannot delete")
        let service = TerminateContractsService()
        let result = try await service.deleteContract(
            contractId: "contract-123",
            surveyOptionId: "opt1",
            comment: nil
        )
        XCTAssertEqual(result, .userError(message: "Cannot delete"))
    }
}
