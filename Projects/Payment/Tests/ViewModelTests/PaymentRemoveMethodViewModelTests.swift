@preconcurrency import XCTest
import hCore

@testable import Payment

@MainActor
final class PaymentRemoveMethodViewModelTests: XCTestCase {
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

    func testRemoveSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(removePaymentMethod: {})
        sut = mockService

        let vm = PaymentRemoveMethodViewModel(method: swishMethod)
        let result = await vm.remove()

        XCTAssertTrue(result)
        XCTAssertEqual(vm.processingState, .success)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(mockService.events, [.removePaymentMethod])
        XCTAssertEqual(mockService.removedProviders, [.swish])
    }

    func testRemoveTrustlyMethodRecordsProviderSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = PaymentRemoveMethodViewModel(method: trustlyMethod)
        let result = await vm.remove()

        XCTAssertTrue(result)
        XCTAssertEqual(mockService.removedProviders, [.trustly])
    }

    func testRemoveLoadingWhileActionRuns() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = PaymentRemoveMethodViewModel(method: swishMethod)
        mockService.removePaymentMethodClosure = { [weak vm] in
            XCTAssertEqual(vm?.processingState, .loading)
            XCTAssertEqual(vm?.isLoading, true)
        }
        let result = await vm.remove()

        XCTAssertTrue(result)
        XCTAssertFalse(vm.isLoading)
    }

    func testRemoveServiceErrorFailure() async {
        let error = PaymentError.missingDataError(message: "error")
        let mockService = MockPaymentData.createMockPaymentService(removePaymentMethod: { throw error })
        sut = mockService

        let vm = PaymentRemoveMethodViewModel(method: swishMethod)
        let result = await vm.remove()

        XCTAssertFalse(result)
        XCTAssertTrue(vm.processingState.isError)
        XCTAssertEqual(vm.errorMessage, error.localizedDescription)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(mockService.events, [.removePaymentMethod])
        XCTAssertEqual(mockService.removedProviders, [.swish])
    }

    func testRemoveClearsPreviousErrorSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            removePaymentMethod: { throw PaymentError.missingDataError(message: "error") }
        )
        sut = mockService

        let vm = PaymentRemoveMethodViewModel(method: swishMethod)
        let firstResult = await vm.remove()
        mockService.removePaymentMethodClosure = {}
        let secondResult = await vm.remove()

        XCTAssertFalse(firstResult)
        XCTAssertTrue(secondResult)
        XCTAssertEqual(vm.processingState, .success)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(mockService.events, [.removePaymentMethod, .removePaymentMethod])
        XCTAssertEqual(mockService.removedProviders, [.swish, .swish])
    }
}
