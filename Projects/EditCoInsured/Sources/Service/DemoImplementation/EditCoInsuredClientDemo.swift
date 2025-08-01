import EditCoInsuredShared
import Foundation
import hCore

public class EditCoInsuredClientDemo: EditCoInsuredClient {
    public func sendMidtermChangeIntentCommit(commitId _: String) async throws {}

    public func getPersonalInformation(SSN _: String) async throws -> PersonalData? {
        PersonalData(firstName: "first name", lastName: "last name")
    }

    public func sendIntent(contractId _: String, coInsured _: [CoInsuredModel]) async throws -> Intent {
        Intent(
            activationDate: "2024-02-22",
            currentPremium: MonetaryAmount(amount: "", currency: ""),
            newPremium: MonetaryAmount(amount: "", currency: ""),
            id: "is",
            state: "state"
        )
    }
}
