import Apollo
import Foundation
import XCTest

@testable import Embark

final class ResultMapTests: XCTestCase {
    override func setUp() { super.setUp() }
    
    override func tearDown() { super.tearDown() }
    
    func testThatResultMapCanFindArrays() {
        let map: ResultMap = [
            "hello": [
                [
                    "mock": "value"
                ]
            ],
            "another_array": [
                "1",
                "2",
                "3",
            ],
            "thirdArray": Array(repeating: "2", count: 100),
        ]
        
        XCTAssertEqual(map.deepFind("hello[0].mock") as? String, "value")
        XCTAssertEqual(map.deepFind("another_array[1]") as? String, "2")
        XCTAssertEqual(map.deepFind("thirdArray[99]") as? String, "2")
        XCTAssertEqual(map.deepFind("thirdArray[120]") as? String, nil)
    }
    
    func testLodash_Basic() {
        let map = GraphQLMap()

        let newMap = map.lodash_set(path: "input.payload[0].lastName", value: "Hedvigsen")
        
        let expectedMap: GraphQLMap = [
            "input" :
                ["payload":
                    [
                        [
                            "lastName" : "Hedvigsen"
                        ]
                    ]
                ]
        ]
        
        XCTAssertEqual(newMap.jsonObject.prettyPrinted, expectedMap.jsonObject.prettyPrinted)
    }
    
    func testLodash_DeepArrayAppend() {
        var map = GraphQLMap()
        map["input"] =
            ["payload" :
                [
                    [
                        "data":
                        [
                            "type":"House",
                            "lastName": "Hedvigsen"
                        ]
                    ]
            ]
        ]
        
        let expectedMap: GraphQLMap = [
            "input" :
                ["payload":
                    [
                        ["data" : [
                            "type" : "House",
                            "lastName": "Hedvigsen"
                        ]],
                        ["data" : [
                            "type" : "Bloop"
                        ]]
                    ]
                ]
        ]
        
        let newMap = map.lodash_set(path: "input.payload[1].data.type", value: "Bloop")
    
        XCTAssertEqual(newMap.jsonObject.prettyPrinted, expectedMap.jsonObject.prettyPrinted)
    }
}

private extension String {
    func getArrayPathAndIndex() -> (String, String)? {
        let arrayRegex = "\\[[0-9]+\\]$"
        
        if range(of: ".*\(arrayRegex)", options: .regularExpression) != nil,
           let rangeOfIndex = range(of: arrayRegex, options: .regularExpression)
        {
            let index = String(self[rangeOfIndex].dropFirst().dropLast())
            
            let pathWithoutIndex = String(self.replacingCharacters(in: rangeOfIndex, with: ""))
            
            return (pathWithoutIndex, index)
        }
        
        return nil
    }
    
    func isIndex() -> Bool {
        if let index = Int(self), index > -1 {
            return true
        } else {
            return false
        }
    }
}
