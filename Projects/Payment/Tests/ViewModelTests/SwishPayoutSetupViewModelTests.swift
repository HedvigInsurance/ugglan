import Testing
import hCore

@testable import Payment

extension PaymentDependencySuite {
    @MainActor
    final class SwishPayoutSetupViewModelTests {
        private weak var sut: MockPaymentService?

        private static let validPhoneNumber = "0735328847"

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: hPaymentClient.self)
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive its dependency registration")
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

        @Test
        func initialStateSaveDisabledUntilNumberIsConfirmed() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = SwishPayoutSetupViewModel()

                #expect(vm.isSaveDisabled)
                #expect(vm.hasConfirmedNumber == false)
                #expect(vm.phoneNumber == "")
                #expect(vm.phoneNumberError == nil)
                #expect(vm.errorMessage == nil)
                #expect(vm.isLoading == false)
                #expect(mockService.events.isEmpty)
            }

            await expectServiceReleased()
        }

        @Test
        func confirmingTheNumberEnablesSaving() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = SwishPayoutSetupViewModel()
                vm.hasConfirmedNumber = true

                #expect(vm.isSaveDisabled == false)
            }

            await expectServiceReleased()
        }

        @Test
        func removingTheConfirmationDisablesSavingAgain() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = makeViewModel()
                #expect(vm.isSaveDisabled == false)

                vm.hasConfirmedNumber = false

                #expect(vm.isSaveDisabled)
            }

            await expectServiceReleased()
        }

        // The phone number isn't part of the gate: an empty form still offers Save and fails on validation.
        @Test
        func saveEnabledWithoutAPhoneNumber() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = makeViewModel(phoneNumber: "")

                #expect(vm.isSaveDisabled == false)
            }

            await expectServiceReleased()
        }

        // MARK: - save validation

        @Test(arguments: ["", "12345", "073 532 88 47"])
        func saveMalformedPhoneNumberFailure(phoneNumber: String) async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = makeViewModel(phoneNumber: phoneNumber)
                let result = await vm.save()

                #expect(result == false)
                #expect(vm.phoneNumberError == L10n.myInfoPhoneNumberMalformedError)
                #expect(vm.focusedField == .phoneNumber)
                #expect(vm.errorMessage == nil)
                #expect(vm.isLoading == false)
                #expect(mockService.events.isEmpty)
            }

            await expectServiceReleased()
        }

        @Test
        func saveClearsPreviousPhoneNumberErrorSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
                )
                sut = mockService

                let vm = makeViewModel(phoneNumber: "12345")
                let firstResult = await vm.save()
                vm.phoneNumber = Self.validPhoneNumber
                let secondResult = await vm.save()

                #expect(firstResult == false)
                #expect(secondResult)
                #expect(vm.phoneNumberError == nil)
                #expect(vm.errorMessage == nil)
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }

        // MARK: - save

        @Test
        func saveSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
                )
                sut = mockService

                let vm = makeViewModel()
                let result = await vm.save()

                #expect(result)
                #expect(vm.errorMessage == nil)
                #expect(vm.phoneNumberError == nil)
                #expect(vm.isLoading == false)
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func saveSendsTheUnmaskedPhoneNumberSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
                )
                sut = mockService

                let vm = makeViewModel(phoneNumber: "+46735328847")
                let result = await vm.save()

                #expect(result)
                #expect(swishPayoutPhoneNumber(from: mockService.lastSetupType) == "+46735328847")
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func saveSendsTheNumberExactlyOncePerAttempt() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: { .init(status: .active, orderId: nil, url: nil, errorMessage: nil) }
                )
                sut = mockService

                let vm = makeViewModel()
                _ = await vm.save()
                vm.phoneNumber = "+46735328847"
                _ = await vm.save()

                #expect(mockService.setupTypes.count == 2)
                #expect(swishPayoutPhoneNumber(from: mockService.setupTypes.first) == Self.validPhoneNumber)
                #expect(swishPayoutPhoneNumber(from: mockService.lastSetupType) == "+46735328847")
            }

            await expectServiceReleased()
        }

        @Test
        func saveLoadingWhileSetupRuns() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService()
                sut = mockService

                let vm = makeViewModel()
                await confirmation("the setup call runs") { setupRan in
                    mockService.fetchSetupPaymentMethod = { [weak vm] in
                        setupRan()
                        #expect(vm?.isLoading == true)
                        return .init(status: .active, orderId: nil, url: nil, errorMessage: nil)
                    }
                    let result = await vm.save()

                    #expect(result)
                    #expect(vm.isLoading == false)
                }
            }

            await expectServiceReleased()
        }

        @Test
        func saveResultErrorMessageFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: {
                        .init(status: .failed, orderId: nil, url: nil, errorMessage: "number not connected to Swish")
                    }
                )
                sut = mockService

                let vm = makeViewModel()
                let result = await vm.save()

                #expect(result == false)
                #expect(vm.errorMessage == "number not connected to Swish")
                #expect(vm.phoneNumberError == nil)
                #expect(vm.isLoading == false)
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }

        // Only errorMessage decides the outcome, so a failure with no message still saves (pinned, not endorsed).
        @Test
        func saveFailedResultWithoutMessageSuccess() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: { .init(status: .failed, orderId: nil, url: nil, errorMessage: nil) }
                )
                sut = mockService

                let vm = makeViewModel()
                let result = await vm.save()

                #expect(result)
                #expect(vm.errorMessage == nil)
            }

            await expectServiceReleased()
        }

        @Test
        func saveServiceErrorFailure() async {
            do {
                let error = PaymentError.missingDataError(message: "error")
                let mockService = MockPaymentData.createMockPaymentService(fetchSetupPaymentMethod: { throw error })
                sut = mockService

                let vm = makeViewModel()
                let result = await vm.save()

                #expect(result == false)
                #expect(vm.errorMessage == error.localizedDescription)
                #expect(vm.phoneNumberError == nil)
                #expect(vm.isLoading == false)
                #expect(mockService.events == [.setupPaymentMethod])
            }

            await expectServiceReleased()
        }

        @Test
        func saveClearsPreviousErrorMessageSuccess() async {
            do {
                let error = PaymentError.missingDataError(message: "error")
                let mockService = MockPaymentData.createMockPaymentService(fetchSetupPaymentMethod: { throw error })
                sut = mockService

                let vm = makeViewModel()
                let firstResult = await vm.save()
                mockService.fetchSetupPaymentMethod = {
                    .init(status: .active, orderId: nil, url: nil, errorMessage: nil)
                }
                let secondResult = await vm.save()

                #expect(firstResult == false)
                #expect(secondResult)
                #expect(vm.errorMessage == nil)
                #expect(vm.isLoading == false)
                #expect(mockService.events == [.setupPaymentMethod, .setupPaymentMethod])
            }

            await expectServiceReleased()
        }
    }
}
