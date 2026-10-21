import Foundation
import Testing

@testable import Home

final class DismissedOngoingQuotesTrackerTests {
    // Each test gets its own UserDefaults suite, so this needs no .serialized parent.
    private let suiteName: String
    private let userDefaults: UserDefaults

    init() throws {
        suiteName = "DismissedOngoingQuotesTrackerTests.\(UUID().uuidString)"
        userDefaults = try #require(UserDefaults(suiteName: suiteName))
    }

    deinit {
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    @Test
    func nothingIsDismissedForAnUnknownMember() {
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        #expect(store.dismissedIds(forMember: "member-1").isEmpty)
    }

    @Test
    func dismissedQuoteIsRememberedForThatMember() {
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        store.dismiss(quoteId: "quote-1", forMember: "member-1")

        #expect(store.dismissedIds(forMember: "member-1") == ["quote-1"])
    }

    @Test
    func dismissalsAreIsolatedPerMember() {
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        store.dismiss(quoteId: "quote-1", forMember: "member-1")

        #expect(store.dismissedIds(forMember: "member-2").isEmpty)
    }

    @Test
    func dismissingSeveralQuotesKeepsAllOfThem() {
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        store.dismiss(quoteId: "quote-1", forMember: "member-1")
        store.dismiss(quoteId: "quote-2", forMember: "member-1")

        #expect(store.dismissedIds(forMember: "member-1") == ["quote-1", "quote-2"])
    }

    @Test
    func dismissingTheSameQuoteTwiceStoresItOnce() {
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        store.dismiss(quoteId: "quote-1", forMember: "member-1")
        store.dismiss(quoteId: "quote-1", forMember: "member-1")

        #expect(store.dismissedIds(forMember: "member-1") == ["quote-1"])
    }

    @Test
    func corruptStoredValueIsTreatedAsNothingDismissed() {
        userDefaults.set(Data("not json".utf8), forKey: DismissedOngoingQuotesTracker.storageKey)
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        #expect(store.dismissedIds(forMember: "member-1").isEmpty)

        store.dismiss(quoteId: "quote-1", forMember: "member-1")

        #expect(store.dismissedIds(forMember: "member-1") == ["quote-1"])
    }

    @Test
    func dismissalsSurviveANewStoreInstance() {
        DismissedOngoingQuotesTracker(userDefaults: userDefaults)
            .dismiss(quoteId: "quote-1", forMember: "member-1")

        let reloaded = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        #expect(reloaded.dismissedIds(forMember: "member-1") == ["quote-1"])
    }
}
