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
    
    func testLodash() {
        var map = GraphQLMap()
        map["input.payload[1].lastName"] = "Hedvigsen"
        
        let newMap = map.nest()
        
        let expectedMap: ResultMap = [
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
    
    func testLodash_MultipleKeyValuePairs() {
        var map = [String:Any]()
//        map["input.payload[0].data.type"] = "House"
//        map["input.payload[0].data.lastName"] = "Hedvig"
//        map["input.payload[1].data.type"] = "Bloop"
        
        //        let sorted = map.arrayOfKeyValues()
        //        var resultMap = GraphQLMap()
        //
        //        let mapped = GraphQLMap.deepMerge(resultMap, map)
        map["a"] = ["b": [["c":0]]]
        
        let expectedMap: ResultMap = [
            "input" :
                ["payload":
                    [
                        ["data" : [
                            "type" : "House",
                            "laseName": "Hedvigsen"
                        ]],
                        ["data" : [
                            "type" : "Bloop"
                        ]]
                    ]
                ]
        ]
        
        let paths = "a.b[1].c"
        let expectedCasted = ["a","b","0","c"]
        
        var test = lodash_set(map: map, path: paths, value: 1)
        
        func castedPath(_ path: String) -> [PathType] {
            let paths = path.components(separatedBy: ".")
            var newArray = [PathType]()
            paths.enumerated().forEach { pathIndex, path in
                if let (path, index) = path.getArrayPathAndIndex(), let intValue = Int(index) {
                    newArray.append(.array(index: intValue, path: path))
                } else if pathIndex == (paths.count - 1) {
                    newArray.append(.last(path: path))
                } else {
                    newArray.append(.normal(path: path))
                }
            }
            return newArray
        }
        
        enum LodashSet {
            case array(Int)
            case nestedValues([String:Any])
            case newMap
            case assignValue(Any)
        }
        
        enum PathType {
            case normal(path: String)
            case array(index: Int, path: String)
            case last(path: String)
        }
        
        func lodash_set(map: [String:Any], path: String, value: Any) -> [String:Any] {
            var castPath = castedPath(path)
            
            let lastIndex = castPath.count - 1
            var nested = map
            var currentValue = [String:Any]()
            
            let returnMap = setMap(originalMap: nested, accumulatedMap: &currentValue, paths: &castPath, value: value)
            
            return returnMap
        }
        
        func setMap(originalMap: [String:Any]?, accumulatedMap: inout [String:Any], paths: inout [PathType], value: Any) -> [String:Any] {
            let path = paths.removeFirst()
            
            switch path {
            case .normal(let path):
                if var hasValue = originalMap?[path] as? [String:Any] {
                    accumulatedMap[path] = setMap(originalMap: hasValue, accumulatedMap: &hasValue, paths: &paths, value: value)
                } else {
                    var newMap = [String:Any]()
                    accumulatedMap[path] = setMap(originalMap: nil, accumulatedMap: &newMap, paths: &paths, value: value)
                }
            case .array(index: let index, path: let path):
                if var hasValue = originalMap?[path] as? [[String:Any]] {
                    if (hasValue.count - 1) >= index {
                        hasValue[index] = setMap(originalMap: hasValue[index], accumulatedMap: &hasValue[index], paths: &paths, value: value)
                        accumulatedMap[path] = hasValue
                    } else {
                        var newMap = [String:Any]()
                        hasValue.append(setMap(originalMap: nil, accumulatedMap: &newMap, paths: &paths, value: value))
                        accumulatedMap[path] = hasValue
                    }
                } else {
                    accumulatedMap[path] = [[String:Any]]()
                }
            case .last(let path):
                accumulatedMap[path] = value
                return accumulatedMap
            }
            
            return accumulatedMap
        }
        
        func assignMapValue(_ map: [String:Any?], _ key: String, _ lodashSet: LodashSet) -> [String:Any] {
            var newMap = [String:Any]()
            switch lodashSet {
            case .array(let index):
                if let valueArray = map[key] as? [GraphQLMap] {
                    newMap[key] = valueArray[index]
                }
            case .nestedValues(let graphQLMap):
                newMap[key] = graphQLMap
            case .newMap:
                newMap[key] = [String:Any]()
            case .assignValue(let value):
                newMap[key] = value
            }
            return newMap
        }
        
        XCTAssertEqual(paths, "expectedCasted")
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
