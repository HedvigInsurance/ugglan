import Foundation
import hCore

public class EditCoInsuredSharedClientDemo: EditCoInsuredSharedClient {
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
