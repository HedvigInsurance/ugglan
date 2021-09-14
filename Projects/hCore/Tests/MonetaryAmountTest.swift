import Flow
import Foundation
import XCTest
import hGraphQL

@testable import hCore

final class MonetaryAmountTests: XCTestCase {
    func testFormattedAmount() {
        let sekAmount = MonetaryAmount(amount: "100.0", currency: "SEK")
        XCTAssertEqual(sekAmount.formattedAmount, "100 kr")

        let nokAmount = MonetaryAmount(amount: "100.0", currency: "NOK")
        XCTAssertEqual(nokAmount.formattedAmount, "kr 100")

        Localization.Locale.currentLocale = .sv_SE

        let unknownAmount = MonetaryAmount(amount: "100.0", currency: "USD")
        XCTAssertEqual(unknownAmount.formattedAmount, "100 US$")
    }
}
