import Foundation
@preconcurrency import XCTest
import hCore

@testable import TerminateContracts

@MainActor
final class TerminationDateLandingScreenViewModelTests: XCTestCase {
    weak var viewModel: SetTerminationDateLandingScreenViewModel?
    let context = "context"

    override func setUp() async throws {
        try await super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    }

    override func tearDown() async throws {
        try await Task.sleep(nanoseconds: 100)
        XCTAssertNil(viewModel)
    }

    func testGetNotificaitonSuccess() async throws {
        let date = Date()
        let contractId = UUID().uuidString
        _ = MockData.createMockTerminateContractsService(getNotification: { contractId, date in
            return .init(message: contractId + date.localDateString, type: .info)
        })
        
        let model: TerminationFlowDateNextStepModel = .init(
            id: "id",
            maxDate: Date().addingTimeInterval(60 * 60 * 24 * 90).description,
            minDate: Date().localDateString,
            date: nil,
            extraCoverageItem: [
                .init(displayName: "Travel plus", displayValue: "45 days")
            ]
        )
        let navigationModel = TerminationFlowNavigationViewModel(
            stepResponse: .init(
                context: "context",
                step: .setTerminationDateStep(model: model),
                progress: nil
            ),
            config: .init(
                contractId: contractId,
                contractDisplayName: "displayName",
                contractExposureName: "exposureName",
                activeFrom: Date().localDateString,
                typeOfContract: .seApartmentBrf
            ),
            terminateInsuranceViewModel: nil
        )
        let vm = SetTerminationDateLandingScreenViewModel(terminationNavigationVm: navigationModel)
        self.viewModel = vm
        navigationModel.terminationDateStepModel?.date = date
        navigationModel.fetchNotification(isDeletion: false)
        try await Task.sleep(nanoseconds: 100_000_000)
        assert((navigationModel.notification == .init(message: contractId + date.localDateString, type: .info)))
        assert(vm.isDeletion == false)
        navigationModel.reset()
        assert((navigationModel.notification == nil)

        
    }
}
