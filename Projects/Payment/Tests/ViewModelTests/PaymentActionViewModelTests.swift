import Testing
import hCore

@testable import Payment

extension PaymentDependencySuite {
    @MainActor
    final class PaymentActionViewModelTests {
        private weak var sut: MockPaymentService?

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

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: hPaymentClient.self)
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }

        @Test
        func initialStateNotLoadingWithoutError() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = PaymentActionViewModel.remove(swishMethod)

                #expect(vm.processingState == .success)
                #expect(vm.isLoading == false)
                #expect(vm.errorMessage == nil)
                #expect(mockService.events.isEmpty)
            }

            await expectServiceReleased()
        }

        @Test
        func performSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(removePaymentMethod: {})
                sut = mockService

                let vm = PaymentActionViewModel.remove(swishMethod)
                let result = await vm.perform()

                #expect(result)
                #expect(vm.processingState == .success)
                #expect(vm.isLoading == false)
                #expect(vm.errorMessage == nil)
                #expect(mockService.events == [.removePaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func performLoadingWhileActionRuns() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = PaymentActionViewModel.remove(swishMethod)
                await confirmation("the remove call runs") { removeRan in
                    mockService.removePaymentMethodClosure = { [weak vm] in
                        removeRan()
                        #expect(vm?.processingState == .loading)
                        #expect(vm?.isLoading == true)
                    }
                    let result = await vm.perform()

                    #expect(result)
                    #expect(vm.isLoading == false)
                }
            }

            await expectServiceReleased()
        }

        @Test
        func performServiceErrorFailure() async {
            do {
                let error = PaymentError.missingDataError(message: "error")
                let mockService = MockPaymentData.createMockPaymentService(removePaymentMethod: { throw error })
                sut = mockService

                let vm = PaymentActionViewModel.remove(swishMethod)
                let result = await vm.perform()

                #expect(result == false)
                #expect(vm.processingState.isError)
                #expect(vm.errorMessage == error.localizedDescription)
                #expect(vm.isLoading == false)
                #expect(mockService.events == [.removePaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func performClearsPreviousErrorSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    removePaymentMethod: { throw PaymentError.missingDataError(message: "error") }
                )
                sut = mockService

                let vm = PaymentActionViewModel.remove(swishMethod)
                let firstResult = await vm.perform()
                mockService.removePaymentMethodClosure = {}
                let secondResult = await vm.perform()

                #expect(firstResult == false)
                #expect(secondResult)
                #expect(vm.processingState == .success)
                #expect(vm.errorMessage == nil)
                #expect(vm.isLoading == false)
                #expect(mockService.events == [.removePaymentMethod, .removePaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func removeSendsTheMethodsProviderSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(removePaymentMethod: {})
                sut = mockService

                let result = await PaymentActionViewModel.remove(swishMethod).perform()

                #expect(result)
                #expect(mockService.events == [.removePaymentMethod])
                #expect(mockService.removedProviders == [.swish])
            }

            await expectServiceReleased()
        }

        @Test
        func removeTrustlyMethodRecordsProviderSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let result = await PaymentActionViewModel.remove(trustlyMethod).perform()

                #expect(result)
                #expect(mockService.removedProviders == [.trustly])
            }

            await expectServiceReleased()
        }

        @Test
        func setDefaultCallsSetDefaultPaymentMethodSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(setDefaultPaymentMethod: {})
                sut = mockService

                let vm = PaymentActionViewModel.setDefault(swishMethod)
                let result = await vm.perform()

                #expect(result)
                #expect(vm.processingState == .success)
                #expect(mockService.events == [.setDefaultPaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func setDefaultServiceErrorFailure() async {
            do {
                let error = PaymentError.missingDataError(message: "error")
                let mockService = MockPaymentData.createMockPaymentService(setDefaultPaymentMethod: { throw error })
                sut = mockService

                let vm = PaymentActionViewModel.setDefault(swishMethod)
                let result = await vm.perform()

                #expect(result == false)
                #expect(vm.errorMessage == error.localizedDescription)
                #expect(mockService.events == [.setDefaultPaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func setDefaultPayoutCallsSetDefaultPayoutMethodSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(setDefaultPayoutMethod: {})
                sut = mockService

                let vm = PaymentActionViewModel.setDefaultPayout(swishMethod)
                let result = await vm.perform()

                #expect(result)
                #expect(vm.processingState == .success)
                #expect(mockService.events == [.setDefaultPayoutMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func setDefaultPayoutServiceErrorFailure() async {
            do {
                let error = PaymentError.missingDataError(message: "error")
                let mockService = MockPaymentData.createMockPaymentService(setDefaultPayoutMethod: { throw error })
                sut = mockService

                let vm = PaymentActionViewModel.setDefaultPayout(swishMethod)
                let result = await vm.perform()

                #expect(result == false)
                #expect(vm.errorMessage == error.localizedDescription)
                #expect(mockService.events == [.setDefaultPayoutMethod])
            }

            await expectServiceReleased()
        }
    }
}
