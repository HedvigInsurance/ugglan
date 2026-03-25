import XCTest
import hCore

@testable import TerminateContracts

final class TerminationDateLandingScreenViewModelTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        let mockClient = MockTerminateContractsClient()
        mockClient.notificationToReturn = .init(message: "Test notification", type: .info)
        Dependencies.shared.add(module: Module { () -> TerminateContractsClient in mockClient })
    }

    @MainActor
    func testIsDeletion_withDeleteAction() {
        let navVM = TerminationFlowNavigationViewModel(
            configs: [MockTerminationData.testConfig],
            terminateInsuranceViewModel: nil
        )
        navVM.surveyData = MockTerminationData.deleteSurveyData
        XCTAssertTrue(navVM.isDeletion)
    }

    @MainActor
    func testIsDeletion_withTerminateAction() {
        let navVM = TerminationFlowNavigationViewModel(
            configs: [MockTerminationData.testConfig],
            terminateInsuranceViewModel: nil
        )
        navVM.surveyData = MockTerminationData.terminateSurveyData
        XCTAssertFalse(navVM.isDeletion)
    }

    @MainActor
    func testExtraCoverage_fromAction() {
        let navVM = TerminationFlowNavigationViewModel(
            configs: [MockTerminationData.testConfig],
            terminateInsuranceViewModel: nil
        )
        navVM.surveyData = MockTerminationData.terminateSurveyData
        XCTAssertEqual(navVM.extraCoverage.count, 1)
        XCTAssertEqual(navVM.extraCoverage.first?.displayName, "Travel plus")
    }
}
