import Foundation
import hGraphQL
import hCoreUI
import hCore

public struct ActiveContractBundle: Codable, Equatable, Hashable {
    public var contracts: [Contract]
    public var id: String
    public var movingFlowEmbarkId: String?

    public init(
        bundle: GiraffeGraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle
    ) {
//        contracts = bundle.contracts.map { .init(contract: $0) }
        contracts = []
        id = bundle.id
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

//public struct ContractGiraffe: Codable, Hashable, Equatable {
//    public init(
//        id: String,
//        typeOfContract: TypeOfContract,
//        upcomingAgreementsTable: DetailAgreementsTable,
//        currentAgreementsTable: DetailAgreementsTable?,
//        logo: IconEnvelope?,
//        displayName: String,
//        switchedFromInsuranceProvider: String?,
//        upcomingRenewal: UpcomingRenewal?,
//        contractPerils: [Perils],
//        insurableLimits: [InsurableLimits],
//        termsAndConditions: TermsAndConditions,
//        currentAgreement: CurrentAgreement,
//        statusPills: [String],
//        detailPills: [String],
//        showsMovingFlowButton: Bool = false,
//        upcomingAgreementDate: Date? = nil,
//        terminationDate: Date? = nil
//    ) {
//        self.id = id
//        self.typeOfContract = typeOfContract
//        self.upcomingAgreementsTable = upcomingAgreementsTable
//        self.currentAgreementsTable = currentAgreementsTable
//        self.logo = logo
//        self.displayName = displayName
//        self.switchedFromInsuranceProvider = switchedFromInsuranceProvider
//        self.upcomingRenewal = upcomingRenewal
//        self.contractPerils = contractPerils
//        self.insurableLimits = insurableLimits
//        self.termsAndConditions = termsAndConditions
//        self.currentAgreement = currentAgreement
//        self.statusPills = statusPills
//        self.detailPills = detailPills
//        self.showsMovingFlowButton = showsMovingFlowButton
//        self.upcomingAgreementDate = nil
//        self.terminationDate = terminationDate
//    }
//
//    public let id: String
//    public let typeOfContract: TypeOfContract
//    public let upcomingAgreementsTable: DetailAgreementsTable
//    public let currentAgreementsTable: DetailAgreementsTable?
//    public var pillowType: PillowType? {
//        if self.currentAgreement?.status == .terminated {
//            return nil
//        }
//
//        return self.typeOfContract.pillowType
//    }
//
//    public let logo: IconEnvelope?
//    public let displayName: String
//    public let switchedFromInsuranceProvider: String?
//    public let upcomingRenewal: UpcomingRenewal?
//    public let contractPerils: [Perils]
//    public let insurableLimits: [InsurableLimits]
//    public let termsAndConditions: TermsAndConditions
//    public let currentAgreement: CurrentAgreement?
//    public let statusPills: [String]
//    public let detailPills: [String]
//    public let showsMovingFlowButton: Bool
//    public let upcomingAgreementDate: Date?
//    public let terminationDate: Date?
//
//    init(
//        contract: GiraffeGraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle.Contract
//    ) {
//        id = contract.id
//        typeOfContract = TypeOfContract.resolve(for: contract.typeOfContract)
//        upcomingAgreementsTable = .init(
//            fragment: contract.upcomingAgreementDetailsTable.fragments.detailsTableFragment
//        )
//        currentAgreementsTable = .init(
//            fragment: contract.currentAgreementDetailsTable.fragments.detailsTableFragment
//        )
//        upcomingRenewal = .init(upcomingRenewal: contract.upcomingRenewal)
//        contractPerils = contract.contractPerils.map { .init(fragment: $0.fragments.perilFragment) }
//        insurableLimits = contract.insurableLimits.map { .init(fragment: $0.fragments.insurableLimitFragment) }
//        termsAndConditions = .init(
//            displayName: contract.termsAndConditions.displayName,
//            url: contract.termsAndConditions.url
//        )
//        currentAgreement = .init(currentAgreement: contract.currentAgreement)
//        displayName = contract.displayName
//        switchedFromInsuranceProvider = contract.switchedFromInsuranceProvider
//        statusPills = contract.statusPills
//        detailPills = contract.detailPills
//        if let logo = contract.logo {
//            self.logo = .init(fragment: logo.fragments.iconFragment)
//        } else {
//            self.logo = nil
//        }
//
//        showsMovingFlowButton = contract.supportsAddressChange
//        upcomingAgreementDate =
//            contract.status.asActiveStatus?.upcomingAgreementChange?.newAgreement.activeFrom?.localDateToDate
//        terminationDate = contract.termination?.localDateToDate
//    }
//
//    public init(
//        contract: GiraffeGraphQL.ContractsQuery.Data.Contract
//    ) {
//        id = contract.id
//        typeOfContract = TypeOfContract.resolve(for: contract.typeOfContract)
//        upcomingAgreementsTable = .init(
//            fragment: contract.upcomingAgreementDetailsTable.fragments.detailsTableFragment
//        )
//        currentAgreementsTable = .init(fragment: contract.currentAgreementDetailsTable.fragments.detailsTableFragment)
//        upcomingRenewal = nil
//        contractPerils = contract.contractPerils.map { .init(fragment: $0.fragments.perilFragment) }
//        insurableLimits = contract.insurableLimits.map { .init(fragment: $0.fragments.insurableLimitFragment) }
//        termsAndConditions = .init(
//            displayName: contract.termsAndConditions.displayName,
//            url: contract.termsAndConditions.url
//        )
//        currentAgreement = .init(currentAgreement: contract.currentAgreement)
//        displayName = contract.displayName
//        switchedFromInsuranceProvider = contract.switchedFromInsuranceProvider
//        statusPills = contract.statusPills
//        detailPills = contract.detailPills
//
//        if let logo = contract.logo {
//            self.logo = .init(fragment: logo.fragments.iconFragment)
//        } else {
//            self.logo = nil
//        }
//
//        showsMovingFlowButton = false
//        upcomingAgreementDate = nil
//        terminationDate = nil
//    }
//
//    public enum PillowType: Codable {
//        case accident
//        case car
//        case cat
//        case dog
//        case home
//        case homeOwner
//        case pet
//        case rental
//        case student
//        case travel
//        case villa
//        case unknown
//    }
//
//    public enum TypeOfContract: String, Codable {
//        case seHouse = "SE_HOUSE"
//        case seApartmentBrf = "SE_APARTMENT_BRF"
//        case seApartmentRent = "SE_APARTMENT_RENT"
//        case seApartmentStudentBrf = "SE_APARTMENT_STUDENT_BRF"
//        case seApartmentStudentRent = "SE_APARTMENT_STUDENT_RENT"
//        case seAccident = "SE_ACCIDENT"
//        case seAccidentStudent = "SE_ACCIDENT_STUDENT"
//        case seCarTraffic = "SE_CAR_TRAFFIC"
//        case seCarHalf = "SE_CAR_HALF"
//        case seCarFull = "SE_CAR_FULL"
//        case seGroupApartmentBrf = "SE_GROUP_APARTMENT_BRF"
//        case seGroupApartmentRent = "SE_GROUP_APARTMENT_RENT"
//        case seQasaShortTermRental = "SE_QASA_SHORT_TERM_RENTAL"
//        case seQasaLongTermRental = "SE_QASA_LONG_TERM_RENTAL"
//        case seDogBasic = "SE_DOG_BASIC"
//        case seDogStandard = "SE_DOG_STANDARD"
//        case seDogPremium = "SE_DOG_PREMIUM"
//        case seCatBasic = "SE_CAT_BASIC"
//        case seCatStandard = "SE_CAT_STANDARD"
//        case seCatPremium = "SE_CAT_PREMIUM"
//        case noHouse = "NO_HOUSE"
//        case noHomeContentOwn = "NO_HOME_CONTENT_OWN"
//        case noHomeContentRent = "NO_HOME_CONTENT_RENT"
//        case noHomeContentYouthOwn = "NO_HOME_CONTENT_YOUTH_OWN"
//        case noHomeContentYouthRent = "NO_HOME_CONTENT_YOUTH_RENT"
//        case noHomeContentStudentOwn = "NO_HOME_CONTENT_STUDENT_OWN"
//        case noHomeContentStudentRent = "NO_HOME_CONTENT_STUDENT_RENT"
//        case noTravel = "NO_TRAVEL"
//        case noTravelYouth = "NO_TRAVEL_YOUTH"
//        case noTravelStudent = "NO_TRAVEL_STUDENT"
//        case noAccident = "NO_ACCIDENT"
//        case dkHomeContentOwn = "DK_HOME_CONTENT_OWN"
//        case dkHomeContentRent = "DK_HOME_CONTENT_RENT"
//        case dkHomeContentStudentOwn = "DK_HOME_CONTENT_STUDENT_OWN"
//        case dkHomeContentStudentRent = "DK_HOME_CONTENT_STUDENT_RENT"
//        case dkHouse = "DK_HOUSE"
//        case dkAccident = "DK_ACCIDENT"
//        case dkAccidentStudent = "DK_ACCIDENT_STUDENT"
//        case dkTravel = "DK_TRAVEL"
//        case dkTravelStudent = "DK_TRAVEL_STUDENT"
//        case unknown = "UNKNOWN"
//
//        static func resolve(for typeOfContract: GiraffeGraphQL.TypeOfContract) -> Self {
//            if let concreteTypeOfContract = Self(rawValue: typeOfContract.rawValue) {
//                return concreteTypeOfContract
//            }
//
//            log.warn(
//                "Got an unknown type of contract \(typeOfContract.rawValue) that couldn't be resolved.",
//                error: nil,
//                attributes: nil
//            )
//            return .unknown
//        }
//        fileprivate static let insurancesSuitableForTravelInsurance: [ContractGiraffe.TypeOfContract] = [
//            .seHouse,
//            .seApartmentBrf,
//            .seApartmentRent,
//            .seApartmentStudentBrf,
//            .seApartmentStudentRent,
//        ]
//    }
//
//    public var hasTravelInsurance: Bool {
//        let suitableType = ContractGiraffe.TypeOfContract.insurancesSuitableForTravelInsurance.contains(self.typeOfContract)
//        let isNotInTerminationProcess = terminationDate == nil
//        return suitableType && isNotInTerminationProcess
//    }
//
//    public func getDetails() -> String {
//        detailPills.joined(separator: " · ")
//    }
//}

public struct ProductVariant: Codable, Hashable {
    let termsVersion: String
    let typeOfContract: String
    let partner: String?
    let perils: [Perils]
    let insurableLimits: [InsurableLimits]
    let documents: [InsuranceTerm]
    let highlights: [Highlight]
    let FAQ: [FAQ]?
    let displayName: String
    
    init(
        termsVersion: String,
        typeOfContract: String,
        partner: String?,
        perils: [Perils],
        insurableLimits: [InsurableLimits],
        documents: [InsuranceTerm],
        highlights: [Highlight],
        FAQ: [FAQ]?,
        displayName: String
    ) {
        self.termsVersion = termsVersion
        self.typeOfContract = typeOfContract
        self.partner = partner
        self.perils = perils
        self.insurableLimits = insurableLimits
        self.documents = documents
        self.highlights = highlights
        self.FAQ = FAQ
        self.displayName = displayName
    }
    
    init(
        data: OctopusGraphQL.ProductVariantFragment
    ) {
        self.displayName = data.displayName
        self.termsVersion = data.termsVersion
        self.typeOfContract = data.typeOfContract
        self.partner = data.partner ?? ""
        self.perils = data.perils.map({  .init(fragment: $0) })
        self.insurableLimits = data.insurableLimits.map({ .init($0) })
        self.documents = data.documents.map({ .init($0) })
        self.highlights = data.highlights.map({  .init($0) })
        self.FAQ = data.faq.map({  .init($0) })
    }
    
}

public struct Contract: Codable, Hashable, Equatable {
    
    public init(
        id: String,
        currentAgreement: Agreement,
        exposureDisplayName: String,
        externalInsuranceCancellation: ContractExternalInsuranceCancellation,
        masterInceptionDate: String,
        terminationDate: String?,
        supportsAddressChange: Bool,
        upcomingChangedAgreement: Agreement,
        upcomingRenewal: ContractRenewal
    ) {
        self.id = id
        self.currentAgreement = currentAgreement
        self.exposureDisplayName = exposureDisplayName
        self.externalInsuranceCancellation = externalInsuranceCancellation
        self.masterInceptionDate = masterInceptionDate
        self.terminationDate = terminationDate
        self.supportsAddressChange = supportsAddressChange
        self.upcomingChangedAgreement = upcomingChangedAgreement
        self.upcomingRenewal = upcomingRenewal
    }

    public let id: String
    public let currentAgreement: Agreement
    public let exposureDisplayName: String
    public let externalInsuranceCancellation: ContractExternalInsuranceCancellation?
    public let masterInceptionDate: String
    public let terminationDate: String?
    public let supportsAddressChange: Bool
    public let upcomingChangedAgreement: Agreement?
    public let upcomingRenewal: ContractRenewal


    init(
        contract: OctopusGraphQL.ContractQuery.Data.Contract
    ) {
        id = contract.id
        
        currentAgreement = .init(agreement: contract.currentAgreement.fragments.agreementFragment)
        ?? Agreement(certificateUrl: "", activeFrom: "", activeTo: "", premium: MonetaryAmount(amount: 0, currency: ""), displayItems: [], productVariant: ProductVariant(termsVersion: "", typeOfContract: "", partner: nil, perils: [], insurableLimits: [], documents: [], highlights: [], FAQ: [], displayName: ""))
        
        exposureDisplayName = contract.exposureDisplayName
        if let cancellation = contract.externalInsuranceCancellation {
            externalInsuranceCancellation = .init(data: cancellation.fragments.contractExternalInsuranceCancellationFragment)
        } else {
            externalInsuranceCancellation = nil
        }
        masterInceptionDate = contract.masterInceptionDate
        terminationDate = contract.terminationDate
        supportsAddressChange = contract.supportsAddressChange
        upcomingChangedAgreement = .init(agreement: contract.upcomingChangedAgreement?.fragments.agreementFragment)
        upcomingRenewal = .init(upcomingRenewal: contract.upcomingRenewal)
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
        case seGroupApartmentBrf = "SE_GROUP_APARTMENT_BRF"
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
        fileprivate static let insurancesSuitableForTravelInsurance: [Contract.TypeOfContract] = [
            .seHouse,
            .seApartmentBrf,
            .seApartmentRent,
            .seApartmentStudentBrf,
            .seApartmentStudentRent,
        ]
    }

//    public var hasTravelInsurance: Bool {
//        let suitableType = Contract.TypeOfContract.insurancesSuitableForTravelInsurance.contains(self.typeOfContract)
//        let isNotInTerminationProcess = terminationDate == nil
//        return suitableType && isNotInTerminationProcess
//    }
//
//    public func getDetails() -> String {
//        detailPills.joined(separator: " · ")
//    }
}


//extension Contract.TypeOfContract {
//    public var pillowType: PillowType {
//        switch self {
//        case .seHouse:
//            return .villa
//        case .seApartmentBrf:
//            return .homeOwner
//        case .seGroupApartmentBrf:
//            return .homeOwner
//        case .seApartmentRent:
//            return .rental
//        case .seApartmentStudentBrf:
//            return .student
//        case .seApartmentStudentRent:
//            return .student
//        case .seAccident:
//            return .accident
//        case .seAccidentStudent:
//            return .accident
//        case .seCarTraffic:
//            return .car
//        case .seCarHalf:
//            return .car
//        case .seCarFull:
//            return .car
//        case .seGroupApartmentRent:
//            return .rental
//        case .seQasaShortTermRental:
//            return .rental
//        case .seQasaLongTermRental:
//            return .rental
//        case .seDogBasic:
//            return .dog
//        case .seDogStandard:
//            return .dog
//        case .seDogPremium:
//            return .dog
//        case .seCatBasic:
//            return .cat
//        case .seCatStandard:
//            return .cat
//        case .seCatPremium:
//            return .cat
//        case .noHouse:
//            return .villa
//        case .noHomeContentOwn:
//            return .homeOwner
//        case .noHomeContentRent:
//            return .rental
//        case .noHomeContentYouthOwn:
//            return .homeOwner
//        case .noHomeContentYouthRent:
//            return .rental
//        case .noHomeContentStudentOwn:
//            return .student
//        case .noHomeContentStudentRent:
//            return .student
//        case .noTravel:
//            return .travel
//        case .noTravelYouth:
//            return .travel
//        case .noTravelStudent:
//            return .travel
//        case .noAccident:
//            return .accident
//        case .dkHomeContentOwn:
//            return .homeOwner
//        case .dkHomeContentRent:
//            return .rental
//        case .dkHomeContentStudentOwn:
//            return .homeOwner
//        case .dkHomeContentStudentRent:
//            return .rental
//        case .dkHouse:
//            return .villa
//        case .dkAccident:
//            return .accident
//        case .dkAccidentStudent:
//            return .accident
//        case .dkTravel:
//            return .travel
//        case .dkTravelStudent:
//            return .travel
//        case .unknown:
//            return .unknown
//        }
//    }
//}


//extension ContractGiraffe {
//    /// Does this contract have a co insured concept, i.e covers multiple people, and thus can change that
//    public var canChangeCoInsured: Bool {
//        switch typeOfContract {
//        case .seHouse:
//            return true
//        case .seApartmentBrf:
//            return true
//        case .seApartmentRent:
//            return true
//        case .seApartmentStudentBrf:
//            return true
//        case .seApartmentStudentRent:
//            return true
//        case .seAccident:
//            return true
//        case .seAccidentStudent:
//            return true
//        case .seCarTraffic:
//            return false
//        case .seCarHalf:
//            return false
//        case .seCarFull:
//            return false
//        case .seGroupApartmentRent:
//            return false
//        case .seQasaShortTermRental:
//            return false
//        case .seQasaLongTermRental:
//            return false
//        case .seDogBasic:
//            return false
//        case .seDogStandard:
//            return false
//        case .seDogPremium:
//            return false
//        case .seCatBasic:
//            return false
//        case .seCatStandard:
//            return false
//        case .seCatPremium:
//            return false
//        case .noHouse:
//            return true
//        case .noHomeContentOwn:
//            return true
//        case .noHomeContentRent:
//            return true
//        case .noHomeContentYouthOwn:
//            return true
//        case .noHomeContentYouthRent:
//            return true
//        case .noHomeContentStudentOwn:
//            return true
//        case .noHomeContentStudentRent:
//            return true
//        case .noTravel:
//            return true
//        case .noTravelYouth:
//            return true
//        case .noTravelStudent:
//            return true
//        case .noAccident:
//            return true
//        case .dkHomeContentOwn:
//            return true
//        case .dkHomeContentRent:
//            return true
//        case .dkHomeContentStudentOwn:
//            return true
//        case .dkHomeContentStudentRent:
//            return true
//        case .dkHouse:
//            return true
//        case .dkAccident:
//            return true
//        case .dkAccidentStudent:
//            return true
//        case .dkTravel:
//            return true
//        case .dkTravelStudent:
//            return true
//        case .unknown:
//            return false
//        case .seGroupApartmentBrf:
//            return true
//        }
//    }
//}

public struct ContractRenewal: Codable, Hashable {
    public let renewalDate: String
    public let draftCertificateUrl: String?

    init(
        renewalDate: String,
        draftCertificateUrl: String
    ) {
        self.renewalDate = renewalDate
        self.draftCertificateUrl = draftCertificateUrl
    }

    init(
        upcomingRenewal: OctopusGraphQL.ContractQuery.Data.Contract.UpcomingRenewal
    ) {
        renewalDate = upcomingRenewal.renewalDate
        draftCertificateUrl = upcomingRenewal.draftCertificateUrl
    }
}

//public struct TermsAndConditions: Identifiable, Codable, Hashable {
//    public init(
//        displayName: String,
//        url: String
//    ) {
//        self.displayName = displayName
//        self.url = url
//    }
//
//    public var id: String {
//        displayName + url
//    }
//
//    public let displayName: String
//    public let url: String
//}

//public struct AngelStories: Codable {
//    public let addressChange: String
//}

//public struct DetailAgreementsTable: Codable, Hashable, Identifiable {
//    public init(
//        sections: [DetailAgreementsTable.Section],
//        title: String
//    ) {
//        self.sections = sections
//        self.title = title
//    }
//
//    public var id: String {
//        return title
//    }
//    public let sections: [Section]
//    public let title: String
//    public init(
//        fragment: GiraffeGraphQL.DetailsTableFragment
//    ) {
//        sections = fragment.sections.map { .init(section: $0) }
//        title = fragment.title
//    }
//
//    public struct Section: Codable, Hashable, Identifiable {
//        public init(
//            title: String,
//            rows: [DetailAgreementsTable.Row]
//        ) {
//            self.title = title
//            self.rows = rows
//        }
//
//        public var id: String {
//            return title
//        }
//        public let title: String
//        public let rows: [Row]
//
//        init(
//            section: GiraffeGraphQL.DetailsTableFragment.Section
//        ) {
//            title = section.title
//            rows = section.rows.map { .init(row: $0) }
//        }
//    }
//
//    public struct Row: Codable, Hashable {
//        public init(
//            title: String,
//            subtitle: String?,
//            value: String
//        ) {
//            self.title = title
//            self.subtitle = subtitle
//            self.value = value
//        }
//
//        public let title: String
//        public let subtitle: String?
//        public let value: String
//        init(
//            row: GiraffeGraphQL.DetailsTableFragment.Section.Row
//        ) {
//            title = row.title
//            subtitle = row.subtitle
//            value = row.value
//        }
//    }
//}

public struct Agreement: Codable, Hashable {
    public init(
        certificateUrl: String,
        activeFrom: String,
        activeTo: String,
        premium: MonetaryAmount,
        displayItems: [AgreementDisplayItem],
        productVariant: ProductVariant
    ) {
        self.certificateUrl = certificateUrl
        self.activeFrom = activeFrom
        self.activeTo = activeTo
        self.premium = premium
        self.displayItems = displayItems
        self.productVariant = productVariant
    }

    public let certificateUrl: String?
    public let activeFrom: String?
    public let activeTo: String?
    public let premium: MonetaryAmount
    public let displayItems: [AgreementDisplayItem]
    public let productVariant: ProductVariant

    init?(
        agreement: OctopusGraphQL.AgreementFragment?
    ) {
        guard let agreement = agreement else {
            return nil
        }
        certificateUrl = agreement.certificateUrl
        activeFrom = agreement.activeFrom
        activeTo = agreement.activeTo
        premium = .init(fragment: agreement.premium.fragments.moneyFragment)
        displayItems = agreement.displayItems.map({ .init(data: $0.fragments.agreementDisplayItemFragment) })
        productVariant = .init(data: agreement.productVariant.fragments.productVariantFragment)
    }

}

public struct AgreementDisplayItem: Codable, Hashable {
    let displayTitle: String
    let displayValue: String
    
    public init(
        data: OctopusGraphQL.AgreementDisplayItemFragment
    ) {
        self.displayTitle = data.displayTitle
        self.displayValue = data.displayValue
    }
}

public struct ContractExternalInsuranceCancellation: Codable, Hashable {
    let id: String
    let bankSigning: BankSigning?
    let externalInsurer: ExternalInsurer
    let status: ContractExternalInsuranceCancellationStatus
    let type: ContractExternalInsuranceCancellationType
    
    public init(
        data: OctopusGraphQL.ContractExternalInsuranceCancellationFragment
    ) {
        self.id = data.id
        if let bankSigning = data.bankSignering {
            self.bankSigning = BankSigning(approvedByDate: bankSigning.approveByDate, url: bankSigning.url)
        } else {
            bankSigning = nil
        }
        self.externalInsurer = ExternalInsurer(id: data.externalInsurer.id, displayName: data.externalInsurer.displayName, insurelyId: data.externalInsurer.insurelyId)
        self.status = ContractExternalInsuranceCancellationStatus.resolve(for: data.status)
        self.type = ContractExternalInsuranceCancellationType.resolve(for: data.type)
    }
    
    struct BankSigning: Codable, Hashable {
        let approvedByDate: String
        let url: String?
        
        init(
            approvedByDate: String,
            url: String?
        ) {
            self.approvedByDate = approvedByDate
            self.url = url
        }
    }
    
    struct ExternalInsurer: Codable, Hashable {
        let id: String
        let displayName: String
        let insurelyId: String?
        
        init(
            id: String,
            displayName: String,
            insurelyId: String?
        ) {
            self.id = id
            self.displayName = displayName
            self.insurelyId = insurelyId
        }
    }
    
    public enum ContractExternalInsuranceCancellationStatus: String, Codable {
        case notInitiated = "NOT_INITIATED"
        case initiated = "INITIATED"
        case completed = "COMPLETED"
        case unknown = "UNKNOWN"
        
        static func resolve(for status: OctopusGraphQL.ContractExternalInsuranceCancellationStatus) -> Self {
            if let concreteStatus = Self(rawValue: status.rawValue) {
                return concreteStatus
            }
            
            log.warn(
                "Got an unknown type of status \(status.rawValue) that couldn't be resolved.",
                error: nil,
                attributes: nil
            )
            return .unknown
        }
    }
    
    public enum ContractExternalInsuranceCancellationType: String, Codable {
        case bankSigned = "BANKSIGNERING"
        case unknown = "UNKNOWN"
        
        static func resolve(for type: OctopusGraphQL.ContractExternalInsuranceCancellationType) -> Self {
            if let concreteType = Self(rawValue: type.rawValue) {
                return concreteType
            }
            
            log.warn(
                "Got an unknown type of status \(type.rawValue) that couldn't be resolved.",
                error: nil,
                attributes: nil
            )
            return .unknown
        }
    }
}
