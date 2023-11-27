import Foundation
import XCTest

@testable import Contracts

final class ContractsEditInsuredCompleteListTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testUpcomingZeroCurrentOneSuccess() {
        let viewModel = InsuredPeopleNewScreenModel()
        viewModel.upcomingAgreementCoInsured = []
        viewModel.currentAgreementCoInsured = [
            CoInsuredModel.mock(withSSN: "199409016830")
        ]
        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        assert(list.count == 0)
    }

    func testUpcomingTwoCoInsuredMissingDataWithCurrentWithTwoCoInsuredSuccess() {
        let viewModel = InsuredPeopleNewScreenModel()
        viewModel.upcomingAgreementCoInsured =
            [
                CoInsuredModel.mockMissingData(),
                CoInsuredModel.mockMissingData(),
            ]
        viewModel.currentAgreementCoInsured = [
            CoInsuredModel.mock(withSSN: "199409016830"),
            CoInsuredModel.mock(withSSN: "199309016830"),
        ]
        viewModel.coInsuredAdded = []
        viewModel.coInsuredDeleted = []
        let list = viewModel.completeList()
        assert(list.count == 0)
    }

}

extension CoInsuredModel {
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
