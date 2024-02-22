import Foundation
import hGraphQL

public class EditCoInsuredDemoClient: EditCoInsuredService {
    public func sendMidtermChangeIntentCommit(commitId: String) async throws {
    }

    public func getPersonalInformation(SSN: String) async throws -> PersonalData? {
        return PersonalData(firstName: "first name", lastName: "last name")
    }

    public func sendIntent(contractId: String, coInsured: [CoInsuredModel]) async throws -> IntentData? {
        return IntentData(
            activationDate: "2024-02-22",
            currentPremium: MonetaryAmount(amount: "", currency: ""),
            newPremium: MonetaryAmount(amount: "", currency: ""),
            id: "is",
            state: "state"
        )
    }
}
