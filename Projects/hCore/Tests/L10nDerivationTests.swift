import Flow
import Foundation
@testable import hCore
import XCTest

final class L10nDerivationTests: XCTestCase {
    func test() {
        let l10nText = L10n.aboutLanguageRow
        XCTAssertEqual(l10nText, l10nText.derivedFromL10n?.render())
    }
}
