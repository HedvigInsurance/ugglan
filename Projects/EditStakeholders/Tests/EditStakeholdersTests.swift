import Foundation
import Testing

@testable import EditStakeholders

@MainActor
final class ContractsEditInsuredCompleteListTests {
    @Test
    func upcomingZeroCurrentOneSuccess() {
        let viewModel = StakeholdersViewModel(with: .init(stakeholders: [Stakeholder.testMemberWithSSN5]))

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = []
        let list = viewModel.completeList()
        #expect(list.count == 1)
    }

    @Test
    func upcomingTwoCoInsuredMissingDataWithCurrentWithTwoCoInsuredSuccess() {
        let viewModel = StakeholdersViewModel(
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
        #expect(list.count == 0)
    }

    @Test
    func currentWith4EmptyDataUpcomingThreeSuccess() {
        let viewModel = StakeholdersViewModel(
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
        #expect(list.count == 4)
    }

    @Test
    func currentFourEmptyUpcomingFourWithValueAddedOne() {
        let viewModel = StakeholdersViewModel(
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
        #expect(list.count == 3)
    }

    @Test
    func currentTwoWithValuesAddingThreeWithValues() {
        let viewModel = StakeholdersViewModel(
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
        #expect(list.count == 5)
    }

    @Test
    func initialWithTwoAdded() throws {
        let viewModel = StakeholdersViewModel(
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
        try #require(list.count == 2)
        #expect(list[0] == Stakeholder.testMemberWithSSN1)
        #expect(list[1] == Stakeholder.testMemberWithSSN2)
    }

    @Test
    func initialWithOneDeleted() throws {
        let viewModel = StakeholdersViewModel(
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
        try #require(list.count == 1)
        #expect(list[0] == Stakeholder.mockMissingData())
    }

    @Test
    func initialAllDeleted() {
        let viewModel = StakeholdersViewModel(
            with: .init(stakeholders: [
                Stakeholder.mockMissingData(),
                Stakeholder.mockMissingData(),
            ])
        )

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = [Stakeholder.mockMissingData(), Stakeholder.mockMissingData()]

        let list = viewModel.completeList()
        #expect(list.count == 0)
    }

    @Test
    func removeOne() {
        let viewModel = StakeholdersViewModel(
            with: .init(stakeholders: [
                Stakeholder.testMemberWithSSN1,
                Stakeholder.testMemberWithSSN2,
                Stakeholder.testMemberWithBirthdate2,
            ])
        )

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = [Stakeholder.testMemberWithBirthdate2]

        let list = viewModel.completeList()
        #expect(list.count == 2)
    }

    @Test
    func emptyWithTerminationAndMissingData() throws {
        let viewModel = StakeholdersViewModel(
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
        try #require(list.count == 1)
        #expect(list[0] == Stakeholder.mockMissingData())
    }

    @Test
    func emptyWithTerminationAndAddedData() {
        let viewModel = StakeholdersViewModel(
            with: .init(stakeholders: [
                Stakeholder.testMemberWithSSN1,
                Stakeholder.testMemberWithBirthdate1,
                Stakeholder.testMemberEmptyTerminated,
            ])
        )

        viewModel.stakeholdersAdded = []
        viewModel.stakeholdersDeleted = []

        let list = viewModel.completeList()
        #expect(list.count == 2)
    }

    @Test
    func emptyWithTerminationAndAddingData() throws {
        let viewModel = StakeholdersViewModel(
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
        try #require(list.count == 2)
        #expect(list[0] == Stakeholder.testMemberWithSSN1)
        #expect(list[1] == Stakeholder.testMemberWithBirthdate1)
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
