import Foundation
import XCTest
@testable import Embark

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
}
