import TestDependencies
import Testing
import hCore

@testable import Payment

extension PaymentDependencySuite {
    @MainActor
    final class PaymentServiceTests {
        private weak var sut: MockPaymentService?

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: hPaymentClient.self)
            await delay(0.00001)

            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }

        @Test
        func fetchPaymentDataSuccess() async {
            await recordingErrors {
                let paymentData: (upcoming: Payment.PaymentData?, ongoing: [Payment.PaymentData]) = (
                    upcoming: .init(
                        id: "id1",
                        payment: .init(
                            gross: .init(amount: "230", currency: "SEK"),
                            net: .init(amount: "230", currency: "SEK"),
                            carriedAdjustment: .init(amount: "230", currency: "SEK"),
                            settlementAdjustment: nil,
                            date: .init()
                        ),
                        status: .upcoming,
                        contracts: [],
                        referralDiscount: nil,
                        amountPerReferral: .sek(20),
                        payinMethod: nil,
                        addedToThePayment: nil
                    ),
                    ongoing: [
                        .init(
                            id: "id2",
                            payment: .init(
                                gross: .init(amount: "230", currency: "SEK"),
                                net: .init(amount: "230", currency: "SEK"),
                                carriedAdjustment: .init(amount: "230", currency: "SEK"),
                                settlementAdjustment: nil,
                                date: .init()
                            ),
                            status: .pending,
                            contracts: [],
                            referralDiscount: nil,
                            amountPerReferral: .sek(10),
                            payinMethod: nil,
                            addedToThePayment: nil
                        )
                    ]
                )

                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentData: { paymentData }
                )
                sut = mockService

                let respondedPaymentData = try await mockService.getPaymentData()
                #expect(respondedPaymentData.ongoing == paymentData.ongoing)
                #expect(respondedPaymentData.upcoming == paymentData.upcoming)
            }

            await expectServiceReleased()
        }

        @Test
        func fetchPaymentStatusDataSuccess() async {
            await recordingErrors {
                let paymentStatusData: PaymentStatusData = .init(
                    status: .active,
                    chargingDay: 27,
                    defaultPayinMethod: .init(
                        status: .active,
                        isDefault: true,
                        method: .trustly(bankAccount: .init(account: "descriptor", bank: "displayName"))
                    ),
                    payinMethods: [
                        .init(
                            status: .active,
                            isDefault: true,
                            method: .trustly(bankAccount: .init(account: "descriptor", bank: "displayName"))
                        )
                    ],
                    defaultPayoutMethod: nil,
                    payoutMethods: [],
                    availableMethods: [],
                    missingConnection: nil,
                    layout: .other
                )
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentStatusData: { paymentStatusData }
                )
                sut = mockService

                let respondedPaymentStatusData = try await mockService.getPaymentStatusData()
                #expect(respondedPaymentStatusData == paymentStatusData)
            }

            await expectServiceReleased()
        }

        @Test
        func fetchPaymentHistoryDataSuccess() async {
            await recordingErrors {
                let paymentHistoryData: [PaymentHistoryListData] = [
                    .init(
                        id: "id",
                        year: 2023,
                        valuesPerMonth: []
                    )
                ]

                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentHistoryData: { paymentHistoryData }
                )
                sut = mockService

                let respondedPaymentHistoryData = try await mockService.getPaymentHistoryData()
                #expect(respondedPaymentHistoryData == paymentHistoryData)
            }

            await expectServiceReleased()
        }

        @Test
        func setupPaymentMethodSuccess() async {
            await recordingErrors {
                let expectedResult = PaymentSetupResult(
                    status: .pending,
                    orderId: "order-1",
                    url: "https://hedvig.se/trustly",
                    errorMessage: nil
                )

                let mockService = MockPaymentData.createMockPaymentService(
                    fetchSetupPaymentMethod: {
                        expectedResult
                    }
                )
                sut = mockService

                let result = try await mockService.setupPaymentMethod(
                    .trustly
                )
                #expect(result == expectedResult)
            }

            await expectServiceReleased()
        }

        @Test
        func getPaymentSetupStatusSuccess() async {
            await recordingErrors {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchPaymentSetupStatus: { .active }
                )
                sut = mockService

                let status = try await mockService.getPaymentSetupStatus(orderId: "order-1")
                #expect(status == .active)
                #expect(mockService.events == [.getPaymentSetupStatus])
            }

            await expectServiceReleased()
        }

        @Test
        func fetchMissedPaymentDataSuccess() async {
            await recordingErrors {
                let missedPaymentData = MissedPaymentData(
                    paymentData: .init(
                        id: "missed-id",
                        payment: .init(
                            gross: .init(amount: "230", currency: "SEK"),
                            net: .init(amount: "230", currency: "SEK"),
                            carriedAdjustment: .init(amount: "230", currency: "SEK"),
                            settlementAdjustment: nil,
                            date: .init()
                        ),
                        status: .upcoming,
                        contracts: [],
                        referralDiscount: nil,
                        amountPerReferral: .sek(20),
                        payinMethod: nil,
                        addedToThePayment: nil
                    ),
                    paymentMethodData: .init(
                        status: .active,
                        isDefault: true,
                        method: .trustly(bankAccount: .init(account: "descriptor", bank: "displayName"))
                    )
                )

                let mockService = MockPaymentData.createMockPaymentService(
                    fetchMissedPaymentData: { missedPaymentData }
                )
                sut = mockService

                let response = try await mockService.getMissedPaymentData()
                #expect(response == missedPaymentData)
                #expect(mockService.events.first == .getMissedPaymentData)
            }

            await expectServiceReleased()
        }

        @Test
        func fetchMissedPaymentDataNil() async {
            await recordingErrors {
                let mockService = MockPaymentData.createMockPaymentService(
                    fetchMissedPaymentData: { nil }
                )
                sut = mockService

                let response = try await mockService.getMissedPaymentData()
                #expect(response == nil)
                #expect(mockService.events.first == .getMissedPaymentData)
            }

            await expectServiceReleased()
        }

        @Test
        func chargeOutstandingPaymentSuccess() async {
            await recordingErrors {
                let mockService = MockPaymentData.createMockPaymentService(
                    chargeOutstandingPayment: {}
                )
                sut = mockService

                try await mockService.chargeOutstandingPayment()
                #expect(mockService.events.first == .chargeOutstandingPayment)
            }

            await expectServiceReleased()
        }

        @Test
        func chargeOutstandingPaymentFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    chargeOutstandingPayment: { throw PaymentError.missingDataError(message: "error") }
                )
                sut = mockService

                await #expect(throws: PaymentError.self) {
                    try await mockService.chargeOutstandingPayment()
                }
                #expect(mockService.events.first == .chargeOutstandingPayment)
            }

            await expectServiceReleased()
        }

        @Test
        func setDefaultPaymentMethodSuccess() async {
            await recordingErrors {
                let mockService = MockPaymentData.createMockPaymentService(
                    setDefaultPaymentMethod: {}
                )
                sut = mockService

                try await mockService.setDefaultPaymentMethod(.swish(phoneNumber: "0701231231"))
                #expect(mockService.events.first == .setDefaultPaymentMethod)
            }

            await expectServiceReleased()
        }

        @Test
        func setDefaultPaymentMethodFailure() async {
            do {
                let mockService = MockPaymentData.createMockPaymentService(
                    setDefaultPaymentMethod: { throw PaymentError.missingDataError(message: "error") }
                )
                sut = mockService

                await #expect(throws: PaymentError.self) {
                    try await mockService.setDefaultPaymentMethod(.swish(phoneNumber: "0701231231"))
                }
                #expect(mockService.events.first == .setDefaultPaymentMethod)
            }

            await expectServiceReleased()
        }
    }
}
