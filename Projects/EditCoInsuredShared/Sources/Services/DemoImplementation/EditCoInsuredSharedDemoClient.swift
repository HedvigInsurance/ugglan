import Foundation
import hCore
import hGraphQL

public class EditCoInsuredSharedDemoClient: EditCoInsuredSharedClient {
    public func fetchContracts() async throws -> [Contract] {
        return [
            Contract(
                id: "",
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
