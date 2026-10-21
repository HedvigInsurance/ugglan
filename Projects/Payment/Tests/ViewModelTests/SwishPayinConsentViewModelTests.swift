import TestDependencies
import Testing
import hCore

@testable import Payment

extension PaymentDependencySuite {
    @MainActor
    final class SwishPayinConsentViewModelTests {
        private weak var sut: MockPaymentService?

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: hPaymentClient.self)
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive its dependency registration")
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

        @Test
        func qrImageGeneratedFromUrlSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = makeViewModel(url: PaymentTestURL.setup)

                #expect(vm.qrImage != nil)
                #expect(vm.state == .waiting)
                #expect(vm.isRetrying == false)
            }

            await expectServiceReleased()
        }

        @Test
        func qrImageNilWithoutUrl() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = makeViewModel(url: nil)

                #expect(vm.qrImage == nil)
            }

            await expectServiceReleased()
        }

        // MARK: - connect

        @Test
        func connectFetchesAnOrderThenPollsSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: {
                        .init(status: .pending, orderId: "order-1", url: PaymentTestURL.setup, errorMessage: nil)
                    },
                    fetchPaymentSetupStatus: { .active }
                )
                sut = mockService

                let vm = makeViewModel(orderId: nil, url: nil, state: .loading)
                let result = await vm.connect()

                #expect(result)
                #expect(vm.state == .waiting)
                #expect(vm.qrImage != nil)
                #expect(mockService.events == [.setupPaymentMethod, .getPaymentSetupStatus])
            }

            await expectServiceReleased()
        }

        /// The first order is fetched inside the run that then polls it, so it must not re-arm the view's task.
        @Test
        func connectDoesNotRearmPollingForTheFirstOrder() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .active })
                sut = mockService

                let vm = makeViewModel(orderId: nil, url: nil, state: .loading)
                _ = await vm.connect()

                #expect(vm.pollAttempt == 0)
            }

            await expectServiceReleased()
        }

        @Test
        func connectAlreadyActiveSetupSkipsPollingSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
                )
                sut = mockService

                let vm = makeViewModel(orderId: nil, url: nil, state: .loading)
                let result = await vm.connect()

                #expect(result)
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func connectFailedSetupFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: {
                        .init(status: .failed, orderId: nil, url: nil, errorMessage: "number not connected to Swish")
                    }
                )
                sut = mockService

                let vm = makeViewModel(orderId: nil, url: nil, state: .loading)
                let result = await vm.connect()

                #expect(result == false)
                #expect(vm.state == .failed(error: "number not connected to Swish"))
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func connectServiceErrorFailure() async {
            do {
                let error = PaymentError.missingDataError(message: "error")
                let mockService = MockPaymentData.createMockPaymentService(fetchSetupPaymentMethod: { throw error })
                sut = mockService

                let vm = makeViewModel(orderId: nil, url: nil, state: .loading)
                let result = await vm.connect()

                #expect(result == false)
                #expect(vm.state == .failed(error: error.localizedDescription))
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }

        /// A retry fetched its own order, so the pass it re-arms goes straight to polling.
        @Test
        func connectWithAnExistingOrderSkipsSetup() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .active })
                sut = mockService

                let vm = makeViewModel(state: .waiting)
                let result = await vm.connect()

                #expect(result)
                #expect(mockService.events == [.getPaymentSetupStatus])
            }

            await expectServiceReleased()
        }

        // MARK: - openSwish

        @Test
        func openSwishMovesToApproving() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = makeViewModel(url: nil)

                await vm.openSwish()

                #expect(vm.state == .approving)
                #expect(mockService.events.isEmpty)
            }

            await expectServiceReleased()
        }

        /// Leaving for Swish must not stop the wait it was meant to start.
        @Test
        func pollUntilSettledKeepsGoingWhileApproving() async {
            do {
                var statuses: [PaymentSetupResult.PaymentSetupStatus] = [.pending, .active]
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentSetupStatus: { statuses.isEmpty ? .active : statuses.removeFirst() }
                )
                sut = mockService

                let vm = makeViewModel(state: .approving)
                let result = await vm.pollUntilSettled()

                #expect(result)
                #expect(vm.state == .approving)
                #expect(mockService.events == [.getPaymentSetupStatus, .getPaymentSetupStatus])
            }

            await expectServiceReleased()
        }

        @Test
        func requestNewOrderBringsBackTheCode() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: {
                        .init(status: .pending, orderId: "order-2", url: PaymentTestURL.retry, errorMessage: nil)
                    }
                )
                sut = mockService

                let vm = makeViewModel(url: nil)
                await vm.openSwish()
                #expect(vm.state == .approving)

                await vm.requestNewOrder()

                #expect(vm.state == .waiting)
                #expect(vm.qrImage != nil)
            }

            await expectServiceReleased()
        }

        // MARK: - pollUntilSettled

        @Test
        func pollUntilSettledMissingOrderIdFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .active })
                sut = mockService

                let vm = makeViewModel(orderId: nil)
                let result = await vm.pollUntilSettled()

                #expect(result == false)
                #expect(vm.state == .waiting)
                #expect(mockService.events.isEmpty)
            }

            await expectServiceReleased()
        }

        @Test
        func pollUntilSettledAlreadyFailedStateFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .active })
                sut = mockService

                let vm = makeViewModel(state: .failed(error: "earlier failure"))
                let result = await vm.pollUntilSettled()

                #expect(result == false)
                #expect(vm.state == .failed(error: "earlier failure"))
                #expect(mockService.events.isEmpty)
            }

            await expectServiceReleased()
        }

        @Test
        func pollUntilSettledActiveStatusSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .active })
                sut = mockService

                let vm = makeViewModel()
                let result = await vm.pollUntilSettled()

                #expect(result)
                #expect(vm.state == .waiting)
                #expect(mockService.events == [.getPaymentSetupStatus])
            }

            await expectServiceReleased()
        }

        @Test
        func pollUntilSettledFailedStatusFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .failed })
                sut = mockService

                let vm = makeViewModel()
                let result = await vm.pollUntilSettled()

                #expect(result == false)
                #expect(vm.state == .failed(error: nil))
                #expect(mockService.events == [.getPaymentSetupStatus])
            }

            await expectServiceReleased()
        }

        @Test
        func pollUntilSettledServiceErrorFailure() async {
            do {
                let error = PaymentError.missingDataError(message: "error")
                let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { throw error })
                sut = mockService

                let vm = makeViewModel()
                let result = await vm.pollUntilSettled()

                #expect(result == false)
                #expect(vm.state == .failed(error: error.localizedDescription))
                #expect(mockService.events == [.getPaymentSetupStatus])
            }

            await expectServiceReleased()
        }

        @Test
        func pollUntilSettledPendingThenActiveSuccess() async {
            do {
                var statuses: [PaymentSetupResult.PaymentSetupStatus] = [.pending, .unknown, .active]
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentSetupStatus: { statuses.isEmpty ? .active : statuses.removeFirst() }
                )
                sut = mockService

                let vm = makeViewModel()
                let result = await vm.pollUntilSettled()

                #expect(result)
                #expect(vm.state == .waiting)
                #expect(mockService.events == [.getPaymentSetupStatus, .getPaymentSetupStatus, .getPaymentSetupStatus])
            }

            await expectServiceReleased()
        }

        /// A pending order no longer runs out of time, so the wait ends only when the screen goes away — and it
        /// leaves the state alone on the way out, rather than reporting a failure.
        @Test
        func pollUntilSettledPendingRunsUntilCancelled() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(fetchPaymentSetupStatus: { .pending })
                sut = mockService

                let vm = makeViewModel()
                let poll = Task { await vm.pollUntilSettled() }
                await waitUntil(description: "first poll") { !mockService.events.isEmpty }
                poll.cancel()
                let result = await poll.value

                #expect(result == false)
                #expect(vm.state == .waiting)
                #expect(mockService.events.isEmpty == false)
                #expect(mockService.events.allSatisfy { $0 == .getPaymentSetupStatus })
            }

            await expectServiceReleased()
        }

        @Test
        func requestNewOrderActiveResultArmsPolling() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
                )
                sut = mockService

                let vm = makeViewModel(state: .failed(error: nil))
                await vm.requestNewOrder()

                #expect(vm.pollAttempt == 1)
                #expect(vm.isRetrying == false)
                #expect(vm.state == .waiting)
                #expect(mockService.events == [.setupPaymentMethod])
                // Not an early-returning guard: that would skip the release check below.
                let isSwishPayin = if case .swishPayin? = mockService.lastSetupType { true } else { false }
                #expect(isSwishPayin, "Expected a Swish payin setup")
            }

            await expectServiceReleased()
        }

        @Test
        func requestNewOrderStaysFailedWhileSetupRuns() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = makeViewModel(state: .failed(error: "earlier failure"))
                await confirmation("the setup call runs") { setupRan in
                    mockService.fetchSetupPaymentMethod = { [weak vm] in
                        setupRan()
                        #expect(vm?.isRetrying == true)
                        #expect(vm?.state == .failed(error: "earlier failure"))
                        return .init(status: .active, orderId: nil, url: nil, errorMessage: nil)
                    }
                    await vm.requestNewOrder()

                    #expect(vm.isRetrying == false)
                    #expect(vm.state == .waiting)
                }
            }

            await expectServiceReleased()
        }

        @Test
        func requestNewOrderUpdatesQRImageBeforeLeavingFailed() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = makeViewModel(url: nil, state: .failed(error: nil))
                await confirmation("the setup call runs") { setupRan in
                    mockService.fetchSetupPaymentMethod = { [weak vm] in
                        setupRan()
                        #expect(vm?.qrImage == nil, "the retry's code cannot exist before the call returns")
                        return .init(
                            status: .pending,
                            orderId: "order-2",
                            url: PaymentTestURL.retry,
                            errorMessage: nil
                        )
                    }
                    await vm.requestNewOrder()

                    #expect(vm.qrImage != nil)
                    #expect(vm.state == .waiting)
                }
            }

            await expectServiceReleased()
        }

        @Test
        func requestNewOrderUpdatesQRImageFromResultUrlSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: {
                        .init(status: .active, orderId: nil, url: PaymentTestURL.retry, errorMessage: nil)
                    }
                )
                sut = mockService

                let vm = makeViewModel(url: nil, state: .failed(error: nil))
                #expect(vm.qrImage == nil)
                await vm.requestNewOrder()

                #expect(vm.qrImage != nil)
            }

            await expectServiceReleased()
        }

        @Test
        func requestNewOrderFailedResultDoesNotArmPolling() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: {
                        .init(status: .failed, orderId: nil, url: nil, errorMessage: "could not connect")
                    }
                )
                sut = mockService

                let vm = makeViewModel(state: .failed(error: nil))
                await vm.requestNewOrder()

                #expect(vm.pollAttempt == 0)
                #expect(vm.isRetrying == false)
                #expect(vm.state == .failed(error: "could not connect"))
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func requestNewOrderFailedResultWithoutMessageFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: { .init(status: .failed, orderId: nil, url: nil, errorMessage: nil) }
                )
                sut = mockService

                let vm = makeViewModel(state: .failed(error: "earlier failure"))
                await vm.requestNewOrder()

                #expect(vm.pollAttempt == 0)
                #expect(vm.state == .failed(error: nil))
            }

            await expectServiceReleased()
        }

        @Test
        func requestNewOrderPendingResultWithErrorMessageFailure() async {
            do {
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

                #expect(vm.pollAttempt == 0)
                #expect(vm.isRetrying == false)
                #expect(vm.state == .failed(error: "number not connected to Swish"))
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func requestNewOrderServiceErrorFailure() async {
            do {
                let error = PaymentError.missingDataError(message: "error")
                let mockService = MockPaymentData.createMockPaymentService(fetchSetupPaymentMethod: { throw error })
                sut = mockService

                let vm = makeViewModel(state: .failed(error: nil))
                await vm.requestNewOrder()

                #expect(vm.pollAttempt == 0)
                #expect(vm.isRetrying == false)
                #expect(vm.state == .failed(error: error.localizedDescription))
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func requestNewOrderHandsOffToPollingSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: {
                        .init(status: .pending, orderId: "order-2", url: PaymentTestURL.setup, errorMessage: nil)
                    },
                    fetchPaymentSetupStatus: { .active }
                )
                sut = mockService

                let vm = makeViewModel(orderId: nil, state: .failed(error: nil))
                await vm.requestNewOrder()

                #expect(vm.pollAttempt == 1)
                #expect(vm.state == .waiting)
                #expect(mockService.events == [.setupPaymentMethod])

                let result = await vm.pollUntilSettled()

                #expect(result)
                #expect(mockService.events == [.setupPaymentMethod, .getPaymentSetupStatus])
            }

            await expectServiceReleased()
        }

        @Test
        func requestNewOrderWithoutOrderIdPollsNothing() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: { .init(status: .pending, orderId: nil, url: nil, errorMessage: nil) },
                    fetchPaymentSetupStatus: { .active }
                )
                sut = mockService

                let vm = makeViewModel(state: .failed(error: nil))
                await vm.requestNewOrder()

                #expect(vm.pollAttempt == 1)
                #expect(vm.isRetrying == false)
                #expect(vm.state == .waiting)

                let result = await vm.pollUntilSettled()

                #expect(result == false)
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }
    }
}
