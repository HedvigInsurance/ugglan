import Testing

@testable import hCore

@MainActor
final class FeatureFlagsStoreTests {
    private weak var store: FeatureFlagsStore?

    @Test
    func applySnapshotDropsUpdateGatesAndRestoresOtherFlags() {
        do {
            let store = FeatureFlagsStore()
            self.store = store

            store.apply(snapshot: .init(savedData: .withUpdateGatesAndPuppyGuide))

            #expect(store.data.isUpdateNecessary == false)
            #expect(store.data.osVersionTooLow == false)
            #expect(store.data.isPuppyGuideEnabled == true)
            #expect(store.isPuppyGuideEnabled == true)
            #expect(store.isUpdateNecessary == false)
        }

        expectStoreReleased()
    }

    @Test
    func applySnapshotWithoutSavedDataReportsAllDisabled() {
        do {
            let store = FeatureFlagsStore()
            self.store = store

            store.apply(snapshot: .init(savedData: nil))

            #expect(store.data == .allFalse)
        }

        expectStoreReleased()
    }

    @Test
    func setDataReportsUpdateGates() {
        do {
            let store = FeatureFlagsStore()
            self.store = store

            store.data = .withUpdateGatesAndPuppyGuide

            #expect(store.data == .withUpdateGatesAndPuppyGuide)
            #expect(store.data.isUpdateNecessary == true)
            #expect(store.data.osVersionTooLow == true)
        }

        expectStoreReleased()
    }

    @Test
    func setDataAfterApplySnapshotReportsUpdateGates() {
        do {
            let store = FeatureFlagsStore()
            self.store = store

            store.apply(snapshot: .init(savedData: .allFalse))
            store.data = .withUpdateGatesAndPuppyGuide

            #expect(store.data == .withUpdateGatesAndPuppyGuide)
        }

        expectStoreReleased()
    }

    @Test
    func setDataPersistsSetValueInSnapshot() {
        do {
            let store = FeatureFlagsStore()
            self.store = store

            store.data = .withUpdateGatesAndPuppyGuide

            #expect(store.snapshot.savedData == .withUpdateGatesAndPuppyGuide)
        }

        expectStoreReleased()
    }

    private func expectStoreReleased() {
        #expect(store == nil, "the store must not outlive the test that created it")
    }
}

extension FeatureData {
    fileprivate static let allFalse = FeatureData(
        isUpdateNecessary: false,
        osVersionTooLow: false,
        emailPreferencesEnabled: false,
        isDemoMode: false,
        isNewConversationFromInboxEnabled: false,
        isPuppyGuideEnabled: false,
        isResumeClaimEnabled: false,
        isOnboardingEnabled: false,
        isTerminationRedirectionEnabled: false,
        isAnalyticsEnabled: false,
        isResumingOngoingShopSessionsEnabled: false,
        isCancelInsuranceHiddenFromHomeScreen: false
    )

    fileprivate static let withUpdateGatesAndPuppyGuide = FeatureData(
        isUpdateNecessary: true,
        osVersionTooLow: true,
        emailPreferencesEnabled: false,
        isDemoMode: false,
        isNewConversationFromInboxEnabled: false,
        isPuppyGuideEnabled: true,
        isResumeClaimEnabled: false,
        isOnboardingEnabled: false,
        isTerminationRedirectionEnabled: false,
        isAnalyticsEnabled: false,
        isResumingOngoingShopSessionsEnabled: false,
        isCancelInsuranceHiddenFromHomeScreen: false
    )
}
