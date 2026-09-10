@preconcurrency import XCTest
import hCore

@testable import Payment

@MainActor
final class SwishPayinConsentViewModelTests: XCTestCase {
    weak var sut: MockPaymentService?

    private let phoneNumber = "0735328847"

    override func tearDown() async throws {
        Dependencies.shared.remove(for: hPaymentClient.self)
        await delay(0.00001)

        XCTAssertNil(sut)
    }

    private func makeViewModel(
        orderId: String? = "order-1",
        url: String? = "https://example.com/setup",
        state: SwishConsentState = .waiting,
        pollTimeout: TimeInterval = 1
    ) -> SwishPayinConsentViewModel {
        SwishPayinConsentViewModel(
            phoneNumber: phoneNumber,
            orderId: orderId,
            url: url,
            state: state,
            pollInterval: 0.001,
            pollTimeout: pollTimeout
        )
    }

    // MARK: - qrImage

    func testQRImageGeneratedFromUrlSuccess() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel(url: "https://example.com/setup")

        XCTAssertNotNil(vm.qrImage)
        XCTAssertEqual(vm.state, .waiting)
        XCTAssertFalse(vm.isRetrying)
    }

    func testQRImageNilWithoutUrl() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel(url: nil)

        XCTAssertNil(vm.qrImage)
    }

    // MARK: - pollUntilSettled

    func testPollUntilSettledMissingOrderIdFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .active })
        sut = mockService

        let vm = makeViewModel(orderId: nil)
        let result = await vm.pollUntilSettled()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.state, .waiting)
        XCTAssertTrue(mockService.events.isEmpty)
    }

    func testPollUntilSettledAlreadyFailedStateFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .active })
        sut = mockService

        let vm = makeViewModel(state: .failed(error: "earlier failure"))
        let result = await vm.pollUntilSettled()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.state, .failed(error: "earlier failure"))
        XCTAssertTrue(mockService.events.isEmpty)
    }

    func testPollUntilSettledActiveStatusSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .active })
        sut = mockService

        let vm = makeViewModel()
        let result = await vm.pollUntilSettled()

        XCTAssertTrue(result)
        XCTAssertEqual(vm.state, .waiting)
        XCTAssertEqual(mockService.events, [.getPaymentSetupStatus])
    }

    func testPollUntilSettledFailedStatusFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .failed })
        sut = mockService

        let vm = makeViewModel()
        let result = await vm.pollUntilSettled()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.state, .failed(error: nil))
        XCTAssertEqual(mockService.events, [.getPaymentSetupStatus])
    }

    func testPollUntilSettledServiceErrorFailure() async {
        let error = PaymentError.missingDataError(message: "error")
        let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { throw error })
        sut = mockService

        let vm = makeViewModel()
        let result = await vm.pollUntilSettled()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.state, .failed(error: error.localizedDescription))
        XCTAssertEqual(mockService.events, [.getPaymentSetupStatus])
    }

    func testPollUntilSettledPendingThenActiveSuccess() async {
        var statuses: [PaymentSetupResult.PaymentSetupStatus] = [.pending, .unknown, .active]
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentSetupStatus: { statuses.isEmpty ? .active : statuses.removeFirst() }
        )
        sut = mockService

        let vm = makeViewModel()
        let result = await vm.pollUntilSettled()

        XCTAssertTrue(result)
        XCTAssertEqual(vm.state, .waiting)
        XCTAssertEqual(
            mockService.events,
            [.getPaymentSetupStatus, .getPaymentSetupStatus, .getPaymentSetupStatus]
        )
    }

    func testPollUntilSettledTimeoutFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .pending })
        sut = mockService

        let vm = makeViewModel(pollTimeout: 0.02)
        let result = await vm.pollUntilSettled()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.state, .failed(error: nil))
        XCTAssertFalse(mockService.events.isEmpty)
        XCTAssertTrue(mockService.events.allSatisfy { $0 == .getPaymentSetupStatus })
    }

    // MARK: - tryAgain

    func testTryAgainActiveResultSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = makeViewModel(state: .failed(error: nil))
        let result = await vm.tryAgain()

        XCTAssertTrue(result)
        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .waiting)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
        XCTAssertEqual(mockService.lastSetupType?.phoneNumber, phoneNumber)
        guard case .swishPayin? = mockService.lastSetupType else {
            XCTFail("Expected a Swish payin setup")
            return
        }
    }

    func testTryAgainRetryingWhileSetupRuns() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel(state: .failed(error: "earlier failure"))
        mockService.fetchSetupPaymentMethod = { [weak vm] in
            XCTAssertEqual(vm?.isRetrying, true)
            XCTAssertEqual(vm?.state, .waiting)
            return .init(status: .active, orderId: nil, url: nil, errorMessage: nil)
        }
        let result = await vm.tryAgain()

        XCTAssertTrue(result)
        XCTAssertFalse(vm.isRetrying)
    }

    func testTryAgainUpdatesQRImageFromResultUrlSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .active, orderId: nil, url: "https://example.com/retry", errorMessage: nil)
            }
        )
        sut = mockService

        let vm = makeViewModel(url: nil, state: .failed(error: nil))
        XCTAssertNil(vm.qrImage)
        _ = await vm.tryAgain()

        XCTAssertNotNil(vm.qrImage)
    }

    func testTryAgainFailedResultFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .failed, orderId: nil, url: nil, errorMessage: "could not connect")
            }
        )
        sut = mockService

        let vm = makeViewModel(state: .failed(error: nil))
        let result = await vm.tryAgain()

        XCTAssertFalse(result)
        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .failed(error: "could not connect"))
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    func testTryAgainFailedResultWithoutMessageFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .failed, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = makeViewModel(state: .failed(error: "earlier failure"))
        let result = await vm.tryAgain()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.state, .failed(error: nil))
    }

    func testTryAgainPendingResultWithErrorMessageFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(
                    status: .pending,
                    orderId: "order-2",
                    url: "https://example.com/setup",
                    errorMessage: "number not connected to Swish"
                )
            },
            fetchPaymentSetupStatus: { .active }
        )
        sut = mockService

        let vm = makeViewModel(state: .failed(error: nil))
        let result = await vm.tryAgain()

        XCTAssertFalse(result)
        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .failed(error: "number not connected to Swish"))
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    func testTryAgainServiceErrorFailure() async {
        let error = PaymentError.missingDataError(message: "error")
        let mockService = MockPaymentData.createMockPaymentService(fetchSetupPaymentMethod: { throw error })
        sut = mockService

        let vm = makeViewModel(state: .failed(error: nil))
        let result = await vm.tryAgain()

        XCTAssertFalse(result)
        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .failed(error: error.localizedDescription))
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    func testTryAgainPendingResultPollsUntilActiveSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .pending, orderId: "order-2", url: "https://example.com/setup", errorMessage: nil)
            },
            fetchPaymentSetupStatus: { .active }
        )
        sut = mockService

        let vm = makeViewModel(orderId: nil, state: .failed(error: nil))
        let result = await vm.tryAgain()

        XCTAssertTrue(result)
        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .waiting)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod, .getPaymentSetupStatus])
    }

    func testTryAgainPendingResultPollsUntilFailedFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .pending, orderId: "order-2", url: "https://example.com/setup", errorMessage: nil)
            },
            fetchPaymentSetupStatus: { .failed }
        )
        sut = mockService

        let vm = makeViewModel(state: .failed(error: nil))
        let result = await vm.tryAgain()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.state, .failed(error: nil))
        XCTAssertEqual(mockService.events, [.setupPaymentMethod, .getPaymentSetupStatus])
    }

    func testTryAgainPendingResultWithoutOrderIdFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .pending, orderId: nil, url: nil, errorMessage: nil) },
            fetchPaymentSetupStatus: { .active }
        )
        sut = mockService

        let vm = makeViewModel(state: .failed(error: nil))
        let result = await vm.tryAgain()

        XCTAssertFalse(result)
        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .waiting)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }
}
