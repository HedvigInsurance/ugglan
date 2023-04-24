import Foundation

public struct ActiveContractBundle: Codable, Equatable, Hashable {
    public var contracts: [Contract]
    public var id: String
    public var movingFlowEmbarkId: String?

    public init(
        bundle: GiraffeGraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle
    ) {
        contracts = bundle.contracts.map { .init(contract: $0) }
        movingFlowEmbarkId = bundle.angelStories.addressChangeV2
        id = bundle.id
    }
}

public struct IconEnvelope: Codable, Equatable, Hashable {
    public let dark: String
    public let light: String
    public init?(
        fragment: GiraffeGraphQL.IconFragment?
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
        typeOfContract: TypeOfContract,
        upcomingAgreementsTable: DetailAgreementsTable,
        currentAgreementsTable: DetailAgreementsTable?,
        gradientOption: Contract.GradientOption?,
        logo: IconEnvelope?,
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
        self.typeOfContract = typeOfContract
        self.upcomingAgreementsTable = upcomingAgreementsTable
        self.currentAgreementsTable = currentAgreementsTable
        self.logo = logo
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
    public let typeOfContract: TypeOfContract
    public let upcomingAgreementsTable: DetailAgreementsTable
    public let currentAgreementsTable: DetailAgreementsTable?
    public var gradientOption: GradientOption? {
        if self.currentAgreement?.status == .terminated {
            return nil
        }

        return self.typeOfContract.gradientOption
    }

    public let logo: IconEnvelope?
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
        contract: GiraffeGraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract
    ) {
        id = contract.id
        typeOfContract = TypeOfContract.resolve(for: contract.typeOfContract)
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

        if let logo = contract.logo {
            self.logo = .init(fragment: logo.fragments.iconFragment)
        } else {
            self.logo = nil
        }

        showsMovingFlowButton = contract.supportsAddressChange
        upcomingAgreementDate =
            contract.status.asActiveStatus?.upcomingAgreementChange?.newAgreement.activeFrom?.localDateToDate
    }

    public init(
        contract: GiraffeGraphQL.ContractsQuery.Data.Contract
    ) {
        id = contract.id
        typeOfContract = TypeOfContract.resolve(for: contract.typeOfContract)
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

        if let logo = contract.logo {
            self.logo = .init(fragment: logo.fragments.iconFragment)
        } else {
            self.logo = nil
        }

        showsMovingFlowButton = false
        upcomingAgreementDate = nil
    }

    public enum GradientOption: Codable {
        case home
        case accident
        case house
        case travel
        case car
        case pet
        case unknown
    }

    public enum TypeOfContract: String, Codable {
        case seHouse = "SE_HOUSE"
        case seApartmentBrf = "SE_APARTMENT_BRF"
        case seApartmentRent = "SE_APARTMENT_RENT"
        case seApartmentStudentBrf = "SE_APARTMENT_STUDENT_BRF"
        case seApartmentStudentRent = "SE_APARTMENT_STUDENT_RENT"
        case seAccident = "SE_ACCIDENT"
        case seAccidentStudent = "SE_ACCIDENT_STUDENT"
        case seCarTraffic = "SE_CAR_TRAFFIC"
        case seCarHalf = "SE_CAR_HALF"
        case seCarFull = "SE_CAR_FULL"
        case seGroupApartmentRent = "SE_GROUP_APARTMENT_RENT"
        case seQasaShortTermRental = "SE_QASA_SHORT_TERM_RENTAL"
        case seQasaLongTermRental = "SE_QASA_LONG_TERM_RENTAL"
        case seDogBasic = "SE_DOG_BASIC"
        case seDogStandard = "SE_DOG_STANDARD"
        case seDogPremium = "SE_DOG_PREMIUM"
        case seCatBasic = "SE_CAT_BASIC"
        case seCatStandard = "SE_CAT_STANDARD"
        case seCatPremium = "SE_CAT_PREMIUM"
        case noHouse = "NO_HOUSE"
        case noHomeContentOwn = "NO_HOME_CONTENT_OWN"
        case noHomeContentRent = "NO_HOME_CONTENT_RENT"
        case noHomeContentYouthOwn = "NO_HOME_CONTENT_YOUTH_OWN"
        case noHomeContentYouthRent = "NO_HOME_CONTENT_YOUTH_RENT"
        case noHomeContentStudentOwn = "NO_HOME_CONTENT_STUDENT_OWN"
        case noHomeContentStudentRent = "NO_HOME_CONTENT_STUDENT_RENT"
        case noTravel = "NO_TRAVEL"
        case noTravelYouth = "NO_TRAVEL_YOUTH"
        case noTravelStudent = "NO_TRAVEL_STUDENT"
        case noAccident = "NO_ACCIDENT"
        case dkHomeContentOwn = "DK_HOME_CONTENT_OWN"
        case dkHomeContentRent = "DK_HOME_CONTENT_RENT"
        case dkHomeContentStudentOwn = "DK_HOME_CONTENT_STUDENT_OWN"
        case dkHomeContentStudentRent = "DK_HOME_CONTENT_STUDENT_RENT"
        case dkHouse = "DK_HOUSE"
        case dkAccident = "DK_ACCIDENT"
        case dkAccidentStudent = "DK_ACCIDENT_STUDENT"
        case dkTravel = "DK_TRAVEL"
        case dkTravelStudent = "DK_TRAVEL_STUDENT"
        case unknown = "UNKNOWN"

        static func resolve(for typeOfContract: GiraffeGraphQL.TypeOfContract) -> Self {
            if let concreteTypeOfContract = Self(rawValue: typeOfContract.rawValue) {
                return concreteTypeOfContract
            }

            log.warn(
                "Got an unknown type of contract \(typeOfContract.rawValue) that couldn't be resolved.",
                error: nil,
                attributes: nil
            )
            return .unknown
        }
    }
}

extension Contract.TypeOfContract {
    var gradientOption: Contract.GradientOption {
        switch self {
        case .seHouse:
            return .house
        case .seApartmentBrf:
            return .home
        case .seApartmentRent:
            return .home
        case .seApartmentStudentBrf:
            return .home
        case .seApartmentStudentRent:
            return .home
        case .seAccident:
            return .accident
        case .seAccidentStudent:
            return .accident
        case .seCarTraffic:
            return .car
        case .seCarHalf:
            return .car
        case .seCarFull:
            return .car
        case .seGroupApartmentRent:
            return .home
        case .seQasaShortTermRental:
            return .home
        case .seQasaLongTermRental:
            return .home
        case .seDogBasic:
            return .pet
        case .seDogStandard:
            return .pet
        case .seDogPremium:
            return .pet
        case .seCatBasic:
            return .pet
        case .seCatStandard:
            return .pet
        case .seCatPremium:
            return .pet
        case .noHouse:
            return .house
        case .noHomeContentOwn:
            return .home
        case .noHomeContentRent:
            return .home
        case .noHomeContentYouthOwn:
            return .home
        case .noHomeContentYouthRent:
            return .home
        case .noHomeContentStudentOwn:
            return .home
        case .noHomeContentStudentRent:
            return .home
        case .noTravel:
            return .travel
        case .noTravelYouth:
            return .travel
        case .noTravelStudent:
            return .travel
        case .noAccident:
            return .accident
        case .dkHomeContentOwn:
            return .home
        case .dkHomeContentRent:
            return .home
        case .dkHomeContentStudentOwn:
            return .home
        case .dkHomeContentStudentRent:
            return .home
        case .dkHouse:
            return .house
        case .dkAccident:
            return .accident
        case .dkAccidentStudent:
            return .accident
        case .dkTravel:
            return .travel
        case .dkTravelStudent:
            return .travel
        case .unknown:
            return .unknown
        }
    }
}

extension Contract {
    /// Does this contract have a co insured concept, i.e covers multiple people, and thus can change that
    public var canChangeCoInsured: Bool {
        switch typeOfContract {
        case .seHouse:
            return true
        case .seApartmentBrf:
            return true
        case .seApartmentRent:
            return true
        case .seApartmentStudentBrf:
            return true
        case .seApartmentStudentRent:
            return true
        case .seAccident:
            return true
        case .seAccidentStudent:
            return true
        case .seCarTraffic:
            return false
        case .seCarHalf:
            return false
        case .seCarFull:
            return false
        case .seGroupApartmentRent:
            return false
        case .seQasaShortTermRental:
            return false
        case .seQasaLongTermRental:
            return false
        case .seDogBasic:
            return false
        case .seDogStandard:
            return false
        case .seDogPremium:
            return false
        case .seCatBasic:
            return false
        case .seCatStandard:
            return false
        case .seCatPremium:
            return false
        case .noHouse:
            return true
        case .noHomeContentOwn:
            return true
        case .noHomeContentRent:
            return true
        case .noHomeContentYouthOwn:
            return true
        case .noHomeContentYouthRent:
            return true
        case .noHomeContentStudentOwn:
            return true
        case .noHomeContentStudentRent:
            return true
        case .noTravel:
            return true
        case .noTravelYouth:
            return true
        case .noTravelStudent:
            return true
        case .noAccident:
            return true
        case .dkHomeContentOwn:
            return true
        case .dkHomeContentRent:
            return true
        case .dkHomeContentStudentOwn:
            return true
        case .dkHomeContentStudentRent:
            return true
        case .dkHouse:
            return true
        case .dkAccident:
            return true
        case .dkAccidentStudent:
            return true
        case .dkTravel:
            return true
        case .dkTravelStudent:
            return true
        case .unknown:
            return false
        }
    }
}

public struct UpcomingRenewal: Codable, Hashable {
    public let renewalDate: String?
    public let draftCertificateUrl: String?

    init(
        renewalDate: String,
        draftCertificateUrl: String
    ) {
        self.renewalDate = renewalDate
        self.draftCertificateUrl = draftCertificateUrl
    }

    init(
        upcomingRenewal: GiraffeGraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract.UpcomingRenewal?
    ) {
        renewalDate = upcomingRenewal?.renewalDate
        draftCertificateUrl = upcomingRenewal?.draftCertificateUrl
    }
}

public struct TermsAndConditions: Identifiable, Codable, Hashable {
    public init(
        displayName: String,
        url: String
    ) {
        self.displayName = displayName
        self.url = url
    }

    public var id: String {
        displayName + url
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
        fragment: GiraffeGraphQL.DetailsTableFragment
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
            section: GiraffeGraphQL.DetailsTableFragment.Section
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
            row: GiraffeGraphQL.DetailsTableFragment.Section.Row
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
    public let color: String?
    public let covered: [String]
    public let exceptions: [String]

    public init(
        fragment: GiraffeGraphQL.PerilFragment
    ) {
        title = fragment.title
        description = fragment.description
        icon = .init(fragment: fragment.icon.fragments.iconFragment)
        covered = fragment.covered
        exceptions = fragment.exceptions
        color = nil
    }
    
    public init(
        fragment: OctopusGraphQL.ProductVariantFragment.Peril
    ) {
        title = fragment.title
        description = fragment.description
        icon = nil
        covered = fragment.covered
        exceptions = fragment.exceptions
        color = fragment.colorCode
    }
}

public struct InsurableLimits: Codable, Hashable {
    public let label: String
    public let limit: String
    public let description: String

    public init(
        fragment: GiraffeGraphQL.InsurableLimitFragment
    ) {
        label = fragment.label
        limit = fragment.limit
        description = fragment.description
    }
    
    init(
        _ data: OctopusGraphQL.ProductVariantFragment.InsurableLimit
    ) {
        label = data.label
        limit = data.limit
        description = data.description
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
        currentAgreement: GiraffeGraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract.CurrentAgreement?
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
        currentAgreement: GiraffeGraphQL.ContractsQuery.Data.Contract.CurrentAgreement?
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
        fragment: GiraffeGraphQL.MonetaryAmountFragment
    ) {
        amount = fragment.amount
        currency = fragment.currency
    }

    public init(
        fragment: OctopusGraphQL.MoneyFragment
    ) {
        amount = String(fragment.amount)
        currency = fragment.currencyCode.rawValue
    }

    public var amount: String
    public var currency: String
}
