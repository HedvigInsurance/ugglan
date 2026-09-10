import CrossSell
import XCTest
import hCore

@testable import Onboarding

@MainActor
final class OnboardingConnectPaymentRetainTests: XCTestCase {
    override func tearDown() async throws {
        Dependencies.shared.remove(for: OnboardingClient.self)
        try await super.tearDown()
    }

    func testConnectPaymentOnSuccessMarksStepConnected() async throws {
        registerStubClient(isPaymentConnected: true)
        let vm = OnboardingNavigationViewModel()
        vm.steps = [.connectPayment(isConnected: false)]

        vm.connectPayment()
        // `set` assigns the model from inside a `Task`, so it is not there when `set` returns.
        try await Task.sleep(for: .milliseconds(100))
        let model = try XCTUnwrap(vm.connectPaymentVm.setupTypeNavigationModel)

        XCTAssertNotNil(model.onSuccess, "onSuccess must reach the payment flow or a connection is never recorded")
        model.onSuccess?()

        XCTAssertEqual(vm.steps, [.connectPayment(isConnected: true)])
    }

    func testConnectPaymentOnDeinitRefreshesPaymentStatus() async throws {
        let client = registerStubClient(isPaymentConnected: true)
        let vm = OnboardingNavigationViewModel()
        vm.steps = [.connectPayment(isConnected: false)]

        vm.connectPayment()
        // `set` assigns the model from inside a `Task`, so it is not there when `set` returns.
        try await Task.sleep(for: .milliseconds(100))
        let model = try XCTUnwrap(vm.connectPaymentVm.setupTypeNavigationModel)

        XCTAssertNotNil(model.onDeinit, "onDeinit must reach the payment flow or a dismissed sheet never refreshes")
        await model.onDeinit?()

        // Proves the flip came from the callback re-reading the backend, not from anything else.
        XCTAssertEqual(client.paymentStatusFetchCount, 1)
        XCTAssertEqual(vm.steps, [.connectPayment(isConnected: true)])
    }

    func testConnectPaymentCallbacksDoNotRetainViewModel() async throws {
        var vm: OnboardingNavigationViewModel? = OnboardingNavigationViewModel()
        weak let weakVm = vm
        // The callbacks are stored on `connectPaymentVm`; holding that storage — and the model
        // carrying the closures — past the drop is what makes a cycle through it observable.
        let connectPaymentVm = vm!.connectPaymentVm

        vm?.connectPayment()
        // `set` assigns the model from inside a `Task`, so it is not there when `set` returns.
        try await Task.sleep(for: .milliseconds(100))
        let model = try XCTUnwrap(connectPaymentVm.setupTypeNavigationModel)

        // Without these the test passes vacuously: absent callbacks retain nothing.
        XCTAssertNotNil(model.onSuccess, "onSuccess must be stored, otherwise there is no capture to check")
        XCTAssertNotNil(model.onDeinit, "onDeinit must be stored, otherwise there is no capture to check")
        vm = nil

        XCTAssertNil(weakVm, "callbacks stored on connectPaymentVm must not hold the onboarding view model")
    }
}

extension OnboardingConnectPaymentRetainTests {
    /// `@Inject` `fatalError`s on an unregistered dependency and `fetchPaymentStatus`'s `try?`
    /// cannot catch that, so the client is registered before the view model exists.
    @discardableResult
    fileprivate func registerStubClient(isPaymentConnected: Bool) -> StubOnboardingClient {
        let client = StubOnboardingClient(isPaymentConnected: isPaymentConnected)
        Dependencies.shared.add(module: Module { () -> OnboardingClient in client })
        return client
    }
}

/// `OnboardingClientDemo` reports payment as never connected and sleeps a second per call, so
/// these tests need their own boundary stub.
@MainActor
private final class StubOnboardingClient: OnboardingClient {
    private let isPaymentConnected: Bool
    var paymentStatusFetchCount = 0

    init(isPaymentConnected: Bool) {
        self.isPaymentConnected = isPaymentConnected
    }

    func getOnboardingSteps() async throws -> [OnboardingStep] { [] }

    func updateContactInfo(phone: String) async throws {}

    func getCrossSells() async throws -> [CrossSell] { [] }

    func getIsPaymentConnected() async throws -> Bool {
        paymentStatusFetchCount += 1
        return isPaymentConnected
    }
}
