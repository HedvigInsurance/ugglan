import Testing

@testable import hCore

extension HCoreDependencySuite {
    @MainActor
    final class L10nDerivationTests {
        @Test
        func renderReproducesTranslation() throws {
            // Long enough to be heap-allocated: a small string bridges to a fresh object on every access.
            let l10nText = L10n.General.errorBody
            let derivation = try #require(l10nText.derivedFromL10n)
            #expect(l10nText == derivation.render())
        }
    }
}
