@testable import Embark
import Foundation
import XCTest

final class StoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testThatRevisionIsCreated() {
        let store = EmbarkStore()
        store.createRevision()
        store.createRevision()
        XCTAssertTrue(store.revisions.count == 3)
    }

    func testThatValuesAreSetAfterCommitting() {
        let store = EmbarkStore()
        store.setValue(key: "test", value: "test")

        XCTAssertTrue(store.getValue(key: "test") == nil)

        store.createRevision()

        XCTAssertTrue(store.getValue(key: "test") == "test")
    }

    func testThatValuesArePoppedCorrectly() {
        let store = EmbarkStore()
        store.setValue(key: "test", value: "test")
        store.createRevision()

        XCTAssertTrue(store.getValue(key: "test") == "test")

        store.removeLastRevision()

        XCTAssertTrue(store.getValue(key: "test") == nil)
    }

    func testHandlesArrayKVs() {
        let store = EmbarkStore()
        store.setValue(key: "[test,test2]", value: "[mock,mock2]")
        store.createRevision()
        XCTAssertTrue(store.getValue(key: "test") == "mock")
        XCTAssertTrue(store.getValue(key: "test2") == "mock2")
    }

    func testAlwaysKeepsOneRevision() {
        let store = EmbarkStore()
        store.createRevision()
        store.createRevision()
        store.removeLastRevision()
        store.removeLastRevision()
        store.removeLastRevision()
        XCTAssertTrue(store.revisions.count == 1)
    }

    func testComputedValues() {
        let store = EmbarkStore()

        store.computedValues = [
            "fish": "mock - 20 - 10",
            "fish2": "fish + 20",
            "fish3": "fish + 20 ++ 'hej'",
        ]
        store.setValue(key: "mock", value: "100")
        store.createRevision()

        XCTAssertEqual(store.getValue(key: "fish"), "70.0")
        XCTAssertEqual(store.getValue(key: "fish2"), "90.0")
        XCTAssertEqual(store.getValue(key: "fish3"), "90.0hej")
    }

    func testAddMultiActionObject() {
        let store = EmbarkStore()

        store.addMultiActionItems(
            actionKey: "actionKey",
            componentValues: [["type": "garage", "size": "big"],
                              ["type": "sauna", "size": "40"]]
        ) {
            store.createRevision()
        }

        XCTAssertEqual(store.getValue(key: "actionKey[0]type"), "garage")
        XCTAssertEqual(store.getValue(key: "actionKey[0]size"), "big")
        XCTAssertEqual(store.getValue(key: "actionKey[1]type"), "sauna")
        XCTAssertEqual(store.getValue(key: "actionKey[1]size"), "40")
    }
}
