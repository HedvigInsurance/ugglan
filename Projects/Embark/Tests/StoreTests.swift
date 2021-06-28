import Foundation
import XCTest

@testable import Embark

final class StoreTests: XCTestCase {
    override func setUp() { super.setUp() }
    
    override func tearDown() { super.tearDown() }
    
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
        
        store.computedValues = ["fish": "mock - 20 - 10", "fish2": "fish + 20", "fish3": "fish + 20 ++ 'hej'"]
        store.setValue(key: "mock", value: "100")
        store.createRevision()
        
        XCTAssertEqual(store.getValue(key: "fish"), "70.0")
        XCTAssertEqual(store.getValue(key: "fish2"), "90.0")
        XCTAssertEqual(store.getValue(key: "fish3"), "90.0hej")
    }
    
    // Store input
    let actionKey = "addBuilding"
    
    let componentValues = [[
                            "numberAction":"10",
                            "switchAction":"true",
                            "dropDownAction":"garage",
                            "dropDownAction.Label":"GARAGE"],
                           ["numberAction":"12",
                            "switchAction":"false",
                            "dropDownAction":"shed",
                            "dropDownAction.Label":"GARAGE"],
                           ["numberAction":"14",
                            "switchAction":"true",
                            "dropDownAction":"gazebo",
                            "dropDownAction.Label":"GARAGE"]]
    
    let storedMultiActionValues = ["addBuilding[0]numberAction":"10",
                                 "addBuilding[0]switchAction":"true",
                                 "addBuilding[0]dropDownAction":"garage",
                                 "addBuilding[0]dropDownAction.Label":"GARAGE",
                                 "addBuilding[1]numberAction":"12",
                                 "addBuilding[1]switchAction":"false",
                                 "addBuilding[1]dropDownAction":"shed",
                                 "addBuilding[1]dropDownAction.Label":"GARAGE",
                                 "addBuilding[2]numberAction":"14",
                                 "addBuilding[2]switchAction":"true",
                                 "addBuilding[2]dropDownAction":"gazebo",
                                 "addBuilding[2]dropDownAction.Label":"GARAGE"]
    
    private let mockedData = MultiActionData(addLabel: "asd", key: "asd", maxAmount: "4", link: .init(name: "", label: ""), components: [])
    
    func testAddMutliAction() {
        let store = EmbarkStore()
        
        store.addMultiActionItems(actionKey: actionKey, componentValues: componentValues) {}
        
        store.createRevision()
        
        let storeValues = store.getAllValues()
        
        XCTAssertEqual(storedMultiActionValues, storeValues)
    }
    
    func testGetMultiActionItems() {
        let store = EmbarkStore()
        
        store.addMultiActionItems(actionKey: actionKey, componentValues: componentValues) {}
        
        let values = store.getComponentValues(actionKey: actionKey, data: mockedData).map { dic in
            return dic.reduce([String:String]()) { (dict, values) in
                var dict = dict
                dict[values.key] = values.value.inputValue
                return dict
            }
        }
        
        XCTAssertEqual(values, componentValues)
    }
}
