@testable import Embark
import Foundation
import XCTest

final class StringTokensTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testTokens() {
        XCTAssertEqual(
            "'hej' + 300".tokens,
            [
                .stringConstant(constant: "hej"),
                .binaryOperator(operator: .addition),
                .numberConstant(constant: 300),
            ]
        )

        XCTAssertEqual(
            "storeValue + 20.2".tokens,
            [
                .storeKey(key: "storeValue"),
                .binaryOperator(operator: .addition),
                .numberConstant(constant: 20.2),
            ]
        )

        XCTAssertEqual(
            "storeValue - 223.2".tokens,
            [
                .storeKey(key: "storeValue"),
                .binaryOperator(operator: .subtraction),
                .numberConstant(constant: 223.2),
            ]
        )

        XCTAssertEqual(
            "storeValue - 223.2 - 20".tokens,
            [
                .storeKey(key: "storeValue"),
                .binaryOperator(operator: .subtraction),
                .numberConstant(constant: 223.2),
                .binaryOperator(operator: .subtraction),
                .numberConstant(constant: 20),
            ]
        )

        XCTAssertEqual(
            "storeValue-223.2".tokens,
            [
                .storeKey(key: "storeValue"),
                .binaryOperator(operator: .subtraction),
                .numberConstant(constant: 223.2),
            ]
        )
    }
}
