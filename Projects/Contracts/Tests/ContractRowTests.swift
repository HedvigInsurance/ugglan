import Flow
import Foundation
import Presentation
import SnapshotTesting
import SwiftUI
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

    func assert(_ row: ContractRow, _ contract: Contract) {
        assertSnapshot(
            matching: row,
            as: .image(layout: .fixed(width: 375, height: 200)),
            named: "\(contract.displayName)_\(contract.currentAgreement!.status!)"
        )

        assertSnapshot(
            matching: row.colorScheme(.dark),
            as: .image(layout: .fixed(width: 375, height: 200)),
            named: "\(contract.displayName)_\(contract.currentAgreement!.status!)_dark"
        )
    }

    func testContractRow() {
        let mockContract = Contract.mock(displayName: "NorwegianHome", status: .active)

        let activeContractRow = ContractRow(
            id: mockContract.id
        )

        assert(activeContractRow, mockContract)
    }
}

extension Contract {
    public static func mock(displayName: String, status: ContractStatus) -> Contract {
        let contract = Contract(
            id: "mock_norwegian_123",
            upcomingAgreementsTable: .mock(),
            currentAgreementsTable: .mock(),
            gradientOption: .one,
            logo: .none,
            displayName: displayName,
            switchedFromInsuranceProvider: nil,
            upcomingRenewal: nil,
            contractPerils: [],
            insurableLimits: [],
            termsAndConditions: .mock(),
            currentAgreement: .mock(status: status),
            statusPills: ["TERMINATED"],
            detailPills: ["ADDRESS", "COVERS YOU + 2"]
        )

        let store: ContractStore = globalPresentableStoreContainer.get()
        var state = ContractState()
        state.contracts = [
            contract
        ]

        store.setState(state)

        return contract
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
