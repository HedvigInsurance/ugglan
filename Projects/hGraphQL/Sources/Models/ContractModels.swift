import Foundation

public struct ActiveContractBundle: Codable, Equatable {
    public var contracts: [Contract]
    public var id: String
    public var movingFlowEmbarkId: String?
    public var crossSells: [CrossSell]

    public init(
        bundle: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle
    ) {
        contracts = bundle.contracts.map { .init(contract: $0) }
        movingFlowEmbarkId = bundle.angelStories.addressChange
        id = bundle.id
        crossSells = bundle.potentialCrossSells.compactMap { CrossSell($0) }
    }
}

public struct IconEnvelope: Codable, Equatable, Hashable {
    public let dark: String
    public let light: String
    public init?(
        fragment: GraphQL.IconFragment?
    ) {
        guard let fragment = fragment else { return nil }
        dark = fragment.variants.dark.pdfUrl
        light = fragment.variants.light.pdfUrl
    }
}

extension String {
    // converts a YYYY-MM-DD date-string to a Date
    var localDateToDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}

public struct Contract: Codable, Hashable, Equatable {
    public init(
        id: String,
        upcomingAgreementsTable: DetailAgreementsTable,
        currentAgreementsTable: DetailAgreementsTable?,
        gradientOption: Contract.GradientOption?,
        displayName: String,
        switchedFromInsuranceProvider: String?,
        upcomingRenewal: UpcomingRenewal?,
        contractPerils: [Perils],
        insurableLimits: [InsurableLimits],
        termsAndConditions: TermsAndConditions,
        currentAgreement: CurrentAgreement,
        statusPills: [String],
        detailPills: [String],
        showsMovingFlowButton: Bool = false,
        upcomingAgreementDate: Date? = nil
    ) {
        self.id = id
        self.upcomingAgreementsTable = upcomingAgreementsTable
        self.currentAgreementsTable = currentAgreementsTable
        self.gradientOption = gradientOption
        self.displayName = displayName
        self.switchedFromInsuranceProvider = switchedFromInsuranceProvider
        self.upcomingRenewal = upcomingRenewal
        self.contractPerils = contractPerils
        self.insurableLimits = insurableLimits
        self.termsAndConditions = termsAndConditions
        self.currentAgreement = currentAgreement
        self.statusPills = statusPills
        self.detailPills = detailPills
        self.showsMovingFlowButton = showsMovingFlowButton
        self.upcomingAgreementDate = nil
    }

    public let id: String
    public let upcomingAgreementsTable: DetailAgreementsTable
    public let currentAgreementsTable: DetailAgreementsTable?
    public let gradientOption: GradientOption?
    public let displayName: String
    public let switchedFromInsuranceProvider: String?
    public let upcomingRenewal: UpcomingRenewal?
    public let contractPerils: [Perils]
    public let insurableLimits: [InsurableLimits]
    public let termsAndConditions: TermsAndConditions
    public let currentAgreement: CurrentAgreement?
    public let statusPills: [String]
    public let detailPills: [String]
    public let showsMovingFlowButton: Bool
    public let upcomingAgreementDate: Date?

    init(
        contract: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract
    ) {
        id = contract.id
        upcomingAgreementsTable = .init(
            fragment: contract.upcomingAgreementDetailsTable.fragments.detailsTableFragment
        )
        currentAgreementsTable = .init(
            fragment: contract.currentAgreementDetailsTable.fragments.detailsTableFragment
        )
        upcomingRenewal = .init(upcomingRenewal: contract.upcomingRenewal)
        contractPerils = contract.contractPerils.map { .init(fragment: $0.fragments.perilFragment) }
        insurableLimits = contract.insurableLimits.map { .init(fragment: $0.fragments.insurableLimitFragment) }
        termsAndConditions = .init(
            displayName: contract.termsAndConditions.displayName,
            url: contract.termsAndConditions.url
        )
        currentAgreement = .init(currentAgreement: contract.currentAgreement)
        displayName = contract.displayName
        switchedFromInsuranceProvider = contract.switchedFromInsuranceProvider
        statusPills = contract.statusPills
        detailPills = contract.detailPills

        if let contractGradientOption = contract.gradientOption {
            gradientOption = .init(rawValue: contractGradientOption.rawValue)
        } else {
            gradientOption = nil
        }

        showsMovingFlowButton = contract.supportsAddressChange
        upcomingAgreementDate =
            contract.status.asActiveStatus?.upcomingAgreementChange?.newAgreement.activeFrom?.localDateToDate
    }

    public init(
        contract: GraphQL.ContractsQuery.Data.Contract
    ) {
        id = contract.id
        upcomingAgreementsTable = .init(
            fragment: contract.upcomingAgreementDetailsTable.fragments.detailsTableFragment
        )
        currentAgreementsTable = .init(fragment: contract.currentAgreementDetailsTable.fragments.detailsTableFragment)
        upcomingRenewal = nil
        contractPerils = contract.contractPerils.map { .init(fragment: $0.fragments.perilFragment) }
        insurableLimits = contract.insurableLimits.map { .init(fragment: $0.fragments.insurableLimitFragment) }
        termsAndConditions = .init(
            displayName: contract.termsAndConditions.displayName,
            url: contract.termsAndConditions.url
        )
        currentAgreement = .init(currentAgreement: contract.currentAgreement)
        displayName = contract.displayName
        switchedFromInsuranceProvider = contract.switchedFromInsuranceProvider
        statusPills = contract.statusPills
        detailPills = contract.detailPills

        if let contractGradientOption = contract.gradientOption {
            gradientOption = .init(rawValue: contractGradientOption.rawValue)
        } else {
            gradientOption = nil
        }

        showsMovingFlowButton = false
        upcomingAgreementDate = nil
    }

    public enum GradientOption: String, Codable {
        case one = "GRADIENT_ONE"
        case two = "GRADIENT_TWO"
        case three = "GRADIENT_THREE"
    }
}

public struct UpcomingRenewal: Codable, Hashable {
    public let renewalDate: String?
    public let draftCertificateUrl: String?

    init(
        upcomingRenewal: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract.UpcomingRenewal?
    ) {
        renewalDate = upcomingRenewal?.renewalDate
        draftCertificateUrl = upcomingRenewal?.draftCertificateUrl
    }
}

public struct TermsAndConditions: Codable, Hashable {
    public init(
        displayName: String,
        url: String
    ) {
        self.displayName = displayName
        self.url = url
    }

    public let displayName: String
    public let url: String
}

public struct AngelStories: Codable {
    public let addressChange: String
}

public struct DetailAgreementsTable: Codable, Hashable, Identifiable {
    public init(
        sections: [DetailAgreementsTable.Section],
        title: String
    ) {
        self.sections = sections
        self.title = title
    }

    public var id: String {
        return title
    }
    public let sections: [Section]
    public let title: String
    public init(
        fragment: GraphQL.DetailsTableFragment
    ) {
        sections = fragment.sections.map { .init(section: $0) }
        title = fragment.title
    }

    public struct Section: Codable, Hashable, Identifiable {
        public init(
            title: String,
            rows: [DetailAgreementsTable.Row]
        ) {
            self.title = title
            self.rows = rows
        }

        public var id: String {
            return title
        }
        public let title: String
        public let rows: [Row]

        init(
            section: GraphQL.DetailsTableFragment.Section
        ) {
            title = section.title
            rows = section.rows.map { .init(row: $0) }
        }
    }

    public struct Row: Codable, Hashable {
        public init(
            title: String,
            subtitle: String?,
            value: String
        ) {
            self.title = title
            self.subtitle = subtitle
            self.value = value
        }

        public let title: String
        public let subtitle: String?
        public let value: String
        init(
            row: GraphQL.DetailsTableFragment.Section.Row
        ) {
            title = row.title
            subtitle = row.subtitle
            value = row.value
        }
    }
}

public struct Perils: Codable, Equatable, Hashable {
    public let title: String
    public let description: String
    public let icon: IconEnvelope?
    public let covered: [String]
    public let exceptions: [String]

    public init(
        fragment: GraphQL.PerilFragment
    ) {
        title = fragment.title
        description = fragment.description
        icon = .init(fragment: fragment.icon.fragments.iconFragment)
        covered = fragment.covered
        exceptions = fragment.exceptions
    }
}

public struct InsurableLimits: Codable, Hashable {
    public let label: String
    public let limit: String
    public let description: String

    public init(
        fragment: GraphQL.InsurableLimitFragment
    ) {
        label = fragment.label
        limit = fragment.limit
        description = fragment.description
    }
}

public struct CurrentAgreement: Codable, Hashable {
    public init(
        certificateUrl: String?,
        activeFrom: String?,
        activeTo: String?,
        premium: MonetaryAmount,
        status: ContractStatus?
    ) {
        self.certificateUrl = certificateUrl
        self.activeFrom = activeFrom
        self.activeTo = activeTo
        self.premium = premium
        self.status = status
    }

    public let certificateUrl: String?
    public let activeFrom: String?
    public let activeTo: String?
    public let premium: MonetaryAmount
    public let status: ContractStatus?

    init?(
        currentAgreement: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract.CurrentAgreement?
    ) {
        guard let currentAgreement = currentAgreement else {
            return nil
        }

        certificateUrl = currentAgreement.certificateUrl
        activeFrom = currentAgreement.activeFrom
        activeTo = currentAgreement.activeTo
        premium = .init(fragment: currentAgreement.premium.fragments.monetaryAmountFragment)
        status = .init(rawValue: currentAgreement.status.rawValue)
    }

    init?(
        currentAgreement: GraphQL.ContractsQuery.Data.Contract.CurrentAgreement?
    ) {
        guard let currentAgreement = currentAgreement else {
            return nil
        }

        certificateUrl = currentAgreement.certificateUrl
        activeFrom = currentAgreement.activeFrom
        activeTo = currentAgreement.activeTo
        premium = .init(fragment: currentAgreement.premium.fragments.monetaryAmountFragment)
        status = .init(rawValue: currentAgreement.status.rawValue)
    }
}

public enum ContractStatus: String, Codable {
    case active = "ACTIVE"
    case activeInFuture = "ACTIVE_IN_FUTURE"
    case terminated = "TERMINATED"
    case pending = "PENDING"
}

public struct MonetaryAmount: Equatable, Hashable, Codable {
    public init(
        amount: String,
        currency: String
    ) {
        self.amount = amount
        self.currency = currency
    }

    public init(
        amount: Float,
        currency: String
    ) {
        self.amount = String(amount)
        self.currency = currency
    }

    public init(
        fragment: GraphQL.MonetaryAmountFragment
    ) {
        amount = fragment.amount
        currency = fragment.currency
    }

    public var amount: String
    public var currency: String
}
