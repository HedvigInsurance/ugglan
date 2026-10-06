import Foundation
import XCTest

@testable import Home

@MainActor
final class DismissedOngoingQuotesTrackerTests: XCTestCase {
    private var suiteName: String!
    private var userDefaults: UserDefaults!

    override func setUp() async throws {
        try await super.setUp()
        suiteName = "DismissedOngoingQuotesTrackerTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() async throws {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        try await super.tearDown()
    }

    func testNothingIsDismissedForAnUnknownMember() {
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        XCTAssertTrue(store.dismissedIds(forMember: "member-1").isEmpty)
    }

    func testDismissedQuoteIsRememberedForThatMember() {
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        store.dismiss(quoteId: "quote-1", forMember: "member-1")

        XCTAssertEqual(store.dismissedIds(forMember: "member-1"), ["quote-1"])
    }

    func testDismissalsAreIsolatedPerMember() {
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        store.dismiss(quoteId: "quote-1", forMember: "member-1")

        XCTAssertTrue(store.dismissedIds(forMember: "member-2").isEmpty)
    }

    func testDismissingSeveralQuotesKeepsAllOfThem() {
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        store.dismiss(quoteId: "quote-1", forMember: "member-1")
        store.dismiss(quoteId: "quote-2", forMember: "member-1")

        XCTAssertEqual(store.dismissedIds(forMember: "member-1"), ["quote-1", "quote-2"])
    }

    func testDismissingTheSameQuoteTwiceStoresItOnce() {
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        store.dismiss(quoteId: "quote-1", forMember: "member-1")
        store.dismiss(quoteId: "quote-1", forMember: "member-1")

        XCTAssertEqual(store.dismissedIds(forMember: "member-1"), ["quote-1"])
    }

    func testCorruptStoredValueIsTreatedAsNothingDismissed() {
        userDefaults.set(Data("not json".utf8), forKey: DismissedOngoingQuotesTracker.storageKey)
        let store = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        XCTAssertTrue(store.dismissedIds(forMember: "member-1").isEmpty)

        store.dismiss(quoteId: "quote-1", forMember: "member-1")

        XCTAssertEqual(store.dismissedIds(forMember: "member-1"), ["quote-1"])
    }

    func testDismissalsSurviveANewStoreInstance() {
        DismissedOngoingQuotesTracker(userDefaults: userDefaults)
            .dismiss(quoteId: "quote-1", forMember: "member-1")

        let reloaded = DismissedOngoingQuotesTracker(userDefaults: userDefaults)

        XCTAssertEqual(reloaded.dismissedIds(forMember: "member-1"), ["quote-1"])
    }
}
