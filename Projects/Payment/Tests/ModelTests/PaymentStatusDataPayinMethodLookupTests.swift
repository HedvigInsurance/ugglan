import Testing

@testable import Payment

@MainActor
final class PaymentStatusDataPayinMethodLookupTests {
    private let trustly = PaymentTestMethod.trustly
    private let swish = PaymentTestMethod.swish
    private let invoice = PaymentTestMethod.invoice

    private func makeStatusData(
        defaultPayinMethod: ConnectedPaymentMethod? = nil,
        payinMethods: [ConnectedPaymentMethod]
    ) -> PaymentStatusData {
        .test(defaultPayinMethod: defaultPayinMethod, payinMethods: payinMethods)
    }

    @Test
    func payinMethodWithoutMethodsReturnsNil() {
        let statusData = makeStatusData(payinMethods: [])

        #expect(statusData.connectedPaymentMethod(for: .swish) == nil)
    }

    @Test
    func payinMethodWithoutMatchingProviderReturnsNil() {
        let statusData = makeStatusData(
            defaultPayinMethod: trustly.connected(isDefault: true),
            payinMethods: [trustly.connected(isDefault: true), invoice.connected(status: .pending)]
        )

        #expect(statusData.connectedPaymentMethod(for: .swish) == nil)
    }

    @Test
    func payinMethodActiveMatchNotProcessing() throws {
        let activeSwish = swish.connected()
        let statusData = makeStatusData(payinMethods: [trustly.connected(isDefault: true), activeSwish])

        let result = try #require(statusData.connectedPaymentMethod(for: .swish))

        #expect(result == activeSwish)
    }

    @Test
    func payinMethodPendingMatchIsProcessing() throws {
        let pendingSwish = swish.connected(status: .pending)
        let statusData = makeStatusData(payinMethods: [trustly.connected(isDefault: true), pendingSwish])

        let result = try #require(statusData.connectedPaymentMethod(for: .swish))

        #expect(result == pendingSwish)
    }

    @Test
    func payinMethodPrefersActiveOverPendingMatch() throws {
        let pendingSwish = swish.connected(status: .pending)
        let activeSwish = swish.connected(isDefault: true)
        let statusData = makeStatusData(payinMethods: [pendingSwish, activeSwish])

        let result = try #require(statusData.connectedPaymentMethod(for: .swish))

        #expect(result == activeSwish)
    }

    @Test
    func payinMethodFallsBackToFirstMatchWithoutActive() throws {
        let unknownSwish = swish.connected(status: .unknown)
        let pendingSwish = swish.connected(status: .pending)
        let statusData = makeStatusData(payinMethods: [unknownSwish, pendingSwish])

        let result = try #require(statusData.connectedPaymentMethod(for: .swish))

        #expect(result == unknownSwish)
    }

    @Test
    func payinMethodOtherProviderPendingNotProcessing() throws {
        let activeTrustly = trustly.connected(isDefault: true)
        let statusData = makeStatusData(payinMethods: [activeTrustly, swish.connected(status: .pending)])

        let result = try #require(statusData.connectedPaymentMethod(for: .trustly))

        #expect(result == activeTrustly)
    }

    @Test
    func payinMethodMatchOnlyInDefaultPayinMethod() throws {
        let defaultSwish = swish.connected(isDefault: true)
        let statusData = makeStatusData(defaultPayinMethod: defaultSwish, payinMethods: [trustly.connected()])

        let result = try #require(statusData.connectedPaymentMethod(for: .swish))

        #expect(result == defaultSwish)
    }

    @Test
    func payinMethodPrefersActiveListedMethodOverPendingDefault() throws {
        let pendingDefaultSwish = swish.connected(status: .pending, isDefault: true)
        let activeSwish = swish.connected()
        let statusData = makeStatusData(defaultPayinMethod: pendingDefaultSwish, payinMethods: [activeSwish])

        let result = try #require(statusData.connectedPaymentMethod(for: .swish))

        #expect(result == activeSwish)
    }

    @Test
    func defaultOrFirstDefaultFallsBackToTheListWithoutADefaultField() {
        let activeTrustly = trustly.connected()
        let defaultSwish = swish.connected(isDefault: true)
        let statusData = makeStatusData(payinMethods: [activeTrustly, defaultSwish])

        #expect(statusData.defaultOrFirstDefaultPayinMethod == defaultSwish)
    }
}
