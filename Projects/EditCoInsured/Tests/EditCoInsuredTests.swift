import Foundation
import XCTest

@testable import EditCoInsured

final class ContractsEditInsuredCompleteListTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testUpcomingZeroCurrentOneSuccess() {
        let viewModel = InsuredPeopleNewScreenModel()

        viewModel.config.upcomingAgreementCoInsured = []
        viewModel.config.currentAgreementCoInsured = [
            CoInsuredModel.testMemberWithSSN5
        ]
        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        assert(list.count == 0)
    }

    func testUpcomingTwoCoInsuredMissingDataWithCurrentWithTwoCoInsuredSuccess() {
        let viewModel = InsuredPeopleNewScreenModel()

        viewModel.config.currentAgreementCoInsured = [
            CoInsuredModel.testMemberWithSSN5,
            CoInsuredModel.testMemberWithSSN4,
        ]

        viewModel.config.upcomingAgreementCoInsured = []

        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        assert(list.count == 0)
    }

    func testCurrentWith4EmptyDataUpcomingThreeSuccess() {
        let viewModel = InsuredPeopleNewScreenModel()

        viewModel.config.currentAgreementCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.config.upcomingAgreementCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        assert(list.count == 3)
    }

    func testCurrentFourEmptyUpcomingFourWithValueAddedOne() {
        let viewModel = InsuredPeopleNewScreenModel()

        viewModel.config.currentAgreementCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.config.upcomingAgreementCoInsured = [
            CoInsuredModel.testMemberWithSSN5,
            CoInsuredModel.testMemberWithSSN4,
            CoInsuredModel.testMemberWithSSN3,
            CoInsuredModel.testMemberWithSSN2,
        ]

        viewModel.coInsuredAdded = [
            CoInsuredModel.testMemberWithSSN1
        ]
        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        assert(list.count == 5)
    }

    func testCurrentTwoWithValuesAddingThreeWithValues() {
        let viewModel = InsuredPeopleNewScreenModel()

        viewModel.config.currentAgreementCoInsured = [
            CoInsuredModel.testMemberWithSSN4,
            CoInsuredModel.testMemberWithSSN5,
        ]

        viewModel.config.upcomingAgreementCoInsured = []

        viewModel.coInsuredAdded = [
            CoInsuredModel.testMemberWithSSN1,
            CoInsuredModel.testMemberWithSSN2,
            CoInsuredModel.testMemberWithSSN3,
        ]
        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        assert(list.count == 3)
    }

    func testCurrentTwoEmptyUpcomingThreeWithValuesAddingOneDeleteingTwo() {
        let viewModel = InsuredPeopleNewScreenModel()

        viewModel.config.currentAgreementCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.config.upcomingAgreementCoInsured = [
            CoInsuredModel.testMemberWithSSN1,
            CoInsuredModel.testMemberWithSSN2,
            CoInsuredModel.testMemberWithSSN3,
        ]

        viewModel.coInsuredAdded = [
            CoInsuredModel.testMemberWithSSN4
        ]

        viewModel.coInsuredDeleted = [
            CoInsuredModel.testMemberWithSSN2,
            CoInsuredModel.testMemberWithSSN3,
        ]
        let list = viewModel.completeList()
        assert(list.count == 2)
    }

    func testInitialSSNBirthday() {
        let viewModel = InsuredPeopleNewScreenModel()

        viewModel.config.currentAgreementCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.config.upcomingAgreementCoInsured = [
            CoInsuredModel.testMemberWithSSN1,
            CoInsuredModel.testMemberWithBirthdate1,
        ]

        viewModel.coInsuredAdded = []

        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        assert(list.count == 2)
    }

    func testRemovedWithoutDataAddingSSNBirthdate() {
        let viewModel = InsuredPeopleNewScreenModel()

        viewModel.config.currentAgreementCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.config.upcomingAgreementCoInsured = [
            CoInsuredModel.mockMissingData()
        ]

        viewModel.coInsuredAdded = [
            CoInsuredModel.testMemberWithSSN1,
            CoInsuredModel.testMemberWithBirthdate1,
        ]

        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        assert(list.count == 2)
    }

    func testAddCoInsuredToEmptyCurrentUpcomingValues() {
        let viewModel = InsuredPeopleNewScreenModel()

        viewModel.config.currentAgreementCoInsured = [
            CoInsuredModel.mockMissingData(),
            CoInsuredModel.mockMissingData(),
        ]

        viewModel.config.upcomingAgreementCoInsured = [
            CoInsuredModel.testMemberWithSSN1
        ]

        viewModel.coInsuredAdded = [
            CoInsuredModel.testMemberWithBirthdate1
        ]

        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        assert(list.count == 2)
    }

}

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
