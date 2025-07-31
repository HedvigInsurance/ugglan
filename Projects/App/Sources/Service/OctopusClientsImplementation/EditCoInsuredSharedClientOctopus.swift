import EditCoInsuredShared
import Foundation
import hCore
import hGraphQL

public class EditCoInsuredSharedClientOctopus: EditCoInsuredSharedClient {
    @Inject var octopus: hOctopus
    public init() {}

    public func fetchContracts() async throws -> [Contract] {
        let query = OctopusGraphQL.ContractsQuery()
        let data = try await octopus.client.fetch(
            query: query,
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        return data.currentMember.activeContracts.compactMap { activeContract in
            Contract(
                contract: activeContract.fragments.contractFragment,
                firstName: data.currentMember.firstName,
                lastName: data.currentMember.lastName,
                ssn: data.currentMember.ssn
            )
        }
    }
}

@MainActor
extension Contract {
    public init(
        contract: OctopusGraphQL.ContractFragment,
        firstName: String,
        lastName: String,
        ssn: String?
    ) {
        self.init(
            id: contract.id,
            exposureDisplayName: contract.exposureDisplayName,
            supportsCoInsured: contract.supportsCoInsured,
            upcomingChangedAgreement: .init(agreement: contract.upcomingChangedAgreement?.fragments.agreementFragment),
            currentAgreement: .init(agreement: contract.currentAgreement.fragments.agreementFragment),
            terminationDate: contract.terminationDate,
            coInsured: contract.coInsured?.map { .init(data: $0.fragments.coInsuredFragment) } ?? [],
            firstName: firstName,
            lastName: lastName,
            ssn: ssn
        )
    }
}

extension Agreement {
    init?(
        agreement: OctopusGraphQL.AgreementFragment?
    ) {
        guard let agreement = agreement else {
            return nil
        }
        self.init(
            activeFrom: agreement.activeFrom,
            productVariant: .init(data: agreement.productVariant.fragments.productVariantFragment)
        )
    }
}

extension EditCoInsuredShared.ProductVariant {
    public init(
        data: OctopusGraphQL.ProductVariantFragment
    ) {
        self.init(displayName: data.displayName)
    }
}

@MainActor
extension CoInsuredModel {
    public init(
        data: OctopusGraphQL.CoInsuredFragment
    ) {
        self.init(
            firstName: data.firstName,
            lastName: data.lastName,
            SSN: data.ssn,
            birthDate: data.birthdate,
            needsMissingInfo: data.hasMissingInfo,
            activatesOn: data.activatesOn,
            terminatesOn: data.terminatesOn
        )
    }
}
