public struct Contract: Codable, Hashable, Equatable, Identifiable, Sendable {
    public init(
        id: String,
        exposureDisplayName: String,
        supportsCoInsured: Bool,
        supportsCoOwners: Bool,
        upcomingChangedAgreement: Agreement?,
        currentAgreement: Agreement?,
        terminationDate: String?,
        coInsured: [Stakeholder],
        coOwners: [Stakeholder],
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
    public let coInsured: [Stakeholder]
    public let coOwners: [Stakeholder]

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

    public func showEditStakeholdersInfo(for stakeholdersType: StakeholderType) -> Bool {
        switch stakeholdersType {
        case .coInsured: supportsCoInsured && terminationDate == nil
        case .coOwner: supportsCoOwners && terminationDate == nil
        }
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
extension StakeholdersConfig {
    public init(
        contract: Contract,
        preSelectedStakeholders: [Stakeholder],
        fromInfoCard: Bool,
        stakeholderType: StakeholderType
    ) {
        let (stakeholders, numberOfMissingStakeholders, numberOfMissingStakeholdersWithoutTermination) =
            switch stakeholderType {
            case .coInsured:
                (contract.coInsured, contract.nbOfMissingCoInsured, contract.nbOfMissingCoInsuredWithoutTermination)
            case .coOwner:
                (contract.coOwners, contract.nbOfMissingCoOwners, contract.nbOfMissingCoOwnersWithoutTermination)
            }
        self.init(
            id: contract.id,
            stakeholders: stakeholders,
            contractId: contract.id,
            activeFrom: contract.upcomingChangedAgreement?.activeFrom,
            numberOfMissingStakeholders: numberOfMissingStakeholders,
            numberOfMissingStakeholdersWithoutTermination: numberOfMissingStakeholdersWithoutTermination,
            displayName: contract.currentAgreement?.productVariant.displayName ?? "",
            exposureDisplayName: contract.exposureDisplayName,
            preSelectedStakeholders: preSelectedStakeholders,
            contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
            holderFirstName: contract.firstName,
            holderLastName: contract.lastName,
            holderSSN: contract.ssn,
            fromInfoCard: fromInfoCard,
            stakeholderType: stakeholderType
        )
    }
}
