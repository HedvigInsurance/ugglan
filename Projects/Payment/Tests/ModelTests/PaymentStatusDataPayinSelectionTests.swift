import Testing

@testable import Payment

@MainActor
final class PaymentStatusDataPayinSelectionTests {
    private let trustly = PaymentTestMethod.trustly
    private let swish = PaymentTestMethod.swish
    private let invoice = PaymentTestMethod.invoice

    private func makeStatusData(payinMethods: [ConnectedPaymentMethod]) -> PaymentStatusData {
        .test(defaultPayinMethod: payinMethods.first(where: \.isDefault), payinMethods: payinMethods)
    }

    // MARK: - activePayinMethods

    @Test
    func activePayinMethodsEmptyWithoutMethods() {
        let statusData = makeStatusData(payinMethods: [])

        #expect(statusData.activePayinMethods == [])
    }

    @Test
    func activePayinMethodsIncludesOnlyActiveMethods() {
        let activeTrustly = trustly.connected(isDefault: true)
        let pendingSwish = swish.connected(status: .pending)
        let unknownInvoice = invoice.connected(status: .unknown)
        let activeSwish = swish.connected()
        let statusData = makeStatusData(payinMethods: [activeTrustly, pendingSwish, unknownInvoice, activeSwish])

        #expect(statusData.activePayinMethods == [activeTrustly, activeSwish])
    }

    // MARK: - selectablePayinMethods

    @Test
    func selectablePayinMethodsDefaultFirst() {
        let activeTrustly = trustly.connected()
        let defaultInvoice = invoice.connected(isDefault: true)
        let activeSwish = swish.connected()
        let statusData = makeStatusData(payinMethods: [activeTrustly, defaultInvoice, activeSwish])

        #expect(statusData.selectablePayinMethods == [defaultInvoice, activeTrustly, activeSwish])
    }

    @Test
    func selectablePayinMethodsPreservesBackendOrderWithoutDefault() {
        let activeSwish = swish.connected()
        let activeInvoice = invoice.connected()
        let activeTrustly = trustly.connected()
        let statusData = makeStatusData(payinMethods: [activeSwish, activeInvoice, activeTrustly])

        #expect(statusData.selectablePayinMethods == [activeSwish, activeInvoice, activeTrustly])
    }

    @Test
    func selectablePayinMethodsExcludesPendingMethods() {
        let activeTrustly = trustly.connected()
        let pendingSwish = swish.connected(status: .pending)
        let defaultInvoice = invoice.connected(isDefault: true)
        let statusData = makeStatusData(payinMethods: [activeTrustly, pendingSwish, defaultInvoice])

        #expect(statusData.selectablePayinMethods == [defaultInvoice, activeTrustly])
    }

    @Test
    func selectablePayinMethodsExcludesPendingDefault() {
        let pendingDefaultSwish = swish.connected(status: .pending, isDefault: true)
        let activeTrustly = trustly.connected()
        let statusData = makeStatusData(payinMethods: [pendingDefaultSwish, activeTrustly])

        #expect(statusData.selectablePayinMethods == [activeTrustly])
    }

    @Test
    func selectablePayinMethodsEmptyWhenAllPending() {
        let statusData = makeStatusData(
            payinMethods: [swish.connected(status: .pending), trustly.connected(status: .pending)]
        )

        #expect(statusData.selectablePayinMethods == [])
    }

    // MARK: - canChooseDefaultPayinMethod

    @Test
    func canChooseDefaultPayinMethodWithoutMethods() {
        let statusData = makeStatusData(payinMethods: [])

        #expect(statusData.canChooseDefaultPayinMethod == false)
    }

    @Test
    func canChooseDefaultPayinMethodWithOnlyPendingMethods() {
        let statusData = makeStatusData(
            payinMethods: [swish.connected(status: .pending), trustly.connected(status: .pending)]
        )

        #expect(statusData.canChooseDefaultPayinMethod == false)
    }

    @Test
    func canChooseDefaultPayinMethodWithOneActiveMethod() {
        let statusData = makeStatusData(
            payinMethods: [trustly.connected(isDefault: true), swish.connected(status: .pending)]
        )

        #expect(statusData.canChooseDefaultPayinMethod == false)
    }

    @Test
    func canChooseDefaultPayinMethodWithTwoActiveMethods() {
        let statusData = makeStatusData(
            payinMethods: [trustly.connected(isDefault: true), swish.connected()]
        )

        #expect(statusData.canChooseDefaultPayinMethod)
    }
}
