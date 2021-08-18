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
}
