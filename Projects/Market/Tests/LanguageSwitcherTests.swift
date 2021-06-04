import Flow
import Form
import Foundation
import SnapshotTesting
import Testing
import XCTest
import hCore

@testable import Market

final class LanguageSwitcherTests: XCTestCase {
	let bag = DisposeBag()

	override func setUp() {
		super.setUp()
		setupScreenShotTests()
		DefaultStyling.installCustom()
	}

	func testRendersCorrectOptions() {
		Localization.Locale.currentLocale = .en_SE

		let viewControllerSE = LanguageSwitcher().materialize(into: bag)
		assertSnapshot(matching: viewControllerSE, as: .image(on: .iPhoneX))

		Localization.Locale.currentLocale = .da_DK

		let viewControllerDK = LanguageSwitcher().materialize(into: bag)
		assertSnapshot(matching: viewControllerDK, as: .image(on: .iPhoneX))

		Localization.Locale.currentLocale = .nb_NO

		let viewControllerNO = LanguageSwitcher().materialize(into: bag)
		assertSnapshot(matching: viewControllerNO, as: .image(on: .iPhoneX))
	}
}
