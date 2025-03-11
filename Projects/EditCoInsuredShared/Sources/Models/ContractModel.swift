public struct Contract: Codable, Hashable, Equatable, Identifiable {

    public init(
        id: String,
        supportsCoInsured: Bool,
        upcomingChangedAgreement: Agreement?,
        currentAgreement: Agreement?,
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
}

public struct ProductVariant: Codable, Hashable {
    public let displayName: String

    public init(
        displayName: String
    ) {
        self.displayName = displayName
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
