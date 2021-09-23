import Flow
import Foundation
import SnapshotTesting
import Testing
import TestingUtil
import XCTest
import hCoreUI
import hGraphQL

@testable import Contracts
import SwiftUI

final class ContractRowTests: XCTestCase {
    let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func assert(_ row: ContractRow) {
        assertSnapshot(
            matching: row,
            as: .image(layout: .fixed(width: 375, height: 200)),
            named: "\(row.contract.displayName)_\(row.contract.currentAgreement.status!)"
        )

        assertSnapshot(
            matching: row.colorScheme(.dark),
            as: .image(layout: .fixed(width: 375, height: 200)),
            named: "\(row.contract.displayName)_\(row.contract.currentAgreement.status!)_dark"
        )
    }

    func testContractRow() {
        let activeContractRow = ContractRow(
            contract: .mock(displayName: "NorwegianHome", status: .active)
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
            contractPerils: [],
            insurableLimits: [],
            termsAndConditions: .mock(),
            currentAgreement: .mock(status: status),
            statusPills: ["TERMINATED"],
            detailPills: ["ADDRESS", "COVERS YOU + 2"]
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
