import Foundation
@preconcurrency import XCTest

@testable import EditStakeholders

@MainActor
final class ContractsEditInsuredCompleteListTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testUpcomingZeroCurrentOneSuccess() {
        let viewModel = StakeholderListViewModel(with: .init(stakeholders: [Stakeholder.testMemberWithSSN5]))

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = []
        let list = viewModel.completeList()
        XCTAssert(list.count == 1)
    }

    func testUpcomingTwoCoInsuredMissingDataWithCurrentWithTwoCoInsuredSuccess() {
        let viewModel = StakeholderListViewModel(
            with: .init(stakeholders: [
                Stakeholder.testMemberWithSSN5,
                Stakeholder.testMemberWithSSN4,
            ])
        )

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = [
            Stakeholder.testMemberWithSSN5,
            Stakeholder.testMemberWithSSN4,
        ]

        let list = viewModel.completeList()
        XCTAssert(list.count == 0)
    }

    func testCurrentWith4EmptyDataUpcomingThreeSuccess() {
        let viewModel = StakeholderListViewModel(
            with: .init(stakeholders: [
                Stakeholder.mockMissingData(),
                Stakeholder.mockMissingData(),
                Stakeholder.mockMissingData(),
                Stakeholder.mockMissingData(),
            ])
        )

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = []
        let list = viewModel.completeList()
        XCTAssert(list.count == 4)
    }

    func testCurrentFourEmptyUpcomingFourWithValueAddedOne() {
        let viewModel = StakeholderListViewModel(
            with: .init(
                stakeholders: [
                    Stakeholder.mockMissingData(),
                    Stakeholder.mockMissingData(),
                    Stakeholder.mockMissingData(),
                    Stakeholder.mockMissingData(),
                ],
                numberOfMissingStakeholdersWithoutTermination: 4
            )
        )

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = [
            Stakeholder.mockMissingData()
        ]

        let list = viewModel.completeList()
        XCTAssert(list.count == 3)
    }

    func testCurrentTwoWithValuesAddingThreeWithValues() {
        let viewModel = StakeholderListViewModel(
            with: .init(stakeholders: [
                Stakeholder.testMemberWithSSN4,
                Stakeholder.testMemberWithSSN5,
            ])
        )

        viewModel.stakeholdersAdded = [
            Stakeholder.testMemberWithSSN1,
            Stakeholder.testMemberWithSSN2,
            Stakeholder.testMemberWithSSN3,
        ]
        viewModel.stakeholdersDeleted = []
        let list = viewModel.completeList()
        XCTAssert(list.count == 5)
    }

    func testInitialWithTwoAdded() {
        let viewModel = StakeholderListViewModel(
            with: .init(
                stakeholders: [
                    Stakeholder.mockMissingData(),
                    Stakeholder.mockMissingData(),
                ],
                numberOfMissingStakeholdersWithoutTermination: 2
            )
        )

        viewModel.stakeholdersAdded = [Stakeholder.testMemberWithSSN1, Stakeholder.testMemberWithSSN2]
        viewModel.stakeholdersDeleted = []

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
        XCTAssert(list[0] == Stakeholder.testMemberWithSSN1)
        XCTAssert(list[1] == Stakeholder.testMemberWithSSN2)
    }

    func testInitialWithOneDeleted() {
        let viewModel = StakeholderListViewModel(
            with: .init(
                stakeholders: [
                    Stakeholder.mockMissingData(),
                    Stakeholder.mockMissingData(),
                ],
                numberOfMissingStakeholdersWithoutTermination: 2
            )
        )

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = [Stakeholder.mockMissingData()]

        let list = viewModel.completeList()
        XCTAssert(list.count == 1)
        XCTAssert(list[0] == Stakeholder.mockMissingData())
    }

    func testInitialAllDeleted() {
        let viewModel = StakeholderListViewModel(
            with: .init(stakeholders: [
                Stakeholder.mockMissingData(),
                Stakeholder.mockMissingData(),
            ])
        )

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = [Stakeholder.mockMissingData(), Stakeholder.mockMissingData()]

        let list = viewModel.completeList()
        XCTAssert(list.count == 0)
    }

    func testRemoveOne() {
        let viewModel = StakeholderListViewModel(
            with: .init(stakeholders: [
                Stakeholder.testMemberWithSSN1,
                Stakeholder.testMemberWithSSN2,
                Stakeholder.testMemberWithBirthdate2,
            ])
        )

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = [Stakeholder.testMemberWithBirthdate2]

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
    }

    func testEmptyWithTerminationAndMissingData() {
        let viewModel = StakeholderListViewModel(
            with: .init(
                stakeholders: [
                    Stakeholder.mockMissingData(),
                    Stakeholder.mockMissingData(),
                    Stakeholder.testMemberEmptyTerminated,
                ],
                numberOfMissingStakeholdersWithoutTermination: 2
            )
        )

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = [Stakeholder.mockMissingData()]

        let list = viewModel.completeList()
        XCTAssert(list.count == 1)
        XCTAssert(list[0] == Stakeholder.mockMissingData())
    }

    func testEmptyWithTerminationAndAddedData() {
        let viewModel = StakeholderListViewModel(
            with: .init(stakeholders: [
                Stakeholder.testMemberWithSSN1,
                Stakeholder.testMemberWithBirthdate1,
                Stakeholder.testMemberEmptyTerminated,
            ])
        )

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = []

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
    }

    func testEmptyWithTerminationAndAddingData() {
        let viewModel = StakeholderListViewModel(
            with: .init(
                stakeholders: [
                    Stakeholder.mockMissingData(),
                    Stakeholder.mockMissingData(),
                    Stakeholder.testMemberEmptyTerminated,
                ],
                numberOfMissingStakeholdersWithoutTermination: 2
            )
        )

        viewModel.stakeholdersAdded = [
            Stakeholder.testMemberWithSSN1,
            Stakeholder.testMemberWithBirthdate1,
        ]
        viewModel.stakeholdersDeleted = []

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
        XCTAssert(list[0] == Stakeholder.testMemberWithSSN1)
        XCTAssert(list[1] == Stakeholder.testMemberWithBirthdate1)
    }
}

@MainActor
extension Stakeholder {
    static let testMemberWithSSN1 = Stakeholder(
        firstName: "Test",
        lastName: "Testsson",
        SSN: "199009016830",
        birthDate: "1990-09-01"
    )
    static let testMemberWithSSN2 = Stakeholder(
        firstName: "Hedvig",
        lastName: "Testsson",
        SSN: "199109016830",
        birthDate: "1991-09-01"
    )
    static let testMemberWithSSN3 = Stakeholder(
        firstName: "A",
        lastName: "B",
        SSN: "199209016830",
        birthDate: "1992-09-01"
    )
    static let testMemberWithSSN4 = Stakeholder(
        firstName: "B",
        lastName: "A",
        SSN: "199309016830",
        birthDate: "1993-09-01"
    )
    static let testMemberWithSSN5 = Stakeholder(
        firstName: "C",
        lastName: "D",
        SSN: "199409016830",
        birthDate: "1994-09-01"
    )

    static let testMemberWithBirthdate1 = Stakeholder(
        firstName: "Test",
        lastName: "Testsson",
        SSN: nil,
        birthDate: "1990-09-01"
    )
    static let testMemberWithBirthdate2 = Stakeholder(
        firstName: "Test",
        lastName: "Testsson",
        SSN: nil,
        birthDate: "1991-09-01"
    )
    static let testMemberWithBirthdate3 = Stakeholder(
        firstName: "Test",
        lastName: "Testsson",
        SSN: nil,
        birthDate: "1992-09-01"
    )

    static let testMemberEmptyTerminated = Stakeholder(
        firstName: nil,
        lastName: nil,
        SSN: nil,
        birthDate: nil,
        terminatesOn: "2023-12-11"
    )

    static func mock(withSSN ssn: String) -> Stakeholder {
        Stakeholder(
            firstName: "",
            lastName: "",
            SSN: ssn,
            birthDate: ""
        )
    }

    static func mock(withBirthday birthday: String) -> Stakeholder {
        Stakeholder(
            firstName: "",
            lastName: "",
            SSN: nil,
            birthDate: birthday
        )
    }

    static func mockMissingData() -> Stakeholder {
        Stakeholder()
    }
}

@MainActor
extension StakeholdersConfig {
    init(
        stakeholders: [Stakeholder],
        numberOfMissingStakeholdersWithoutTermination: Int = 0,
        stakeholderType: StakeholderType = .coInsured,
    ) {
        self.init(
            id: "",
            stakeholders: stakeholders,
            contractId: "",
            activeFrom: "",
            numberOfMissingStakeholders: 0,
            numberOfMissingStakeholdersWithoutTermination: numberOfMissingStakeholdersWithoutTermination,
            displayName: "",
            exposureDisplayName: "",
            preSelectedStakeholders: [],
            contractDisplayName: "",
            holderFirstName: "",
            holderLastName: "",
            holderSSN: "",
            fromInfoCard: false,
            stakeholderType: stakeholderType
        )
    }
}
