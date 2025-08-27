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
            currentTotalCost: .init(monthlyGross: .sek(0), montlyNet: .sek(0)),
            newTotalCost: .init(monthlyGross: .sek(0), montlyNet: .sek(0)),
            id: "id",
            newCostBreakdown: []
        )
    }

    public func fetchContracts() async throws -> [Contract] {
        [
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
