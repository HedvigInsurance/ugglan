public struct Contract: Codable, Hashable, Equatable, Identifiable, Sendable {
    public init(
        id: String,
        exposureDisplayName: String,
        supportsCoInsured: Bool,
        supportsCoOwners: Bool,
        upcomingChangedAgreement: Agreement?,
        currentAgreement: Agreement?,
        terminationDate: String?,
        coInsured: [StakeHolder],
        coOwners: [StakeHolder],
        firstName: String,
        lastName: String,
        ssn: String?
    ) {
        self.id = id
        self.exposureDisplayName = exposureDisplayName
        self.supportsCoInsured = supportsCoInsured
        self.supportsCoOwners = supportsCoOwners
        self.upcomingChangedAgreement = upcomingChangedAgreement
        self.currentAgreement = currentAgreement
        self.terminationDate = terminationDate
        self.coInsured = coInsured
        self.coOwners = coOwners
        self.firstName = firstName
        self.lastName = lastName
        self.ssn = ssn
    }

    public let id: String
    public let exposureDisplayName: String
    public let currentAgreement: Agreement?
    public let upcomingChangedAgreement: Agreement?
    public let terminationDate: String?
    public let supportsCoInsured: Bool
    public let supportsCoOwners: Bool
    public let firstName: String
    public let lastName: String
    public let ssn: String?
    public let coInsured: [StakeHolder]
    public let coOwners: [StakeHolder]

    public var fullName: String {
        firstName + " " + lastName
    }

    public var nbOfMissingCoInsured: Int {
        coInsured.filter(\.hasMissingInfo).count
    }

    public var nbOfMissingCoOwners: Int {
        coOwners.filter(\.hasMissingInfo).count
    }

    public var nbOfMissingCoInsuredWithoutTermination: Int {
        coInsured.filter { $0.hasMissingInfo && $0.terminatesOn == nil }.count
    }

    public var nbOfMissingCoOwnersWithoutTermination: Int {
        coOwners.filter { $0.hasMissingInfo && $0.terminatesOn == nil }.count
    }

    public var showEditStakeHoldersInfo: Bool {
        (supportsCoInsured || supportsCoOwners) && terminationDate == nil
    }
}

public struct Agreement: Codable, Hashable, Sendable {
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

public struct ProductVariant: Codable, Hashable, Sendable {
    public let displayName: String

    public init(
        displayName: String
    ) {
        self.displayName = displayName
    }
}

@MainActor
extension StakeHoldersConfig {
    public init(
        contract: Contract,
        preSelectedStakeHolders: [StakeHolder],
        fromInfoCard: Bool,
        stakeHolderType: StakeHolderType
    ) {
        self.init(
            id: contract.id,
            stakeHolders: contract.coInsured + contract.coOwners,
            contractId: contract.id,
            activeFrom: contract.upcomingChangedAgreement?.activeFrom,
            numberOfMissingStakeHolders: contract.nbOfMissingCoInsured + contract.nbOfMissingCoOwners,
            numberOfMissingStakeHoldersWithoutTermination: contract.nbOfMissingCoInsuredWithoutTermination
                + contract.nbOfMissingCoOwnersWithoutTermination,
            displayName: contract.currentAgreement?.productVariant.displayName ?? "",
            exposureDisplayName: contract.exposureDisplayName,
            preSelectedStakeHolders: preSelectedStakeHolders,
            contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
            holderFirstName: contract.firstName,
            holderLastName: contract.lastName,
            holderSSN: contract.ssn,
            fromInfoCard: fromInfoCard,
            stakeHolderType: stakeHolderType
        )
    }
}
