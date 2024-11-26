import hGraphQL

public struct Contract: Codable, Hashable, Equatable, Identifiable {
    public init(
        contract: OctopusGraphQL.ContractFragment,
        firstName: String,
        lastName: String,
        ssn: String?
    ) {
        self.id = contract.id
        self.coInsured = contract.coInsured?.map({ .init(data: $0.fragments.coInsuredFragment) }) ?? []
        self.supportsCoInsured = contract.supportsCoInsured
        self.upcomingChangedAgreement = .init(agreement: contract.upcomingChangedAgreement?.fragments.agreementFragment)
        self.currentAgreement =
            .init(agreement: contract.currentAgreement.fragments.agreementFragment)
        self.terminationDate = contract.terminationDate
        self.firstName = firstName
        self.lastName = lastName
        self.ssn = ssn
    }

    public init(
        id: String,
        supportsCoInsured: Bool,
        upcomingChangedAgreement: Agreement?,
        currentAgreement: Agreement,
        terminationDate: String?,
        coInsured: [CoInsuredModel],
        firstName: String,
        lastName: String,
        ssn: String?
    ) {
        self.id = id
        self.supportsCoInsured = supportsCoInsured
        self.upcomingChangedAgreement = upcomingChangedAgreement
        self.currentAgreement = currentAgreement
        self.terminationDate = terminationDate
        self.coInsured = coInsured
        self.firstName = firstName
        self.lastName = lastName
        self.ssn = ssn
    }

    public let id: String
    public let currentAgreement: Agreement?
    public let upcomingChangedAgreement: Agreement?
    public let terminationDate: String?
    public let supportsCoInsured: Bool
    public let firstName: String
    public let lastName: String
    public let ssn: String?
    public var coInsured: [CoInsuredModel]
    public var fullName: String {
        return firstName + " " + lastName
    }

    public var nbOfMissingCoInsured: Int {
        return self.coInsured.filter({ $0.hasMissingInfo }).count
    }

    public var nbOfMissingCoInsuredWithoutTermination: Int {
        return self.coInsured.filter({ $0.hasMissingInfo && $0.terminatesOn == nil }).count
    }

    public var showEditCoInsuredInfo: Bool {
        return supportsCoInsured && self.terminationDate == nil
    }
}

public struct Agreement: Codable, Hashable {
    public let activeFrom: String?
    public let productVariant: ProductVariant

    public init(
        activeFrom: String?,
        productVariant: ProductVariant
    ) {
        self.activeFrom = activeFrom
        self.productVariant = productVariant
    }

    init?(
        agreement: OctopusGraphQL.AgreementFragment?
    ) {
        guard let agreement = agreement else {
            return nil
        }
        activeFrom = agreement.activeFrom
        productVariant = .init(data: agreement.productVariant.fragments.productVariantFragment)
    }
}

public struct ProductVariant: Codable, Hashable {
    public let displayName: String

    public init(
        displayName: String
    ) {
        self.displayName = displayName
    }

    public init(
        data: OctopusGraphQL.ProductVariantFragment
    ) {
        self.displayName = data.displayName
    }
}
@MainActor
extension InsuredPeopleConfig {
    public init(
        contract: Contract,
        preSelectedCoInsuredList: [CoInsuredModel],
        fromInfoCard: Bool
    ) {
        self.init(
            id: contract.id,
            contractCoInsured: contract.coInsured,
            contractId: contract.id,
            activeFrom: contract.upcomingChangedAgreement?.activeFrom,
            numberOfMissingCoInsured: contract.nbOfMissingCoInsured,
            numberOfMissingCoInsuredWithoutTermination: contract.nbOfMissingCoInsuredWithoutTermination,
            displayName: contract.currentAgreement?.productVariant.displayName ?? "",
            preSelectedCoInsuredList: preSelectedCoInsuredList,
            contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
            holderFirstName: contract.firstName,
            holderLastName: contract.lastName,
            holderSSN: contract.ssn,
            fromInfoCard: fromInfoCard
        )
    }
}
