import Foundation

public class FetchContractsServiceDemo: FetchContractsService {

    public init() {}
    public func getContracts() async throws -> ContractsStack {
        let variant = ProductVariant(
            termsVersion: "",
            typeOfContract: "",
            partner: nil,
            perils: [],
            insurableLimits: [],
            documents: [],
            displayName: ""
        )
        let agreement = Agreement(
            certificateUrl: nil,
            activeFrom: nil,
            activeTo: nil,
            premium: .sek(200),
            displayItems: [],
            productVariant: variant
        )
        let contract = Contract(
            id: "contractId",
            currentAgreement: agreement,
            exposureDisplayName: "",
            masterInceptionDate: "",
            terminationDate: nil,
            supportsAddressChange: false,
            supportsCoInsured: false,
            supportsTravelCertificate: false,
            upcomingChangedAgreement: nil,
            upcomingRenewal: nil,
            firstName: "",
            lastName: "",
            ssn: nil,
            typeOfContract: Contract.TypeOfContract.seHouse,
            coInsured: []
        )
        return .init(activeContracts: [contract], pendingContracts: [], termiantedContracts: [])
    }

}
