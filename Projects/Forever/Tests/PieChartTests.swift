import Flow
import Form
import Foundation
import SnapshotTesting
import Testing
import XCTest
import hCoreUI

@testable import Forever

final class PieChartTests: XCTestCase {
	override func setUp() {
		super.setUp()
		setupScreenShotTests()
		DefaultStyling.installCustom()
	}

	func test() {
		let pieChart = PieChart(stateSignal: .init(.init(percentagePerSlice: 0.25, slices: 2)), animated: false)

		materializeViewable(pieChart) { view in
			view.snp.makeConstraints { make in make.width.height.equalTo(215) }

			assertSnapshot(matching: view, as: .image)

			pieChart.stateSignal.value = .init(percentagePerSlice: 0.05, slices: 10)
			assertSnapshot(matching: view, as: .image)

			pieChart.stateSignal.value = .init(percentagePerSlice: 0.05, slices: 5)
			assertSnapshot(matching: view, as: .image)

			pieChart.stateSignal.value = .init(percentagePerSlice: 0.05, slices: 12)
			assertSnapshot(matching: view, as: .image)

			pieChart.stateSignal.value = .init(percentagePerSlice: 0.5, slices: 2)
			assertSnapshot(matching: view, as: .image)

			pieChart.stateSignal.value = .init(percentagePerSlice: 0.5, slices: 1.5)
			assertSnapshot(matching: view, as: .image)

			pieChart.stateSignal.value = .init(percentagePerSlice: 0.05, slices: 1.5)
			assertSnapshot(matching: view, as: .image)

			pieChart.stateSignal.value = .init(
				grossAmount: .sek(100),
				netAmount: .sek(50),
				potentialDiscountAmount: .sek(10)
			)
			assertSnapshot(matching: view, as: .image)

			pieChart.stateSignal.value = .init(
				grossAmount: .sek(1000),
				netAmount: .sek(5),
				potentialDiscountAmount: .sek(10)
			)
			assertSnapshot(matching: view, as: .image)
		}
	}

	func testMoneyToPieChartState() {
		let state = PieChartState(
			grossAmount: .sek(1000),
			netAmount: .sek(5),
			potentialDiscountAmount: .sek(10)
		)
		XCTAssert(state.percentagePerSlice == 0.01)
		XCTAssert(state.slices == 99.5)

		let state2 = PieChartState(
			grossAmount: .sek(100),
			netAmount: .sek(90),
			potentialDiscountAmount: .sek(10)
		)
		XCTAssert(state2.percentagePerSlice == 0.1)
		XCTAssert(state2.slices == 1)
	}
}
