import Foundation

public struct ActiveContractBundle: Codable, Equatable {
    public let contracts: [Contract]
    public let id: String
    public let movingFlowEmbarkId: String?

    public init(
        bundle: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle
    ) {
        contracts = bundle.contracts.map { .init(contract: $0) }
        movingFlowEmbarkId = bundle.angelStories.addressChange
        id = bundle.id
    }
}

public struct hIcon: Codable, Equatable {
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

public struct MonetaryAmount: Codable {
    public let amount: String
    public let currency: String
    public init(
        fragment: GraphQL.MonetaryAmountFragment
    ) {
        amount = fragment.amount
        currency = fragment.currency
    }
}

extension Contract: Equatable {
    public static func == (lhs: Contract, rhs: Contract) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct Contract: Codable {
    public let id: String
    public let upcomingAgreementsTable: DetailAgreementsTable
    public let currentAgreementsTable: DetailAgreementsTable?
    public let gradientOption: GradientOption?
    public let displayName: String
    public let switchedFromInsuranceProvider: String?
    public let upcomingRenewal: UpcomingRenewal?
    public let perils: [Perils]
    public let insurableLimits: [InsurableLimits]
    public let termsAndConditions: TermsAndConditions
    public let currentAgreement: CurrentAgreement
    public let statusPills: [String]
    public let detailPills: [String]

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
        perils = contract.perils.map { .init(fragment: $0.fragments.perilFragment) }
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
        gradientOption = .init(rawValue: contract.gradientOption.rawValue)
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
        perils = contract.perils.map { .init(fragment: $0.fragments.perilFragment) }
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
        gradientOption = .init(rawValue: contract.gradientOption.rawValue)
    }

    public enum GradientOption: String, Codable {
        case one = "GRADIENT_ONE"
        case two = "GRADIENT_TWO"
        case three = "GRADIENT_THREE"
    }
}

public struct UpcomingRenewal: Codable {
    public let renewalDate: String?
    public let draftCertificateUrl: String?

    init(
        upcomingRenewal: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract.UpcomingRenewal?
    ) {
        renewalDate = upcomingRenewal?.renewalDate
        draftCertificateUrl = upcomingRenewal?.draftCertificateUrl
    }
}

public struct TermsAndConditions: Codable {
    public let displayName: String
    public let url: String
}

public struct AngelStories: Codable {
    public let addressChange: String
}

public struct DetailAgreementsTable: Codable {
    public let sections: [Section]
    public let title: String
    public init(
        fragment: GraphQL.DetailsTableFragment
    ) {
        sections = fragment.sections.map { .init(section: $0) }
        title = fragment.title
    }

    public struct Section: Codable {
        public let title: String
        public let rows: [Row]

        init(
            section: GraphQL.DetailsTableFragment.Section
        ) {
            title = section.title
            rows = section.rows.map { .init(row: $0) }
        }
    }

    public struct Row: Codable {
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

public struct Perils: Codable, Equatable {
    public let title: String
    public let description: String
    public let icon: hIcon?
    public let covered: [String]
    public let exceptions: [String]
    public let info: String
    public init(
        fragment: GraphQL.PerilFragment
    ) {
        title = fragment.title
        description = fragment.description
        icon = .init(fragment: fragment.icon.fragments.iconFragment)
        covered = fragment.covered
        exceptions = fragment.exceptions
        info = fragment.info
    }
}

public struct InsurableLimits: Codable {
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

public struct CurrentAgreement: Codable {
    public let certificateUrl: String?
    public let activeFrom: String?
    public let activeTo: String?
    public let premium: MonetaryAmount
    public let status: ContractStatus?
    init(
        currentAgreement: GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract.CurrentAgreement
    ) {
        certificateUrl = currentAgreement.certificateUrl
        activeFrom = currentAgreement.activeFrom
        activeTo = currentAgreement.activeTo
        premium = .init(fragment: currentAgreement.premium.fragments.monetaryAmountFragment)
        status = .init(rawValue: currentAgreement.status.rawValue)
    }

    init(
        currentAgreement: GraphQL.ContractsQuery.Data.Contract.CurrentAgreement
    ) {
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

extension Contract {
    public var upcomingAgreementDate: String? {
        return nil
        //        let agreement = self
        //        let agreement = self.status.asActiveStatus?.upcomingAgreementChange?.fragments
        //            .upcomingAgreementChangeFragment.newAgreement
        //        let dateString =
        //            agreement?.asSwedishApartmentAgreement?.activeFrom
        //            ?? agreement?.asSwedishHouseAgreement?.activeFrom
        //            ?? agreement?.asDanishHomeContentAgreement?.activeFrom
        //            ?? agreement?.asNorwegianHomeContentAgreement?.activeFrom
        //
        //        return dateString
    }

    public var upcomingAgreementAddress: String? {
        //        let upcomingAgreement = self.status.asActiveStatus?.upcomingAgreementChange?.fragments
        //            .upcomingAgreementChangeFragment.newAgreement
        //
        //        if let address = upcomingAgreement?.asSwedishHouseAgreement?.address.street {
        //            return address
        //        } else if let address = upcomingAgreement?.asSwedishApartmentAgreement?.address.street {
        //            return address
        //        } else if let address = upcomingAgreement?.asNorwegianHomeContentAgreement?.address.street {
        //            return address
        //        } else if let address = upcomingAgreement?.asDanishHomeContentAgreement?.address.street {
        //            return address
        //        } else {
        //            return nil
        //        }

        return nil
    }
}

public struct UpcomingAgreementContract: Codable, Equatable {
    public static func == (lhs: UpcomingAgreementContract, rhs: UpcomingAgreementContract) -> Bool {
        lhs.id == rhs.id
    }

    public let detailsTable: DetailAgreementsTable
    public let hasUpcomingAgreementChange: Bool
    public let id: String
    public init(
        contract: GraphQL.UpcomingAgreementQuery.Data.Contract
    ) {
        id = contract.id
        detailsTable = .init(fragment: contract.upcomingAgreementDetailsTable.fragments.detailsTableFragment)
        hasUpcomingAgreementChange = contract.status.asActiveStatus?.upcomingAgreementChange != nil
    }
}
