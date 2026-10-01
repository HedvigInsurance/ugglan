@preconcurrency import XCTest
import hCore

@testable import Payment

/// `PaymentActionViewModel` runs one injected mutation, so the loading/error machinery is tested
/// once here and each factory is checked only for calling the right service method.
@MainActor
final class PaymentActionViewModelTests: XCTestCase {
    weak var sut: MockPaymentService?

    private let swishMethod = ConnectedPaymentMethod(
        status: .active,
        isDefault: true,
        method: .swish(phoneNumber: "0735328847")
    )

    private let trustlyMethod = ConnectedPaymentMethod(
        status: .active,
        isDefault: false,
        method: .trustly(bankAccount: .init(account: "1234", bank: "Bank"))
    )

    override func tearDown() async throws {
        Dependencies.shared.remove(for: hPaymentClient.self)
        await delay(0.00001)

        XCTAssertNil(sut)
    }

    // MARK: - perform

    func testInitialStateNotLoadingWithoutError() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = PaymentActionViewModel.remove(swishMethod)

        XCTAssertEqual(vm.processingState, .success)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertTrue(mockService.events.isEmpty)
    }

    func testPerformSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(removePaymentMethod: {})
        sut = mockService

        let vm = PaymentActionViewModel.remove(swishMethod)
        let result = await vm.perform()

        XCTAssertTrue(result)
        XCTAssertEqual(vm.processingState, .success)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(mockService.events, [.removePaymentMethod])
    }

    func testPerformLoadingWhileActionRuns() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = PaymentActionViewModel.remove(swishMethod)
        mockService.removePaymentMethodClosure = { [weak vm] in
            XCTAssertEqual(vm?.processingState, .loading)
            XCTAssertEqual(vm?.isLoading, true)
        }
        let result = await vm.perform()

        XCTAssertTrue(result)
        XCTAssertFalse(vm.isLoading)
    }

    func testPerformServiceErrorFailure() async {
        let error = PaymentError.missingDataError(message: "error")
        let mockService = MockPaymentData.createMockPaymentService(removePaymentMethod: { throw error })
        sut = mockService

        let vm = PaymentActionViewModel.remove(swishMethod)
        let result = await vm.perform()

        XCTAssertFalse(result)
        XCTAssertTrue(vm.processingState.isError)
        XCTAssertEqual(vm.errorMessage, error.localizedDescription)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(mockService.events, [.removePaymentMethod])
    }

    func testPerformClearsPreviousErrorSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            removePaymentMethod: { throw PaymentError.missingDataError(message: "error") }
        )
        sut = mockService

        let vm = PaymentActionViewModel.remove(swishMethod)
        let firstResult = await vm.perform()
        mockService.removePaymentMethodClosure = {}
        let secondResult = await vm.perform()

        XCTAssertFalse(firstResult)
        XCTAssertTrue(secondResult)
        XCTAssertEqual(vm.processingState, .success)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(mockService.events, [.removePaymentMethod, .removePaymentMethod])
    }

    // MARK: - remove

    func testRemoveSendsTheMethodsProviderSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(removePaymentMethod: {})
        sut = mockService

        let result = await PaymentActionViewModel.remove(swishMethod).perform()

        XCTAssertTrue(result)
        XCTAssertEqual(mockService.events, [.removePaymentMethod])
        XCTAssertEqual(mockService.removedProviders, [.swish])
    }

    func testRemoveTrustlyMethodRecordsProviderSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let result = await PaymentActionViewModel.remove(trustlyMethod).perform()

        XCTAssertTrue(result)
        XCTAssertEqual(mockService.removedProviders, [.trustly])
    }

    // MARK: - setDefault

    func testSetDefaultCallsSetDefaultPaymentMethodSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(setDefaultPaymentMethod: {})
        sut = mockService

        let vm = PaymentActionViewModel.setDefault(swishMethod)
        let result = await vm.perform()

        XCTAssertTrue(result)
        XCTAssertEqual(vm.processingState, .success)
        XCTAssertEqual(mockService.events, [.setDefaultPaymentMethod])
    }

    func testSetDefaultServiceErrorFailure() async {
        let error = PaymentError.missingDataError(message: "error")
        let mockService = MockPaymentData.createMockPaymentService(setDefaultPaymentMethod: { throw error })
        sut = mockService

        let vm = PaymentActionViewModel.setDefault(swishMethod)
        let result = await vm.perform()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.errorMessage, error.localizedDescription)
        XCTAssertEqual(mockService.events, [.setDefaultPaymentMethod])
    }
}
