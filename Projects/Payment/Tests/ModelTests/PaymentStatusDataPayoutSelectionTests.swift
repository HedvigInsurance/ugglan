import Testing

@testable import Payment

@MainActor
final class PaymentStatusDataPayoutSelectionTests {
    private let trustly = PaymentTestMethod.trustly
    private let swish = PaymentTestMethod.swish
    private let nordea = PaymentMethod.nordea(bankAccount: .init(account: "3300-1234567", bank: "Nordea"))

    private func makeStatusData(payoutMethods: [ConnectedPaymentMethod]) -> PaymentStatusData {
        .test(defaultPayoutMethod: payoutMethods.first(where: \.isDefault), payoutMethods: payoutMethods)
    }

    // MARK: - activePayoutMethods

    @Test
    func activePayoutMethodsIncludesOnlyActiveMethods() {
        let activeNordea = nordea.connected(isDefault: true)
        let pendingSwish = swish.connected(status: .pending)
        let unknownTrustly = trustly.connected(status: .unknown)
        let statusData = makeStatusData(payoutMethods: [activeNordea, pendingSwish, unknownTrustly])

        #expect(statusData.activePayoutMethods == [activeNordea])
    }

    // MARK: - selectablePayoutMethods

    @Test
    func selectablePayoutMethodsDefaultFirst() {
        let activeTrustly = trustly.connected()
        let defaultSwish = swish.connected(isDefault: true)
        let activeNordea = nordea.connected()
        let statusData = makeStatusData(payoutMethods: [activeTrustly, defaultSwish, activeNordea])

        #expect(statusData.selectablePayoutMethods == [defaultSwish, activeTrustly, activeNordea])
    }

    @Test
    func selectablePayoutMethodsExcludesPendingMethods() {
        let defaultNordea = nordea.connected(isDefault: true)
        let pendingSwish = swish.connected(status: .pending)
        let statusData = makeStatusData(payoutMethods: [pendingSwish, defaultNordea])

        #expect(statusData.selectablePayoutMethods == [defaultNordea])
    }

    @Test
    func selectableMethodsForPayoutIgnoresPayinMethods() {
        let defaultNordea = nordea.connected(isDefault: true)
        let statusData = PaymentStatusData.test(
            payinMethods: [trustly.connected(isDefault: true), swish.connected()],
            payoutMethods: [defaultNordea]
        )

        #expect(statusData.selectableMethods(for: .payout) == [defaultNordea])
    }

    // MARK: - canChooseDefaultPayoutMethod

    @Test
    func canChooseDefaultPayoutMethodWithoutMethods() {
        let statusData = makeStatusData(payoutMethods: [])

        #expect(statusData.canChooseDefaultPayoutMethod == false)
    }

    @Test
    func canChooseDefaultPayoutMethodWithOneActiveMethod() {
        let statusData = makeStatusData(
            payoutMethods: [nordea.connected(isDefault: true), swish.connected(status: .pending)]
        )

        #expect(statusData.canChooseDefaultPayoutMethod == false)
    }

    @Test
    func canChooseDefaultPayoutMethodWithTwoActiveMethods() {
        let statusData = makeStatusData(
            payoutMethods: [nordea.connected(isDefault: true), swish.connected()]
        )

        #expect(statusData.canChooseDefaultPayoutMethod)
    }
}
