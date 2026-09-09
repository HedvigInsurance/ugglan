@preconcurrency import XCTest
import hCore

@testable import Payment

@MainActor
final class PaymentsConfirmDefaultViewModelTests: XCTestCase {
    weak var sut: MockPaymentService?

    private let method = ConnectedPaymentMethod(
        status: .active,
        isDefault: false,
        method: .swish(phoneNumber: "0735328847")
    )

    override func tearDown() async throws {
        Dependencies.shared.remove(for: hPaymentClient.self)
        await delay(0.00001)

        XCTAssertNil(sut)
    }

    func testInitialStateNotLoadingWithoutError() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = PaymentsConfirmDefaultViewModel(method: method)

        XCTAssertEqual(vm.processingState, .success)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertTrue(mockService.events.isEmpty)
    }

    func testConfirmSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(setDefaultPaymentMethod: {})
        sut = mockService

        let vm = PaymentsConfirmDefaultViewModel(method: method)
        let result = await vm.confirm()

        XCTAssertTrue(result)
        XCTAssertEqual(vm.processingState, .success)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(mockService.events, [.setDefaultPaymentMethod])
    }

    func testConfirmLoadingWhileActionRuns() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = PaymentsConfirmDefaultViewModel(method: method)
        mockService.setDefaultPaymentMethodClosure = { [weak vm] in
            XCTAssertEqual(vm?.processingState, .loading)
            XCTAssertEqual(vm?.isLoading, true)
        }
        let result = await vm.confirm()

        XCTAssertTrue(result)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(mockService.events, [.setDefaultPaymentMethod])
    }

    func testConfirmServiceErrorFailure() async {
        let error = PaymentError.missingDataError(message: "error")
        let mockService = MockPaymentData.createMockPaymentService(setDefaultPaymentMethod: { throw error })
        sut = mockService

        let vm = PaymentsConfirmDefaultViewModel(method: method)
        let result = await vm.confirm()

        XCTAssertFalse(result)
        XCTAssertTrue(vm.processingState.isError)
        XCTAssertEqual(vm.errorMessage, error.localizedDescription)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(mockService.events, [.setDefaultPaymentMethod])
    }

    func testConfirmClearsPreviousErrorSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            setDefaultPaymentMethod: { throw PaymentError.missingDataError(message: "error") }
        )
        sut = mockService

        let vm = PaymentsConfirmDefaultViewModel(method: method)
        let firstResult = await vm.confirm()
        mockService.setDefaultPaymentMethodClosure = {}
        let secondResult = await vm.confirm()

        XCTAssertFalse(firstResult)
        XCTAssertTrue(secondResult)
        XCTAssertEqual(vm.processingState, .success)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(mockService.events, [.setDefaultPaymentMethod, .setDefaultPaymentMethod])
    }
}
