import Foundation

public struct ActiveContractBundle: Codable, Equatable {
    public var contracts: [Contract]
    public var id: String
    public var movingFlowEmbarkId: String?
    public var crossSells: [CrossSell]

    public init(
        bundle: GiraffeGraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle
    ) {
        contracts = bundle.contracts.map { .init(contract: $0) }
        movingFlowEmbarkId = bundle.angelStories.addressChangeV2
        id = bundle.id
        crossSells = bundle.potentialCrossSells.compactMap { CrossSell($0) }
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
        self.gradientOption = gradientOption
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
    public let gradientOption: GradientOption?
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
        typeOfContract = TypeOfContract(rawValue: contract.typeOfContract.rawValue)!
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
        contract: GiraffeGraphQL.ContractsQuery.Data.Contract
    ) {
        id = contract.id
        typeOfContract = TypeOfContract(rawValue: contract.typeOfContract.rawValue)!
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
        case four = "GRADIENT_FOUR"
        case five = "GRADIENT_FIVE"
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
        }
    }
}

public struct UpcomingRenewal: Codable, Hashable {
    public let renewalDate: String?
    public let draftCertificateUrl: String?

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

    public var amount: String
    public var currency: String
}
