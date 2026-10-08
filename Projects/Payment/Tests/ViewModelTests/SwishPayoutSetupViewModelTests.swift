@preconcurrency import XCTest
import hCore

@testable import Payment

@MainActor
final class SwishPayoutSetupViewModelTests: XCTestCase {
    weak var sut: MockPaymentService?

    private static let validPhoneNumber = "0735328847"

    override func tearDown() async throws {
        Dependencies.shared.remove(for: hPaymentClient.self)
        await delay(0.00001)

        XCTAssertNil(sut)
    }

    private func makeViewModel(
        phoneNumber: String = SwishPayoutSetupViewModelTests.validPhoneNumber,
        hasConfirmedNumber: Bool = true
    ) -> SwishPayoutSetupViewModel {
        let vm = SwishPayoutSetupViewModel()
        vm.phoneNumber = phoneNumber
        vm.hasConfirmedNumber = hasConfirmedNumber
        return vm
    }

    // `PaymentMethodSetupType` is not Equatable, so the number has to be unwrapped to be compared.
    private func swishPayoutPhoneNumber(from type: PaymentMethodSetupType?) -> String? {
        guard case .swishPayout(let phoneNumber)? = type else { return nil }
        return phoneNumber
    }

    // MARK: - isSaveDisabled

    func testInitialStateSaveDisabledUntilNumberIsConfirmed() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = SwishPayoutSetupViewModel()

        XCTAssertTrue(vm.isSaveDisabled)
        XCTAssertFalse(vm.hasConfirmedNumber)
        XCTAssertEqual(vm.phoneNumber, "")
        XCTAssertNil(vm.phoneNumberError)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(mockService.events.isEmpty)
    }

    func testConfirmingTheNumberEnablesSaving() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = SwishPayoutSetupViewModel()
        vm.hasConfirmedNumber = true

        XCTAssertFalse(vm.isSaveDisabled)
    }

    func testRemovingTheConfirmationDisablesSavingAgain() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel()
        XCTAssertFalse(vm.isSaveDisabled)

        vm.hasConfirmedNumber = false

        XCTAssertTrue(vm.isSaveDisabled)
    }

    // The phone number is not part of the gate — an empty form with a ticked box still offers Save
    // and fails on validation instead, so the member is told what is wrong.
    func testSaveEnabledWithoutAPhoneNumber() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel(phoneNumber: "")

        XCTAssertFalse(vm.isSaveDisabled)
    }

    // MARK: - save validation

    func testSaveEmptyPhoneNumberFailure() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel(phoneNumber: "")
        let result = await vm.save()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.phoneNumberError, L10n.myInfoPhoneNumberMalformedError)
        XCTAssertEqual(vm.focusedField, .phoneNumber)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
        XCTAssertTrue(mockService.events.isEmpty)
    }

    func testSaveTooShortPhoneNumberFailure() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel(phoneNumber: "12345")
        let result = await vm.save()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.phoneNumberError, L10n.myInfoPhoneNumberMalformedError)
        XCTAssertTrue(mockService.events.isEmpty)
    }

    func testSaveNonNumericPhoneNumberFailure() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel(phoneNumber: "073 532 88 47")
        let result = await vm.save()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.phoneNumberError, L10n.myInfoPhoneNumberMalformedError)
        XCTAssertTrue(mockService.events.isEmpty)
    }

    func testSaveClearsPreviousPhoneNumberErrorSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = makeViewModel(phoneNumber: "12345")
        let firstResult = await vm.save()
        vm.phoneNumber = Self.validPhoneNumber
        let secondResult = await vm.save()

        XCTAssertFalse(firstResult)
        XCTAssertTrue(secondResult)
        XCTAssertNil(vm.phoneNumberError)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    // MARK: - save

    func testSaveSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = makeViewModel()
        let result = await vm.save()

        XCTAssertTrue(result)
        XCTAssertNil(vm.errorMessage)
        XCTAssertNil(vm.phoneNumberError)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    func testSaveSendsTheUnmaskedPhoneNumberSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = makeViewModel(phoneNumber: "+46735328847")
        let result = await vm.save()

        XCTAssertTrue(result)
        XCTAssertEqual(swishPayoutPhoneNumber(from: mockService.lastSetupType), "+46735328847")
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    func testSaveSendsTheNumberExactlyOncePerAttempt() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = makeViewModel()
        _ = await vm.save()
        vm.phoneNumber = "+46735328847"
        _ = await vm.save()

        XCTAssertEqual(mockService.setupTypes.count, 2)
        XCTAssertEqual(swishPayoutPhoneNumber(from: mockService.setupTypes.first), Self.validPhoneNumber)
        XCTAssertEqual(swishPayoutPhoneNumber(from: mockService.lastSetupType), "+46735328847")
    }

    func testSaveLoadingWhileSetupRuns() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel()
        mockService.fetchSetupPaymentMethod = { [weak vm] in
            XCTAssertEqual(vm?.isLoading, true)
            return .init(status: .active, orderId: nil, url: nil, errorMessage: nil)
        }
        let result = await vm.save()

        XCTAssertTrue(result)
        XCTAssertFalse(vm.isLoading)
    }

    func testSaveResultErrorMessageFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .failed, orderId: nil, url: nil, errorMessage: "number not connected to Swish")
            }
        )
        sut = mockService

        let vm = makeViewModel()
        let result = await vm.save()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.errorMessage, "number not connected to Swish")
        XCTAssertNil(vm.phoneNumberError)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    // Only `errorMessage` decides the outcome — the status is not read — so a failed result that
    // carries no message still saves. Pinned as current behaviour, not as an endorsement.
    func testSaveFailedResultWithoutMessageSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .failed, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = makeViewModel()
        let result = await vm.save()

        XCTAssertTrue(result)
        XCTAssertNil(vm.errorMessage)
    }

    func testSaveServiceErrorFailure() async {
        let error = PaymentError.missingDataError(message: "error")
        let mockService = MockPaymentData.createMockPaymentService(fetchSetupPaymentMethod: { throw error })
        sut = mockService

        let vm = makeViewModel()
        let result = await vm.save()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.errorMessage, error.localizedDescription)
        XCTAssertNil(vm.phoneNumberError)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    func testSaveClearsPreviousErrorMessageSuccess() async {
        let error = PaymentError.missingDataError(message: "error")
        let mockService = MockPaymentData.createMockPaymentService(fetchSetupPaymentMethod: { throw error })
        sut = mockService

        let vm = makeViewModel()
        let firstResult = await vm.save()
        mockService.fetchSetupPaymentMethod = {
            .init(status: .active, orderId: nil, url: nil, errorMessage: nil)
        }
        let secondResult = await vm.save()

        XCTAssertFalse(firstResult)
        XCTAssertTrue(secondResult)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod, .setupPaymentMethod])
    }
}
