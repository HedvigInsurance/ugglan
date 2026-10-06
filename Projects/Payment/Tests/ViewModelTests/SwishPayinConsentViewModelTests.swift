@preconcurrency import XCTest
import hCore

@testable import Payment

@MainActor
final class SwishPayinConsentViewModelTests: XCTestCase {
    weak var sut: MockPaymentService?

    override func tearDown() async throws {
        Dependencies.shared.remove(for: hPaymentClient.self)
        await delay(0.00001)

        XCTAssertNil(sut)
    }

    private func makeViewModel(
        orderId: String? = "order-1",
        url: String? = PaymentTestURL.setup,
        state: SwishConsentState = .waiting
    ) -> SwishPayinConsentViewModel {
        SwishPayinConsentViewModel(
            orderId: orderId,
            url: url,
            state: state,
            pollInterval: 0.001
        )
    }

    // MARK: - qrImage

    func testQRImageGeneratedFromUrlSuccess() {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel(url: PaymentTestURL.setup)

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

    // MARK: - connect

    func testConnectFetchesAnOrderThenPollsSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .pending, orderId: "order-1", url: PaymentTestURL.setup, errorMessage: nil)
            },
            fetchPaymentSetupStatus: { .active }
        )
        sut = mockService

        let vm = makeViewModel(orderId: nil, url: nil, state: .loading)
        let result = await vm.connect()

        XCTAssertTrue(result)
        XCTAssertEqual(vm.state, .waiting)
        XCTAssertNotNil(vm.qrImage)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod, .getPaymentSetupStatus])
    }

    /// The first order is fetched inside the run that then polls it, so it must not re-arm the
    /// view's task.
    func testConnectDoesNotRearmPollingForTheFirstOrder() async {
        let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .active })
        sut = mockService

        let vm = makeViewModel(orderId: nil, url: nil, state: .loading)
        _ = await vm.connect()

        XCTAssertEqual(vm.pollAttempt, 0)
    }

    func testConnectAlreadyActiveSetupSkipsPollingSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = makeViewModel(orderId: nil, url: nil, state: .loading)
        let result = await vm.connect()

        XCTAssertTrue(result)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    func testConnectFailedSetupFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .failed, orderId: nil, url: nil, errorMessage: "number not connected to Swish")
            }
        )
        sut = mockService

        let vm = makeViewModel(orderId: nil, url: nil, state: .loading)
        let result = await vm.connect()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.state, .failed(error: "number not connected to Swish"))
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    func testConnectServiceErrorFailure() async {
        let error = PaymentError.missingDataError(message: "error")
        let mockService = MockPaymentData.createMockPaymentService(fetchSetupPaymentMethod: { throw error })
        sut = mockService

        let vm = makeViewModel(orderId: nil, url: nil, state: .loading)
        let result = await vm.connect()

        XCTAssertFalse(result)
        XCTAssertEqual(vm.state, .failed(error: error.localizedDescription))
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    /// A retry fetched its own order, so the pass it re-arms goes straight to polling.
    func testConnectWithAnExistingOrderSkipsSetup() async {
        let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .active })
        sut = mockService

        let vm = makeViewModel(state: .waiting)
        let result = await vm.connect()

        XCTAssertTrue(result)
        XCTAssertEqual(mockService.events, [.getPaymentSetupStatus])
    }

    // MARK: - openSwish

    func testOpenSwishMovesToApproving() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel(url: nil)

        await vm.openSwish()

        XCTAssertEqual(vm.state, .approving)
        XCTAssertTrue(mockService.events.isEmpty)
    }

    /// Leaving for Swish must not stop the wait it was meant to start.
    func testPollUntilSettledKeepsGoingWhileApproving() async {
        var statuses: [PaymentSetupResult.PaymentSetupStatus] = [.pending, .active]
        let mockService = MockPaymentData.createMockPaymentService(
            fetchPaymentSetupStatus: { statuses.isEmpty ? .active : statuses.removeFirst() }
        )
        sut = mockService

        let vm = makeViewModel(state: .approving)
        let result = await vm.pollUntilSettled()

        XCTAssertTrue(result)
        XCTAssertEqual(vm.state, .approving)
        XCTAssertEqual(mockService.events, [.getPaymentSetupStatus, .getPaymentSetupStatus])
    }

    func testRequestNewOrderBringsBackTheCode() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .pending, orderId: "order-2", url: PaymentTestURL.retry, errorMessage: nil)
            }
        )
        sut = mockService

        let vm = makeViewModel(url: nil)
        await vm.openSwish()
        XCTAssertEqual(vm.state, .approving)

        await vm.requestNewOrder()

        XCTAssertEqual(vm.state, .waiting)
        XCTAssertNotNil(vm.qrImage)
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

    /// A pending order no longer runs out of time, so the wait ends only when the screen goes
    /// away — and it leaves the state alone on the way out, rather than reporting a failure.
    func testPollUntilSettledPendingRunsUntilCancelled() async {
        let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .pending })
        sut = mockService

        let vm = makeViewModel()
        let poll = Task { await vm.pollUntilSettled() }
        await delay(0.02)
        poll.cancel()
        let result = await poll.value

        XCTAssertFalse(result)
        XCTAssertEqual(vm.state, .waiting)
        XCTAssertFalse(mockService.events.isEmpty)
        XCTAssertTrue(mockService.events.allSatisfy { $0 == .getPaymentSetupStatus })
    }

    func testRequestNewOrderActiveResultArmsPolling() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = makeViewModel(state: .failed(error: nil))
        await vm.requestNewOrder()

        XCTAssertEqual(vm.pollAttempt, 1)
        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .waiting)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
        guard case .swishPayin? = mockService.lastSetupType else {
            XCTFail("Expected a Swish payin setup")
            return
        }
    }

    func testRequestNewOrderStaysFailedWhileSetupRuns() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel(state: .failed(error: "earlier failure"))
        mockService.fetchSetupPaymentMethod = { [weak vm] in
            XCTAssertEqual(vm?.isRetrying, true)
            XCTAssertEqual(vm?.state, .failed(error: "earlier failure"))
            return .init(status: .active, orderId: nil, url: nil, errorMessage: nil)
        }
        await vm.requestNewOrder()

        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .waiting)
    }

    func testRequestNewOrderUpdatesQRImageBeforeLeavingFailed() async {
        let mockService = MockPaymentData.createMockPaymentService()
        sut = mockService

        let vm = makeViewModel(url: nil, state: .failed(error: nil))
        mockService.fetchSetupPaymentMethod = { [weak vm] in
            XCTAssertNil(vm?.qrImage, "the retry's code cannot exist before the call returns")
            return .init(status: .pending, orderId: "order-2", url: PaymentTestURL.retry, errorMessage: nil)
        }
        await vm.requestNewOrder()

        XCTAssertNotNil(vm.qrImage)
        XCTAssertEqual(vm.state, .waiting)
    }

    func testRequestNewOrderUpdatesQRImageFromResultUrlSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .active, orderId: nil, url: PaymentTestURL.retry, errorMessage: nil)
            }
        )
        sut = mockService

        let vm = makeViewModel(url: nil, state: .failed(error: nil))
        XCTAssertNil(vm.qrImage)
        await vm.requestNewOrder()

        XCTAssertNotNil(vm.qrImage)
    }

    func testRequestNewOrderFailedResultDoesNotArmPolling() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .failed, orderId: nil, url: nil, errorMessage: "could not connect")
            }
        )
        sut = mockService

        let vm = makeViewModel(state: .failed(error: nil))
        await vm.requestNewOrder()

        XCTAssertEqual(vm.pollAttempt, 0)
        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .failed(error: "could not connect"))
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    func testRequestNewOrderFailedResultWithoutMessageFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .failed, orderId: nil, url: nil, errorMessage: nil) }
        )
        sut = mockService

        let vm = makeViewModel(state: .failed(error: "earlier failure"))
        await vm.requestNewOrder()

        XCTAssertEqual(vm.pollAttempt, 0)
        XCTAssertEqual(vm.state, .failed(error: nil))
    }

    func testRequestNewOrderPendingResultWithErrorMessageFailure() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(
                    status: .pending,
                    orderId: "order-2",
                    url: PaymentTestURL.setup,
                    errorMessage: "number not connected to Swish"
                )
            },
            fetchPaymentSetupStatus: { .active }
        )
        sut = mockService

        let vm = makeViewModel(state: .failed(error: nil))
        await vm.requestNewOrder()

        XCTAssertEqual(vm.pollAttempt, 0)
        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .failed(error: "number not connected to Swish"))
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    func testRequestNewOrderServiceErrorFailure() async {
        let error = PaymentError.missingDataError(message: "error")
        let mockService = MockPaymentData.createMockPaymentService(fetchSetupPaymentMethod: { throw error })
        sut = mockService

        let vm = makeViewModel(state: .failed(error: nil))
        await vm.requestNewOrder()

        XCTAssertEqual(vm.pollAttempt, 0)
        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .failed(error: error.localizedDescription))
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }

    func testRequestNewOrderHandsOffToPollingSuccess() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: {
                .init(status: .pending, orderId: "order-2", url: PaymentTestURL.setup, errorMessage: nil)
            },
            fetchPaymentSetupStatus: { .active }
        )
        sut = mockService

        let vm = makeViewModel(orderId: nil, state: .failed(error: nil))
        await vm.requestNewOrder()

        XCTAssertEqual(vm.pollAttempt, 1)
        XCTAssertEqual(vm.state, .waiting)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])

        let result = await vm.pollUntilSettled()

        XCTAssertTrue(result)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod, .getPaymentSetupStatus])
    }

    func testRequestNewOrderWithoutOrderIdPollsNothing() async {
        let mockService = MockPaymentData.createMockPaymentService(
            fetchSetupPaymentMethod: { .init(status: .pending, orderId: nil, url: nil, errorMessage: nil) },
            fetchPaymentSetupStatus: { .active }
        )
        sut = mockService

        let vm = makeViewModel(state: .failed(error: nil))
        await vm.requestNewOrder()

        XCTAssertEqual(vm.pollAttempt, 1)
        XCTAssertFalse(vm.isRetrying)
        XCTAssertEqual(vm.state, .waiting)

        let result = await vm.pollUntilSettled()

        XCTAssertFalse(result)
        XCTAssertEqual(mockService.events, [.setupPaymentMethod])
    }
}
