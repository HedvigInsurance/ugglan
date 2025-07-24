import Foundation
@preconcurrency import XCTest

@testable import EditCoInsured

@MainActor
final class ContractsEditInsuredCompleteListTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testUpcomingZeroCurrentOneSuccess() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.testMemberWithSSN5
        ]

        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        XCTAssert(list.count == 1)
    }

    func testUpcomingTwoCoInsuredMissingDataWithCurrentWithTwoCoInsuredSuccess() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.testMemberWithSSN5,
            CoInsuredModel.testMemberWithSSN4,
        ]

        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = [
            CoInsuredModel.testMemberWithSSN5,
            CoInsuredModel.testMemberWithSSN4,
        ]

        let list = viewModel.completeList()
        XCTAssert(list.count == 0)
    }

    func testCurrentWith4EmptyDataUpcomingThreeSuccess() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        XCTAssert(list.count == 4)
    }

    func testCurrentFourEmptyUpcomingFourWithValueAddedOne() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = [
            CoInsuredModel.mockMissingData()
        ]

        viewModel.config.numberOfMissingCoInsuredWithoutTermination = 4

        let list = viewModel.completeList()
        XCTAssert(list.count == 3)
    }

    func testCurrentTwoWithValuesAddingThreeWithValues() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.testMemberWithSSN4,
            CoInsuredModel.testMemberWithSSN5,
        ]

        viewModel.coInsuredAdded = [
            CoInsuredModel.testMemberWithSSN1,
            CoInsuredModel.testMemberWithSSN2,
            CoInsuredModel.testMemberWithSSN3,
        ]
        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        XCTAssert(list.count == 5)
    }

    func testInitialWithTwoAdded() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.coInsuredAdded = [CoInsuredModel.testMemberWithSSN1, CoInsuredModel.testMemberWithSSN2]
        viewModel.coInsuredDeleted = []
        viewModel.config.numberOfMissingCoInsuredWithoutTermination = 2

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
        XCTAssert(list[0] == CoInsuredModel.testMemberWithSSN1)
        XCTAssert(list[1] == CoInsuredModel.testMemberWithSSN2)

    }

    func testInitialWithOneDeleted() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = [CoInsuredModel.mockMissingData()]

        viewModel.config.numberOfMissingCoInsuredWithoutTermination = 2

        let list = viewModel.completeList()
        XCTAssert(list.count == 1)
        XCTAssert(list[0] == CoInsuredModel.mockMissingData())
    }

    func testInitialAllDeleted() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = [CoInsuredModel.mockMissingData(), CoInsuredModel.mockMissingData()]

        let list = viewModel.completeList()
        XCTAssert(list.count == 0)
    }

    func testRemoveOne() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.testMemberWithSSN1,
            CoInsuredModel.testMemberWithSSN2,
            CoInsuredModel.testMemberWithBirthdate2,
        ]

        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = [CoInsuredModel.testMemberWithBirthdate2]

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
    }

    func testEmptyWithTerminationAndMissingData() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.testMemberEmptyTerminated,
        ]

        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = [CoInsuredModel.mockMissingData()]
        viewModel.config.numberOfMissingCoInsuredWithoutTermination = 2

        let list = viewModel.completeList()
        XCTAssert(list.count == 1)
        XCTAssert(list[0] == CoInsuredModel.mockMissingData())
    }

    func testEmptyWithTerminationAndAddedData() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.testMemberWithSSN1,
            CoInsuredModel.testMemberWithBirthdate1,
            CoInsuredModel.testMemberEmptyTerminated,
        ]

        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = []

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
    }

    func testEmptyWithTerminationAndAddingData() {
        let viewModel = InsuredPeopleScreenViewModel()

        viewModel.config.contractCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.testMemberEmptyTerminated,
        ]

        viewModel.coInsuredAdded = [
            CoInsuredModel.testMemberWithSSN1,
            CoInsuredModel.testMemberWithBirthdate1,
        ]
        viewModel.coInsuredDeleted = []
        viewModel.config.numberOfMissingCoInsuredWithoutTermination = 2

        let list = viewModel.completeList()
        XCTAssert(list.count == 2)
        XCTAssert(list[0] == CoInsuredModel.testMemberWithSSN1)
        XCTAssert(list[1] == CoInsuredModel.testMemberWithBirthdate1)
    }
}
@MainActor
extension CoInsuredModel {
    static let testMemberWithSSN1 = CoInsuredModel(
        firstName: "Test",
        lastName: "Testsson",
        SSN: "199009016830",
        birthDate: "1990-09-01"
    )
    static let testMemberWithSSN2 = CoInsuredModel(
        firstName: "Hedvig",
        lastName: "Testsson",
        SSN: "199109016830",
        birthDate: "1991-09-01"
    )
    static let testMemberWithSSN3 = CoInsuredModel(
        firstName: "A",
        lastName: "B",
        SSN: "199209016830",
        birthDate: "1992-09-01"
    )
    static let testMemberWithSSN4 = CoInsuredModel(
        firstName: "B",
        lastName: "A",
        SSN: "199309016830",
        birthDate: "1993-09-01"
    )
    static let testMemberWithSSN5 = CoInsuredModel(
        firstName: "C",
        lastName: "D",
        SSN: "199409016830",
        birthDate: "1994-09-01"
    )

    static let testMemberWithBirthdate1 = CoInsuredModel(
        firstName: "Test",
        lastName: "Testsson",
        SSN: nil,
        birthDate: "1990-09-01"
    )
    static let testMemberWithBirthdate2 = CoInsuredModel(
        firstName: "Test",
        lastName: "Testsson",
        SSN: nil,
        birthDate: "1991-09-01"
    )
    static let testMemberWithBirthdate3 = CoInsuredModel(
        firstName: "Test",
        lastName: "Testsson",
        SSN: nil,
        birthDate: "1992-09-01"
    )

    static let testMemberEmptyTerminated = CoInsuredModel(
        firstName: nil,
        lastName: nil,
        SSN: nil,
        birthDate: nil,
        terminatesOn: "2023-12-11"
    )

    static func mock(withSSN ssn: String) -> CoInsuredModel {
        CoInsuredModel(
            firstName: "",
            lastName: "",
            SSN: ssn,
            birthDate: ""
        )
    }

    static func mock(withBirthday birthday: String) -> CoInsuredModel {
        CoInsuredModel(
            firstName: "",
            lastName: "",
            SSN: nil,
            birthDate: birthday
        )
    }

    static func mockMissingData() -> CoInsuredModel {
        CoInsuredModel()
    }
}
