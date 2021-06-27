import Flow
import Foundation
import XCTest

@testable import hCore

final class MonetaryAmountTests: XCTestCase {
	func testFormattedAmount() {
		let sekAmount = MonetaryAmount(amount: "100.0", currency: "SEK")
		XCTAssertEqual(sekAmount.formattedAmount, "100 kr")

		let nokAmount = MonetaryAmount(amount: "100.0", currency: "NOK")
		XCTAssertEqual(nokAmount.formattedAmount, "kr100")

		let unknownAmount = MonetaryAmount(amount: "100.0", currency: "USD")
		XCTAssertEqual(unknownAmount.formattedAmount, "$100")
	}
}
