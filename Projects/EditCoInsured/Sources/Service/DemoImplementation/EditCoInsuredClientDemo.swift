import EditCoInsured
import Foundation
import hCore

public class EditCoInsuredClientDemo: EditCoInsuredClient {
    public func sendMidtermChangeIntentCommit(commitId: String) async throws {
    }

    public func getPersonalInformation(SSN: String) async throws -> PersonalData? {
        return PersonalData(firstName: "first name", lastName: "last name")
    }

    public func sendIntent(contractId: String, coInsured: [CoInsuredModel]) async throws -> Intent {
        return Intent(
            activationDate: "2024-02-22",
            currentPremium: MonetaryAmount(amount: "", currency: ""),
            newPremium: MonetaryAmount(amount: "", currency: ""),
            id: "is",
            state: "state"
        )
    }

    public func fetchContracts() async throws -> [Contract] {
        return [
            Contract(
                id: "",
                exposureDisplayName: "",
                supportsCoInsured: true,
                upcomingChangedAgreement: nil,
                currentAgreement: .init(activeFrom: nil, productVariant: .init(displayName: "")),
                terminationDate: nil,
                coInsured: [],
                firstName: "first name",
                lastName: "last name",
                ssn: "ssn"
            )
        ]
    }
}
