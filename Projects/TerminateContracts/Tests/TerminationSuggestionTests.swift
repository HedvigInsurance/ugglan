import XCTest
import hCore

@testable import TerminateContracts

final class TerminationSuggestionTests: XCTestCase {
    func testButtonTitle_usesActionTextWhenProvided() {
        let suggestion = TerminationSuggestion(
            type: .downgradePrice,
            description: "We can offer you a better price",
            actionText: "Change amount",
            url: nil
        )
        XCTAssertEqual(suggestion.buttonTitle, "Change amount")
    }

    func testButtonTitle_fallsBackToTypeWhenActionTextIsMissing() {
        let upgradeCoverage = TerminationSuggestion(
            type: .upgradeCoverage,
            description: "We can offer better coverage",
            url: nil
        )
        XCTAssertEqual(upgradeCoverage.buttonTitle, L10n.terminationOfferButtonChangeTier)

        let updateAddress = TerminationSuggestion(
            type: .updateAddress,
            description: "We can move your insurance",
            url: nil
        )
        XCTAssertEqual(updateAddress.buttonTitle, L10n.terminationOfferButtonUpdateAddress)

        let redirect = TerminationSuggestion(
            type: .redirect,
            description: "Read more about your options",
            url: "https://www.hedvig.com"
        )
        XCTAssertEqual(redirect.buttonTitle, L10n.terminationFlowLearnMore)
    }

    func testButtonTitle_fallsBackToTypeWhenActionTextIsEmpty() {
        let suggestion = TerminationSuggestion(
            type: .downgradePrice,
            description: "We can offer you a better price",
            actionText: "",
            url: nil
        )
        XCTAssertEqual(suggestion.buttonTitle, L10n.terminationOfferButtonChangeTier)
    }
}
