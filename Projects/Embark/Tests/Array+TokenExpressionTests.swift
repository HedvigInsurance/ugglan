import Foundation
import XCTest

@testable import Embark

final class ArrayTokenExpressionTests: XCTestCase {
	override func setUp() { super.setUp() }

	override func tearDown() { super.tearDown() }

	func testExpressions() {
		XCTAssertEqual(
			"storeValue - 223.2".tokens.expression,
			.binary(
				operator: .subtraction,
				left: .store(key: "storeValue"),
				right: .number(constant: 223.2)
			)
		)

		XCTAssertEqual(
			"storeValue - 223.2 - storeValue".tokens.expression,
			.binary(
				operator: .subtraction,
				left: .binary(
					operator: .subtraction,
					left: .store(key: "storeValue"),
					right: .number(constant: 223.2)
				),
				right: .store(key: "storeValue")
			)
		)
	}
}
