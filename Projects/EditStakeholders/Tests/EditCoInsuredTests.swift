import Foundation
@preconcurrency import XCTest

@testable import EditCoInsured

@MainActor
final class ContractsEditInsuredCompleteListTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testUpcomingZeroCurrentOneSuccess() {
        let viewModel = InsuredPeopleScreenViewModel(with: .init(stakeHolders: [StakeHolder.testMemberWithSSN5]))

        viewModel.stakeHoldersAdded = []
        viewModel.stakeHoldersDeleted = []
        let list = viewModel.completeList()
        XCTAssert(list.count == 1)
    }

    func testUpcomingTwoCoInsuredMissingDataWithCurrentWithTwoCoInsuredSuccess() {
        let viewModel = InsuredPeopleScreenViewModel(
            with: .init(stakeHolders: [
                StakeHolder.testMemberWithSSN5,
                StakeHolder.testMemberWithSSN4,
            ])
        )

        viewModel.stakeHoldersAdded = []
        viewModel.stakeHoldersDeleted = [
            StakeHolder.testMemberWithSSN5,
            StakeHolder.testMemberWithSSN4,
        ]

        let list = viewModel.completeList()
        XCTAssert(list.count == 0)
    }

    func testCurrentWith4EmptyDataUpcomingThreeSuccess() {
        let viewModel = InsuredPeopleScreenViewModel(
            with: .init(stakeHolders: [
                StakeHolder.mockMissingData(),
                StakeHolder.mockMissingData(),
                StakeHolder.mockMissingData(),
                StakeHolder.mockMissingData(),
            ])
        )

        viewModel.stakeHoldersAdded = []
        viewModel.stakeHoldersDeleted = []
        let list = viewModel.completeList()
        XCTAssert(list.count == 4)
    }

    func testCurrentFourEmptyUpcomingFourWithValueAddedOne() {
        let viewModel = InsuredPeopleScreenViewModel(
            with: .init(
                stakeHolders: [
                    StakeHolder.mockMissingData(),
                    StakeHolder.mockMissingData(),
                    StakeHolder.mockMissingData(),
                    StakeHolder.mockMissingData(),
                ],
                numberOfMissingStakeHoldersWithoutTermination: 4
            )
        )

        viewModel.stakeHoldersAdded = []
        viewModel.stakeHoldersDeleted = [
            StakeHolder.mockMissingData()
        ]

        let list = viewModel.completeList()
        XCTAssert(list.count == 3)
    }

    func testCurrentTwoWithValuesAddingThreeWithValues() {
        let viewModel = InsuredPeopleScreenViewModel(
            with: .init(stakeHolders: [
                StakeHolder.testMemberWithSSN4,
                StakeHolder.testMemberWithSSN5,
            ])
        )

        viewModel.stakeHoldersAdded = [
            StakeHolder.testMemberWithSSN1,
            StakeHolder.testMemberWithSSN2,
            StakeHolder.testMemberWithSSN3,
        ]
        viewModel.stakeHoldersDeleted = []
        let list = viewModel.completeList()
        XCTAssert(list.count == 5)
    }

    func testInitialWithTwoAdded() {
        let viewModel = InsuredPeopleScreenViewModel(
            with: .init(
                stakeHolders: [
                    StakeHolder.mockMissingData(),
                    StakeHolder.mockMissingData(),
                ],
                numberOfMissingStakeHoldersWithoutTermination: 2
            )
        )

        viewModel.stakeHoldersAdded = [StakeHolder.testMemberWithSSN1, StakeHolder.testMemberWithSSN2]
        viewModel.stakeHoldersDeleted = []

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
        XCTAssert(list[0] == StakeHolder.testMemberWithSSN1)
        XCTAssert(list[1] == StakeHolder.testMemberWithSSN2)
    }

    func testInitialWithOneDeleted() {
        let viewModel = InsuredPeopleScreenViewModel(
            with: .init(
                stakeHolders: [
                    StakeHolder.mockMissingData(),
                    StakeHolder.mockMissingData(),
                ],
                numberOfMissingStakeHoldersWithoutTermination: 2
            )
        )

        viewModel.stakeHoldersAdded = []
        viewModel.stakeHoldersDeleted = [StakeHolder.mockMissingData()]

        let list = viewModel.completeList()
        XCTAssert(list.count == 1)
        XCTAssert(list[0] == StakeHolder.mockMissingData())
    }

    func testInitialAllDeleted() {
        let viewModel = InsuredPeopleScreenViewModel(
            with: .init(stakeHolders: [
                StakeHolder.mockMissingData(),
                StakeHolder.mockMissingData(),
            ])
        )

        viewModel.stakeHoldersAdded = []
        viewModel.stakeHoldersDeleted = [StakeHolder.mockMissingData(), StakeHolder.mockMissingData()]

        let list = viewModel.completeList()
        XCTAssert(list.count == 0)
    }

    func testRemoveOne() {
        let viewModel = InsuredPeopleScreenViewModel(
            with: .init(stakeHolders: [
                StakeHolder.testMemberWithSSN1,
                StakeHolder.testMemberWithSSN2,
                StakeHolder.testMemberWithBirthdate2,
            ])
        )

        viewModel.stakeHoldersAdded = []
        viewModel.stakeHoldersDeleted = [StakeHolder.testMemberWithBirthdate2]

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
    }

    func testEmptyWithTerminationAndMissingData() {
        let viewModel = InsuredPeopleScreenViewModel(
            with: .init(
                stakeHolders: [
                    StakeHolder.mockMissingData(),
                    StakeHolder.mockMissingData(),
                    StakeHolder.testMemberEmptyTerminated,
                ],
                numberOfMissingStakeHoldersWithoutTermination: 2
            )
        )

        viewModel.stakeHoldersAdded = []
        viewModel.stakeHoldersDeleted = [StakeHolder.mockMissingData()]

        let list = viewModel.completeList()
        XCTAssert(list.count == 1)
        XCTAssert(list[0] == StakeHolder.mockMissingData())
    }

    func testEmptyWithTerminationAndAddedData() {
        let viewModel = InsuredPeopleScreenViewModel(
            with: .init(stakeHolders: [
                StakeHolder.testMemberWithSSN1,
                StakeHolder.testMemberWithBirthdate1,
                StakeHolder.testMemberEmptyTerminated,
            ])
        )

        viewModel.stakeHoldersAdded = []
        viewModel.stakeHoldersDeleted = []

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
    }

    func testEmptyWithTerminationAndAddingData() {
        let viewModel = InsuredPeopleScreenViewModel(
            with: .init(
                stakeHolders: [
                    StakeHolder.mockMissingData(),
                    StakeHolder.mockMissingData(),
                    StakeHolder.testMemberEmptyTerminated,
                ],
                numberOfMissingStakeHoldersWithoutTermination: 2
            )
        )

        viewModel.stakeHoldersAdded = [
            StakeHolder.testMemberWithSSN1,
            StakeHolder.testMemberWithBirthdate1,
        ]
        viewModel.stakeHoldersDeleted = []

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
        XCTAssert(list[0] == StakeHolder.testMemberWithSSN1)
        XCTAssert(list[1] == StakeHolder.testMemberWithBirthdate1)
    }
}

@MainActor
extension StakeHolder {
    static let testMemberWithSSN1 = StakeHolder(
        firstName: "Test",
        lastName: "Testsson",
        SSN: "199009016830",
        birthDate: "1990-09-01"
    )
    static let testMemberWithSSN2 = StakeHolder(
        firstName: "Hedvig",
        lastName: "Testsson",
        SSN: "199109016830",
        birthDate: "1991-09-01"
    )
    static let testMemberWithSSN3 = StakeHolder(
        firstName: "A",
        lastName: "B",
        SSN: "199209016830",
        birthDate: "1992-09-01"
    )
    static let testMemberWithSSN4 = StakeHolder(
        firstName: "B",
        lastName: "A",
        SSN: "199309016830",
        birthDate: "1993-09-01"
    )
    static let testMemberWithSSN5 = StakeHolder(
        firstName: "C",
        lastName: "D",
        SSN: "199409016830",
        birthDate: "1994-09-01"
    )

    static let testMemberWithBirthdate1 = StakeHolder(
        firstName: "Test",
        lastName: "Testsson",
        SSN: nil,
        birthDate: "1990-09-01"
    )
    static let testMemberWithBirthdate2 = StakeHolder(
        firstName: "Test",
        lastName: "Testsson",
        SSN: nil,
        birthDate: "1991-09-01"
    )
    static let testMemberWithBirthdate3 = StakeHolder(
        firstName: "Test",
        lastName: "Testsson",
        SSN: nil,
        birthDate: "1992-09-01"
    )

    static let testMemberEmptyTerminated = StakeHolder(
        firstName: nil,
        lastName: nil,
        SSN: nil,
        birthDate: nil,
        terminatesOn: "2023-12-11"
    )

    static func mock(withSSN ssn: String) -> StakeHolder {
        StakeHolder(
            firstName: "",
            lastName: "",
            SSN: ssn,
            birthDate: ""
        )
    }

    static func mock(withBirthday birthday: String) -> StakeHolder {
        StakeHolder(
            firstName: "",
            lastName: "",
            SSN: nil,
            birthDate: birthday
        )
    }

    static func mockMissingData() -> StakeHolder {
        StakeHolder()
    }
}

@MainActor
extension StakeHoldersConfig {
    init(
        stakeHolders: [StakeHolder],
        numberOfMissingStakeHoldersWithoutTermination: Int = 0,
        stakeHolderType: StakeHolderType = .coInsured,
    ) {
        self.init(
            id: "",
            stakeHolders: stakeHolders,
            contractId: "",
            activeFrom: "",
            numberOfMissingStakeHolders: 0,
            numberOfMissingStakeHoldersWithoutTermination: numberOfMissingStakeHoldersWithoutTermination,
            displayName: "",
            exposureDisplayName: "",
            preSelectedStakeHolders: [],
            contractDisplayName: "",
            holderFirstName: "",
            holderLastName: "",
            holderSSN: "",
            fromInfoCard: false,
            stakeHolderType: stakeHolderType
        )
    }
}
