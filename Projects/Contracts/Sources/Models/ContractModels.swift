import Foundation
import hCore
import hCoreUI
import hGraphQL

extension String {
    // converts a YYYY-MM-DD date-string to a Date
    var localDateToDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}

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
        self.perils = data.perils.map({ .init(fragment: $0) })
        self.insurableLimits = data.insurableLimits.map({ .init($0) })
        self.documents = data.documents.map({ .init($0) })
        self.highlights = data.highlights.map({ .init($0) })
        self.FAQ = data.faq.map({ .init($0) })
    }

}

public struct Contract: Codable, Hashable, Equatable {
    public init(
        id: String,
        currentAgreement: Agreement,
        exposureDisplayName: String,
        masterInceptionDate: String,
        terminationDate: String?,
        supportsAddressChange: Bool,
        upcomingChangedAgreement: Agreement,
        upcomingRenewal: ContractRenewal,
        typeOfContract: TypeOfContract
    ) {
        self.id = id
        self.currentAgreement = currentAgreement
        self.exposureDisplayName = exposureDisplayName
        self.masterInceptionDate = masterInceptionDate
        self.terminationDate = terminationDate
        self.supportsAddressChange = supportsAddressChange
        self.upcomingChangedAgreement = upcomingChangedAgreement
        self.upcomingRenewal = upcomingRenewal
        self.typeOfContract = typeOfContract
    }

    public let id: String
    public let currentAgreement: Agreement?
    public let exposureDisplayName: String
    public let masterInceptionDate: String?
    public let terminationDate: String?
    public let supportsAddressChange: Bool
    public let upcomingChangedAgreement: Agreement?
    public let upcomingRenewal: ContractRenewal?
    public let typeOfContract: TypeOfContract
    public var coInsured: [CoInsuredModel] = [CoInsuredModel(name: "Julia", SSN: "000000000")] /* TODO: CHANGE TO VAR */

    public var showEditInfo: Bool {
        return !EditType.getTypes(for: self).isEmpty && self.terminationDate == nil
    }

    public var canTerminate: Bool {
        return terminationDate == nil
    }

    public var terminatedToday: Bool {
        if terminationDate == Date().localDateString {
            return true
        }
        return false
    }
    public var activeInFuture: Bool {
        if let inceptionDate = masterInceptionDate?.localDateToDate,
            let localDate = Date().localDateString.localDateToDate,
            inceptionDate.daysBetween(start: localDate) > 0
        {
            return true
        }
        return false
    }
    public var pillowType: PillowType? {
        if let terminationDate = terminationDate?.localDateToDate,
            let localDate = Date().localDateString.localDateToDate
        {
            let daysBetween = terminationDate.daysBetween(start: localDate)
            if daysBetween < 0 {
                return nil
            }
        }
        return self.typeOfContract.pillowType
    }

    init(
        pendingContract: OctopusGraphQL.ContractBundleQuery.Data.CurrentMember.PendingContract
    ) {
        exposureDisplayName = pendingContract.exposureDisplayName
        id = pendingContract.id
        currentAgreement = .init(
            premium: .init(fragment: pendingContract.premium.fragments.moneyFragment),
            displayItems: pendingContract.displayItems.map({ .init(data: $0.fragments.agreementDisplayItemFragment) }),
            productVariant: .init(data: pendingContract.productVariant.fragments.productVariantFragment)
        )
        masterInceptionDate = nil
        terminationDate = nil
        supportsAddressChange = false
        upcomingChangedAgreement = nil
        upcomingRenewal = nil
        typeOfContract = TypeOfContract.resolve(for: pendingContract.productVariant.typeOfContract)
    }

    init(
        contract: OctopusGraphQL.ContractFragment
    ) {
        id = contract.id
        currentAgreement =
            .init(agreement: contract.currentAgreement.fragments.agreementFragment)
        exposureDisplayName = contract.exposureDisplayName
        masterInceptionDate = contract.masterInceptionDate
        terminationDate = contract.terminationDate
        supportsAddressChange = contract.supportsMoving
        upcomingChangedAgreement = .init(agreement: contract.upcomingChangedAgreement?.fragments.agreementFragment)
        upcomingRenewal = .init(upcoming: contract.upcomingChangedAgreement?.fragments.agreementFragment)
        typeOfContract = TypeOfContract.resolve(for: contract.currentAgreement.productVariant.typeOfContract)
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

        static func resolve(for typeOfContract: String) -> Self {
            if let concreteTypeOfContract = Self(rawValue: typeOfContract) {
                return concreteTypeOfContract
            }

            log.warn(
                "Got an unknown type of contract \(typeOfContract) that couldn't be resolved.",
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

    public var hasTravelInsurance: Bool {
        let suitableType = Contract.TypeOfContract.insurancesSuitableForTravelInsurance.contains(self.typeOfContract)
        let isNotInTerminationProcess = terminationDate == nil
        return suitableType && isNotInTerminationProcess
    }
}

extension Contract.TypeOfContract {
    public var pillowType: PillowType {
        switch self {
        case .seHouse:
            return .villa
        case .seApartmentBrf:
            return .homeOwner
        case .seGroupApartmentBrf:
            return .homeOwner
        case .seApartmentRent:
            return .rental
        case .seApartmentStudentBrf:
            return .student
        case .seApartmentStudentRent:
            return .student
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
            return .rental
        case .seQasaShortTermRental:
            return .rental
        case .seQasaLongTermRental:
            return .rental
        case .seDogBasic:
            return .dog
        case .seDogStandard:
            return .dog
        case .seDogPremium:
            return .dog
        case .seCatBasic:
            return .cat
        case .seCatStandard:
            return .cat
        case .seCatPremium:
            return .cat
        case .noHouse:
            return .villa
        case .noHomeContentOwn:
            return .homeOwner
        case .noHomeContentRent:
            return .rental
        case .noHomeContentYouthOwn:
            return .homeOwner
        case .noHomeContentYouthRent:
            return .rental
        case .noHomeContentStudentOwn:
            return .student
        case .noHomeContentStudentRent:
            return .student
        case .noTravel:
            return .travel
        case .noTravelYouth:
            return .travel
        case .noTravelStudent:
            return .travel
        case .noAccident:
            return .accident
        case .dkHomeContentOwn:
            return .homeOwner
        case .dkHomeContentRent:
            return .rental
        case .dkHomeContentStudentOwn:
            return .homeOwner
        case .dkHomeContentStudentRent:
            return .rental
        case .dkHouse:
            return .villa
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

extension PillowType {
    public enum PillowType: Codable {
        case accident
        case car
        case cat
        case dog
        case home
        case homeOwner
        case pet
        case rental
        case student
        case travel
        case villa
        case unknown
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
        case .seGroupApartmentBrf:
            return true
        }
    }
}

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

    init?(upcoming: OctopusGraphQL.AgreementFragment?) {
        guard let upcoming = upcoming, upcoming.creationCause == .renewal else { return nil }
        self.renewalDate = upcoming.activeFrom
        self.draftCertificateUrl = upcoming.certificateUrl
    }
}

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

    init(
        premium: MonetaryAmount,
        displayItems: [AgreementDisplayItem],
        productVariant: ProductVariant
    ) {
        self.premium = premium
        self.displayItems = displayItems
        self.productVariant = productVariant
        self.certificateUrl = nil
        self.activeFrom = nil
        self.activeTo = nil
    }

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
