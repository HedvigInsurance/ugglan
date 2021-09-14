import Flow
import Foundation
import SnapshotTesting
import Testing
import TestingUtil
import XCTest
import hCoreUI
import hGraphQL

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
            named: "\(row.contract.displayName)_\(row.contract.currentAgreement.status!)"
        )

        view.overrideUserInterfaceStyle = .dark

        assertSnapshot(
            matching: view,
            as: .image,
            named: "\(row.contract.displayName)_\(row.contract.currentAgreement.status!)_dark"
        )
    }

    func testNorwegianHome() {
        let activeContractRow = ContractRow(
            contract: .mock(displayName: "NorwegianHome", status: .active)
        )

        assert(activeContractRow)

        let activeInFutureContractRow = ContractRow(
            contract: Contract.mock(displayName: "NorwegianHome", status: .activeInFuture)
        )

        assert(activeInFutureContractRow)

        let pendingContractRow = ContractRow(
            contract: Contract.mock(displayName: "NorwegianHome", status: .pending)
        )

        assert(pendingContractRow)

        let activeInFutureAndTerminatedInFutureContractRow = ContractRow(
            contract: Contract.mock(displayName: "NorwegianHome", status: .terminated)
        )

        assert(activeInFutureAndTerminatedInFutureContractRow)

        let terminatedContractRow = ContractRow(
            contract: Contract.mock(displayName: "NorwegianHome", status: .terminated)
        )

        assert(terminatedContractRow)
    }

    func testNorwegianTravel() {
        let activeContractRow = ContractRow(
            contract: Contract.mock(displayName: "NorwegianHome", status: .active)
        )

        assert(activeContractRow)
    }

    func testSwedishHouse() {
        let activeContractRow = ContractRow(
            contract: Contract.mock(displayName: "SwedishHouse", status: ContractStatus.active)
        )

        assert(activeContractRow)
    }
}

extension Contract {
    public static func mock(displayName: String, status: ContractStatus) -> Contract {
        .init(
            id: "mock_norwegian_123",
            upcomingAgreementsTable: .mock(),
            currentAgreementsTable: .mock(),
            gradientOption: .one,
            displayName: displayName,
            switchedFromInsuranceProvider: nil,
            upcomingRenewal: nil,
            perils: [],
            insurableLimits: [],
            termsAndConditions: .mock(),
            currentAgreement: .mock(status: status),
            statusPills: [],
            detailPills: []
        )
    }
}

extension DetailAgreementsTable {
    public static func mock() -> DetailAgreementsTable {
        .init(sections: [.init(title: "", rows: [])], title: "Table")
    }
}

extension TermsAndConditions {
    public static func mock() -> TermsAndConditions {
        .init(displayName: "mock", url: "https://www.mock.com/terms.pdf")
    }
}

extension CurrentAgreement {
    public static func mock(status: ContractStatus) -> CurrentAgreement {
        .init(
            certificateUrl: "https://www.mock.com/terms.pdf",
            activeFrom: nil,
            activeTo: nil,
            premium: .init(amount: "100", currency: "SEK"),
            status: status
        )
    }
}
