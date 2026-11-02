import Foundation
import Testing

@testable import hCore

extension HCoreDependencySuite {
    @MainActor
    final class MonetaryAmountTests {
        @Test
        func formattedAmount() {
            let sekAmount = MonetaryAmount(amount: "100.0", currency: "SEK")
            #expect(sekAmount.formattedAmount == "100 kr")
        }

        @Test
        func formattedAmountFallsBackToCurrentLocale() {
            let savedLocale = Localization.Locale.currentLocale.value
            defer { Localization.Locale.currentLocale.value = savedLocale }

            Localization.Locale.currentLocale.value = .sv_SE
            let unknownAmount = MonetaryAmount(amount: "100.0", currency: "USD")
            #expect(unknownAmount.formattedAmount == "100 US$")
        }
    }
}
