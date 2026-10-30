import Testing
import hCore

@testable import TerminateContracts

final class TerminationSuggestionTests {
    @Test
    func buttonTitleUsesActionTextWhenProvided() {
        let suggestion = TerminationSuggestion(
            type: .downgradePrice,
            description: "We can offer you a better price",
            actionText: "Change amount",
            url: nil
        )
        #expect(suggestion.buttonTitle == "Change amount")
    }

    @Test
    func buttonTitleFallsBackToTypeWhenActionTextIsMissing() {
        let upgradeCoverage = TerminationSuggestion(
            type: .upgradeCoverage,
            description: "We can offer better coverage",
            url: nil
        )
        #expect(upgradeCoverage.buttonTitle == L10n.terminationOfferButtonChangeTier)

        let updateAddress = TerminationSuggestion(
            type: .updateAddress,
            description: "We can move your insurance",
            url: nil
        )
        #expect(updateAddress.buttonTitle == L10n.terminationOfferButtonUpdateAddress)

        let redirect = TerminationSuggestion(
            type: .redirect,
            description: "Read more about your options",
            url: "https://www.hedvig.com"
        )
        #expect(redirect.buttonTitle == L10n.terminationFlowLearnMore)
    }
}
