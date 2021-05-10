import Flow
import ForeverTesting
import Form
import Foundation
import hCoreUI
import SnapshotTesting
import Testing
import XCTest

@testable import Forever

final class DiscountCodeSectionTests: XCTestCase {
	override func setUp() {
		super.setUp()
		setupScreenShotTests()
		DefaultStyling.installCustom()
	}

	func testScreenshot() {
		let data = ForeverData(
			grossAmount: .sek(0),
			netAmount: .sek(0),
			potentialDiscountAmount: .sek(10),
			discountCode: "MOCK",
			invitations: []
		)
		let service = MockForeverService(data: data)

		let discountCodeSection = DiscountCodeSection(service: service)

		materializeViewable(discountCodeSection) { view in
			view.snp.makeConstraints { make in make.width.equalTo(300) }

			assertSnapshot(matching: view, as: .image)
		}
	}
}
