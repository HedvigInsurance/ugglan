import XCTest
import hCore

@testable import Onboarding

@MainActor
final class OnboardingConnectPaymentRetainTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        FeatureFlags.shared.data = .mock(isAnalyticsEnabled: true)
    }

    override func tearDown() async throws {
        FeatureFlags.shared.data = .mock(isAnalyticsEnabled: false)
        try await super.tearDown()
    }

    func testConnectPaymentStoresCallbacksOnPaymentViewModel() async throws {
        let vm = OnboardingNavigationViewModel()

        vm.connectPayment()
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertNotNil(vm.connectPaymentVm.setupTypeNavigationModel)
    }

    func testConnectPaymentCallbacksDoNotRetainViewModel() async throws {
        var vm: OnboardingNavigationViewModel? = OnboardingNavigationViewModel()
        weak let weakVm = vm
        let connectPaymentVm = vm!.connectPaymentVm

        vm?.connectPayment()
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertNotNil(connectPaymentVm.setupTypeNavigationModel)
        vm = nil

        XCTAssertNil(weakVm, "callbacks stored on connectPaymentVm must not hold the onboarding view model")
    }
}

extension FeatureData {
    /// `OnboardingStepComputationTests.swift` owns an identical `fileprivate` helper; file-scoped
    /// visibility means it is not reachable from here, so this file needs its own copy.
    fileprivate static func mock(isAnalyticsEnabled: Bool) -> FeatureData {
        .init(
            isUpdateNecessary: false,
            isSubmitClaimEnabled: false,
            osVersionTooLow: false,
            emailPreferencesEnabled: false,
            isDemoMode: false,
            isAddonsRemovalFromMovingFlowEnabled: false,
            isNewConversationFromInboxEnabled: false,
            isPuppyGuideEnabled: false,
            isResumeClaimEnabled: false,
            isOnboardingEnabled: true,
            isTerminationRedirectionEnabled: false,
            isAnalyticsEnabled: isAnalyticsEnabled,
            isResumingOngoingShopSessionsEnabled: false
        )
    }
}
