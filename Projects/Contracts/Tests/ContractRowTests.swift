import ContractsTesting
import Flow
import Foundation
import SnapshotTesting
import Testing
import TestingUtil
import XCTest
import hCoreUI

@testable import Contracts

final class ContractRowTests: XCTestCase {
	let bag = DisposeBag()

	override func setUp() {
		super.setUp()
		setupScreenShotTests()
	}

	func assert(_ row: ContractRow) {
		let view = row.reuseType(bag: bag)

		view.snp.makeConstraints { make in make.width.equalTo(400) }

		assertSnapshot(
			matching: view,
			as: .image,
			named: "\(row.displayName)_\(row.contract.status.__typename)"
		)

		view.overrideUserInterfaceStyle = .dark

		assertSnapshot(
			matching: view,
			as: .image,
			named: "\(row.displayName)_\(row.contract.status.__typename)_dark"
		)
	}

	func testNorwegianHome() {
		let activeContractRow = ContractRow(
			contract: try! .init(
				jsonObject: .makeNorwegianHomeContentContract(status: .makeActiveStatus())
			),
			displayName: "NorwegianHome",
            type: .norwegianHome,
            state: ContractsState()
		)

		assert(activeContractRow)

		let activeInFutureContractRow = ContractRow(
			contract: try! .init(
				jsonObject: .makeNorwegianHomeContentContract(
					status: .makeActiveInFutureStatus(futureInception: "2020-02-10")
				)
			),
			displayName: "NorwegianHome",
            type: .norwegianHome,
            state: ContractsState()
		)

		assert(activeInFutureContractRow)

		let pendingContractRow = ContractRow(
			contract: try! .init(
				jsonObject: .makeNorwegianHomeContentContract(status: .makePendingStatus())
			),
			displayName: "NorwegianHome",
            type: .norwegianHome,
            state: ContractsState()
		)

		assert(pendingContractRow)

		let activeInFutureAndTerminatedInFutureContractRow = ContractRow(
			contract: try! .init(
				jsonObject: .makeNorwegianHomeContentContract(
					status: .makeActiveInFutureAndTerminatedInFutureStatus(
						futureInception: "2020-02-10",
						futureTermination: "2020-02-12"
					)
				)
			),
			displayName: "NorwegianHome",
            type: .norwegianHome,
            state: ContractsState()
		)

		assert(activeInFutureAndTerminatedInFutureContractRow)

		let terminatedContractRow = ContractRow(
			contract: try! .init(
				jsonObject: .makeNorwegianHomeContentContract(status: .makeTerminatedStatus())
			),
			displayName: "NorwegianHome",
            type: .norwegianHome,
            state: ContractsState()
		)

		assert(terminatedContractRow)
	}

	func testNorwegianTravel() {
		let activeContractRow = ContractRow(
			contract: try! .init(jsonObject: .makeNorwegianTravelContract(status: .makeActiveStatus())),
			displayName: "NorwegianTravel",
            type: .norwegianTravel,
            state: ContractsState()
		)

		assert(activeContractRow)
	}

	func testSwedishHouse() {
		let activeContractRow = ContractRow(
			contract: try! .init(jsonObject: .makeSwedishHouseContract(status: .makeActiveStatus())),
			displayName: "SwedishHouse",
            type: .norwegianTravel,
            state: ContractsState()
		)

		assert(activeContractRow)
	}
}
