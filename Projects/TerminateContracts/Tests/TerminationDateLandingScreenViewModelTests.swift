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
        let mockService = MockData.createMockTerminateContractsService(getNotification: { contractId, date in
            .init(message: contractId + date.localDateString, type: .info)
        })
        let navigationModel = setNavigationModel(contractId: contractId)
        let vm = getTerminationDateLandingScreenViewModel(navigationModel: navigationModel)
        self.viewModel = vm
        navigationModel.terminationDateStepModel?.date = date
        navigationModel.fetchNotification(isDeletion: false)
        try await Task.sleep(nanoseconds: 100_000_000)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getNotification)
        assert(navigationModel.notification == .init(message: contractId + date.localDateString, type: .info))
        assert(vm.isDeletion == false)
        navigationModel.reset()
        assert((navigationModel.notification == nil))
    }

    func testGetNotificaitonFailure() async throws {
        let date = Date()
        let contractId = UUID().uuidString
        let mockService = MockData.createMockTerminateContractsService(getNotification: { contractId, date in
            throw TerminationError.error
        })
        let navigationModel = setNavigationModel(contractId: contractId)
        let vm = getTerminationDateLandingScreenViewModel(navigationModel: navigationModel)
        self.viewModel = vm
        navigationModel.terminationDateStepModel?.date = date
        navigationModel.fetchNotification(isDeletion: false)
        try await Task.sleep(nanoseconds: 100_000_000)
        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getNotification)
        assert(navigationModel.notification == nil)
        assert(vm.isDeletion == false)
        try await Task.sleep(nanoseconds: 1_100_000_000)
        assert(mockService.events.count == 2)
        assert(mockService.events == [.getNotification, .getNotification])
        assert((navigationModel.notification == nil))
    }
    func testGetNotificaitonSuccessAfterFailure() async throws {
        let date = Date()
        let contractId = UUID().uuidString
        let mockService = MockData.createMockTerminateContractsService(getNotification: { contractId, date in
            throw TerminationError.error
        })
        let navigationModel = setNavigationModel(contractId: contractId)
        let vm = getTerminationDateLandingScreenViewModel(navigationModel: navigationModel)
        self.viewModel = vm
        navigationModel.terminationDateStepModel?.date = date
        navigationModel.fetchNotification(isDeletion: false)
        //time for first one to execute
        try await Task.sleep(nanoseconds: 100_000_000)

        //fails after first try
        assert(mockService.events.count == 1)
        assert(navigationModel.notification == nil)
        assert(vm.isDeletion == false)
        //added 1 second delay to simulate retry logic
        try await Task.sleep(nanoseconds: 1_000_000_000)

        //fails after 2nd try
        assert(mockService.events.count == 2)
        assert((navigationModel.notification == nil))

        //update mock service to return success
        mockService.getNotification = { contractId, date in
            .init(message: contractId + date.localDateString, type: .info)
        }
        //added 1 second delay to simulate retry logic
        try await Task.sleep(nanoseconds: 1_000_000_000)

        //success after 3nd try
        assert(mockService.events.count == 3)
        assert(navigationModel.notification == .init(message: contractId + date.localDateString, type: .info))
        assert(mockService.events.allSatisfy { $0 == .getNotification })
    }

    private func setNavigationModel(contractId: String) -> TerminationFlowNavigationViewModel {
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
        return navigationModel
    }

    private func getTerminationDateLandingScreenViewModel(
        navigationModel: TerminationFlowNavigationViewModel
    ) -> SetTerminationDateLandingScreenViewModel {
        let vm = SetTerminationDateLandingScreenViewModel(terminationNavigationVm: navigationModel)
        self.viewModel = vm
        return vm
    }
}
