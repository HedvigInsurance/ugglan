import Combine
import Foundation
@preconcurrency import XCTest
import hCore
import hCoreUI

@testable import TerminateContracts

@MainActor
final class TerminationDeflectAutoDecomViewModelTests: XCTestCase {
    weak var viewModel: TerminationDeflectAutoDecomViewModel?
    let context = "test-context"

    override func setUp() async throws {
        try await super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    }

    override func tearDown() async throws {
        try await Task.sleep(nanoseconds: 100)
        XCTAssertNil(viewModel)
    }

    // MARK: - Success Tests

    func testContinueWithTerminationSuccess() async throws {
        let expectedStep = TerminateStepResponse(
            context: context,
            step: .setTerminationSurveyStep(model: .init(id: "survey-id", options: [], subTitleType: .generic)),
            progress: 0.5
        )

        let mockService = createMockService(
            sendContinueOnDecom: { terminationContext in
                assert(terminationContext == self.context)
                return expectedStep
            }
        )

        let (vm, navigationModel) = createViewModel(context: context)

        let stateChanges = await trackStateChanges(vm: vm) {
            await vm.continueWithTermination()
        }

        verifyServiceCalled(mockService, expectedEvent: .sendContinueAfterDecom)
        assertStateTransition(stateChanges, expected: [.success, .loading, .success])
        assert(navigationModel.currentContext == context)
    }

    func testNavigationWithDifferentSteps() async throws {
        let surveyModel = TerminationFlowSurveyStepModel(id: "survey-id", options: [], subTitleType: .generic)
        let expectedStep = TerminateStepResponse(
            context: "new-context",
            step: .setTerminationSurveyStep(model: surveyModel),
            progress: 0.75
        )

        let mockService = createMockService(
            sendContinueOnDecom: { _ in expectedStep }
        )

        let (vm, navigationModel) = createViewModel(context: context)
        assert(navigationModel.currentContext == context)

        let stateChanges = await trackStateChanges(vm: vm) {
            await vm.continueWithTermination()
        }

        verifyServiceCalled(mockService, expectedEvent: .sendContinueAfterDecom)
        assertStateTransition(stateChanges, expected: [.success, .loading, .success])
        assert(navigationModel.currentContext == "new-context")
        assert(navigationModel.terminationSurveyStepModel?.id == surveyModel.id)
    }

    // MARK: - Failure Tests

    func testContinueWithTerminationFailure() async throws {
        let mockService = createMockService(
            sendContinueOnDecom: { _ in throw TerminationError.error }
        )

        let (vm, navigationModel) = createViewModel(context: context)

        let stateChanges = await trackStateChanges(vm: vm) {
            await vm.continueWithTermination()
        }

        verifyServiceCalled(mockService, expectedEvent: .sendContinueAfterDecom)
        assertStateTransition(stateChanges, expected: [.success, .loading])
        assertErrorState(stateChanges.last)
        assert(navigationModel.currentContext != nil)
    }

    // MARK: - Edge Case Tests

    func testNavigationViewModelWeakReference() async throws {
        let mockService = createMockService(
            sendContinueOnDecom: { _ in
                .init(
                    context: self.context,
                    step: .setSuccessStep(model: .init(terminationDate: nil)),
                    progress: 1.0
                )
            }
        )

        var navigationModel: TerminationFlowNavigationViewModel? = createNavigationModel(context: context)
        let vm = TerminationDeflectAutoDecomViewModel(navigationVM: navigationModel!)
        self.viewModel = vm

        assert(vm.navigationVM != nil)

        navigationModel = nil
        assert(vm.navigationVM == nil)

        let stateChanges = await trackStateChanges(vm: vm) {
            await vm.continueWithTermination()
        }

        assert(mockService.events.isEmpty, "Service should not be called with nil navigationVM")
        assertStateTransition(stateChanges, expected: [.success])
    }

    // MARK: - Helper Methods - Setup
    private func createViewModel(
        context: String
    ) -> (vm: TerminationDeflectAutoDecomViewModel, navigation: TerminationFlowNavigationViewModel) {
        let navigationModel = createNavigationModel(context: context)
        let vm = TerminationDeflectAutoDecomViewModel(navigationVM: navigationModel)
        self.viewModel = vm
        return (vm, navigationModel)
    }

    private func createNavigationModel(context: String) -> TerminationFlowNavigationViewModel {
        let model = TerminationFlowDateNextStepModel(
            id: "test-id",
            maxDate: Date().addingTimeInterval(60 * 60 * 24 * 90).description,
            minDate: Date().localDateString,
            date: nil,
            extraCoverageItem: []
        )

        return TerminationFlowNavigationViewModel(
            stepResponse: .init(
                context: context,
                step: .setTerminationDateStep(model: model),
                progress: 0.0
            ),
            config: .init(
                contractId: "test-contract-id",
                contractDisplayName: "Test Contract",
                contractExposureName: "Test Exposure",
                activeFrom: Date().localDateString,
                typeOfContract: .seApartmentBrf
            ),
            terminateInsuranceViewModel: nil
        )
    }

    private func createMockService(
        sendContinueOnDecom: @escaping SendContinueOnDecom
    ) -> MockTerminateContractsService {
        MockData.createMockTerminateContractsService(sendContinueOnDecom: sendContinueOnDecom)
    }

    // MARK: - Helper Methods - State Tracking
    /// Tracks state changes during an async operation using Combine
    private func trackStateChanges(
        vm: TerminationDeflectAutoDecomViewModel,
        operation: @escaping () async -> Void
    ) async -> [ProcessingState] {
        var stateChanges: [ProcessingState] = []
        var cancellables = Set<AnyCancellable>()

        vm.$state
            .sink { stateChanges.append($0) }
            .store(in: &cancellables)

        await operation()
        try? await Task.sleep(nanoseconds: 10_000_000)
        cancellables.removeAll()

        return stateChanges
    }

    // MARK: - Helper Methods - Assertions
    /// Asserts state transitions match expected sequence
    private func assertStateTransition(_ actual: [ProcessingState], expected: [ProcessingState]) {
        assert(
            actual.count >= expected.count,
            "Expected at least \(expected.count) state changes, got \(actual.count)"
        )

        for (index, expectedState) in expected.enumerated() {
            assert(
                actual[index] == expectedState,
                "State \(index + 1): Expected \(expectedState), got \(actual[index])"
            )
        }
    }

    /// Asserts the state is an error state
    private func assertErrorState(_ state: ProcessingState?) {
        guard let state else {
            XCTFail("State is nil")
            return
        }

        if case .error = state {
            // Success - state is error as expected
        } else {
            XCTFail("Expected state to be error, got \(state)")
        }
    }

    /// Verifies the mock service was called with the expected event
    private func verifyServiceCalled(
        _ service: MockTerminateContractsService,
        expectedEvent: MockTerminateContractsService.Event
    ) {
        assert(service.events.count == 1, "Expected 1 service call, got \(service.events.count)")
        assert(service.events.first == expectedEvent, "Expected \(expectedEvent), got \(service.events.first!)")
    }
}
