import Flow
import Foundation
import XCTest

@testable import hCore

final class L10nDerivationTests: XCTestCase {
	func test() {
		let l10nText = L10n.aboutLanguageRow
		XCTAssertEqual(l10nText, l10nText.derivedFromL10n?.render())
	}
}
