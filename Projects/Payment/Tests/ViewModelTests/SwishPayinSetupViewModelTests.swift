@preconcurrency import XCTest
import hCore

@testable import Payment

@MainActor
final class SwishPayinSetupViewModelTests: XCTestCase {
    weak var sut: MockPaymentService?

    override func tearDown() async throws {
        Dependencies.shared.remove(for: hPaymentClient.self)
        await delay(0.00001)

        XCTAssertNil(sut)
    }

    // MARK: - prefill

    func testPrefillPhoneNumberFillsEmptyFieldSuccess() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "0735328847")

        XCTAssertEqual(vm.phoneNumber, "0735328847")
        XCTAssertTrue(mockService.events.isEmpty)
    }

    func testPrefillNilPhoneNumberKeepsFieldEmpty() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: nil)

        XCTAssertEqual(vm.phoneNumber, "")
    }

    func testPrefillEmptyPhoneNumberKeepsFieldEmpty() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "")

        XCTAssertEqual(vm.phoneNumber, "")
    }

    func testPrefillPhoneNumberKeepsTypedNumber() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.phoneNumber = "0701231231"
        vm.prefill(phoneNumber: "0735328847")

        XCTAssertEqual(vm.phoneNumber, "0701231231")
    }

    func testPrefillPhoneNumberTwiceKeepsFirstNumber() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "0735328847")
        vm.prefill(phoneNumber: "0701231231")

        XCTAssertEqual(vm.phoneNumber, "0735328847")
    }

    func testPrefillPhoneNumberAfterClearingFieldFillsAgain() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "0735328847")
        vm.phoneNumber = ""
        vm.prefill(phoneNumber: "0701231231")

        XCTAssertEqual(vm.phoneNumber, "0701231231")
    }

    // MARK: - save

    func testSavePrefilledPhoneNumberSuccess() async {
        let expectedResult = PaymentSetupResult(status: .active, orderId: nil, url: nil, errorMessage: nil)
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { expectedResult }
        )
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "0735328847")
        let result = await vm.save()

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
        XCTAssertEqual(mockService.lastSetupType?.phoneNumber, "0735328847")
        XCTAssertNil(vm.errorMessage)
        XCTAssertNil(vm.phoneNumberError)
        XCTAssertFalse(vm.isLoading)
    }

    func testSaveTypedPhoneNumberOverPrefilledSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "0735328847")
        vm.phoneNumber = "0701231231"
        _ = await vm.save()

        XCTAssertEqual(mockService.lastSetupType?.phoneNumber, "0701231231")
    }

    func testSavePendingResultSuccess() async {
        let expectedResult = PaymentSetupResult(
            status: .pending,
            orderId: "order-1",
            url: "https://example.com/setup",
            errorMessage: nil
        )
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { expectedResult }
        )
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "0735328847")
        let result = await vm.save()

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(vm.unmaskedPhoneNumber, "0735328847")
        XCTAssertNil(vm.errorMessage)
    }

    func testSaveInvalidPhoneNumberFailure() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "070")
        let result = await vm.save()

        XCTAssertNil(result)
        XCTAssertEqual(vm.phoneNumberError, L10n.myInfoPhoneNumberMalformedError)
        XCTAssertEqual(vm.focusedField, .phoneNumber)
        XCTAssertTrue(mockService.events.isEmpty)
        XCTAssertNil(mockService.lastSetupType)
        XCTAssertFalse(vm.isLoading)
    }

    func testSaveEmptyPhoneNumberFailure() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: nil)
        let result = await vm.save()

        XCTAssertNil(result)
        XCTAssertEqual(vm.phoneNumberError, L10n.myInfoPhoneNumberMalformedError)
        XCTAssertTrue(mockService.events.isEmpty)
    }

    func testSaveFailedStatusFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .failed, orderId: nil, url: nil, errorMessage: "could not connect")
            }
        )
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "0735328847")
        let result = await vm.save()

        XCTAssertNil(result)
        XCTAssertEqual(vm.errorMessage, "could not connect")
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
        XCTAssertFalse(vm.isLoading)
    }

    func testSaveFailedStatusWithoutMessageFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .failed, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "0735328847")
        let result = await vm.save()

        XCTAssertNil(result)
        XCTAssertEqual(vm.errorMessage, L10n.General.errorBody)
    }

    func testSaveResultWithErrorMessageFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .pending, orderId: "order-1", url: nil, errorMessage: "number not connected to Swish")
            }
        )
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "0735328847")
        let result = await vm.save()

        XCTAssertNil(result)
        XCTAssertEqual(vm.errorMessage, "number not connected to Swish")
    }

    func testSaveServiceErrorFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { throw PaymentError.missingDataError(message: "error") }
        )
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "0735328847")
        let result = await vm.save()

        XCTAssertNil(result)
        XCTAssertEqual(vm.errorMessage, PaymentError.missingDataError(message: "error").localizedDescription)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
        XCTAssertEqual(mockService.lastSetupType?.phoneNumber, "0735328847")
        XCTAssertFalse(vm.isLoading)
    }

    func testSaveClearsPreviousErrorSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = SwishPayinSetupViewModel()
        vm.prefill(phoneNumber: "0735328847")
        vm.errorMessage = "previous failure"
        vm.phoneNumberError = "previous field error"
        let result = await vm.save()

        XCTAssertEqual(result?.status, .active)
        XCTAssertNil(vm.errorMessage)
        XCTAssertNil(vm.phoneNumberError)
    }
}
