import Flow
import Form
import Foundation
import hCoreUI
import SnapshotTesting
import Testing
import XCTest

@testable import Forever

final class InvitationRowTests: XCTestCase {
	override func setUp() {
		super.setUp()
		setupScreenShotTests()
		DefaultStyling.installCustom()
	}

	func setupTableKit(holdIn bag: DisposeBag) -> TableKit<EmptySection, InvitationRow> {
		let tableKit = TableKit<EmptySection, InvitationRow>(holdIn: bag)
		bag += tableKit.delegate.heightForCell.set { index -> CGFloat in tableKit.table[index].cellHeight }

		tableKit.view.snp.makeConstraints { make in make.height.equalTo(400)
			make.width.equalTo(300)
		}

		return tableKit
	}

	func testPendingState() {
		let invitationRow = InvitationRow(
			invitation: .init(name: "mock", state: .pending, discount: .sek(10), invitedByOther: false)
		)

		let bag = DisposeBag()

		let tableKit = setupTableKit(holdIn: bag)

		tableKit.table = Table(rows: [invitationRow])

		assertSnapshot(matching: tableKit.view, as: .image)

		bag.dispose()
	}

	func testActiveState() {
		let invitationRow = InvitationRow(
			invitation: .init(name: "mock", state: .active, discount: .sek(10), invitedByOther: false)
		)

		let bag = DisposeBag()

		let tableKit = setupTableKit(holdIn: bag)

		tableKit.table = Table(rows: [invitationRow])

		assertSnapshot(matching: tableKit.view, as: .image)

		bag.dispose()
	}

	func testTerminatedState() {
		let invitationRow = InvitationRow(
			invitation: .init(name: "mock", state: .terminated, discount: .sek(10), invitedByOther: false)
		)

		let bag = DisposeBag()

		let tableKit = setupTableKit(holdIn: bag)

		tableKit.table = Table(rows: [invitationRow])

		assertSnapshot(matching: tableKit.view, as: .image)

		bag.dispose()
	}

	func testTerminatedStateWithInvited() {
		let invitationRow = InvitationRow(
			invitation: .init(name: "mock", state: .terminated, discount: .sek(10), invitedByOther: true)
		)

		let bag = DisposeBag()

		let tableKit = setupTableKit(holdIn: bag)

		tableKit.table = Table(rows: [invitationRow])

		assertSnapshot(matching: tableKit.view, as: .image)

		bag.dispose()
	}
}
