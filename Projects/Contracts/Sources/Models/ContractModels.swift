import EditCoInsured
import Foundation
import Presentation
import hCore
import hCoreUI
import hGraphQL

public struct ProductVariant: Codable, Hashable {
    let termsVersion: String
    let typeOfContract: String
    let partner: String?
    let perils: [Perils]
    let insurableLimits: [InsurableLimits]
    let documents: [InsuranceTerm]
    let displayName: String

    init(
        termsVersion: String,
        typeOfContract: String,
        partner: String?,
        perils: [Perils],
        insurableLimits: [InsurableLimits],
        documents: [InsuranceTerm],
        displayName: String
    ) {
        self.termsVersion = termsVersion
        self.typeOfContract = typeOfContract
        self.partner = partner
        self.perils = perils
        self.insurableLimits = insurableLimits
        self.documents = documents
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
    }

}

public struct Contract: Codable, Hashable, Equatable {
    public init(
        id: String,
        currentAgreement: Agreement,
        exposureDisplayName: String,
        masterInceptionDate: String,
        terminationDate: String?,
        selfChangeBlockers: String? = nil,
        supportsAddressChange: Bool,
        supportsCoInsured: Bool,
        upcomingChangedAgreement: Agreement,
        upcomingRenewal: ContractRenewal,
        firstName: String,
        lastName: String,
        ssn: String?,
        typeOfContract: TypeOfContract,
        coInsured: [CoInsuredModel]
    ) {
        self.id = id
        self.currentAgreement = currentAgreement
        self.exposureDisplayName = exposureDisplayName
        self.masterInceptionDate = masterInceptionDate
        self.terminationDate = terminationDate
        self.selfChangeBlockers = selfChangeBlockers
        self.supportsCoInsured = supportsCoInsured
        self.supportsAddressChange = supportsAddressChange
        self.upcomingChangedAgreement = upcomingChangedAgreement
        self.upcomingRenewal = upcomingRenewal
        self.firstName = firstName
        self.lastName = lastName
        self.ssn = ssn
        self.typeOfContract = typeOfContract
        self.coInsured = coInsured
    }

    public let id: String
    public let currentAgreement: Agreement?
    public let exposureDisplayName: String
    public let masterInceptionDate: String?
    public let terminationDate: String?
    public let selfChangeBlockers: String?
    public let supportsAddressChange: Bool
    public let supportsCoInsured: Bool
    public let upcomingChangedAgreement: Agreement?
    public let upcomingRenewal: ContractRenewal?
    public let typeOfContract: TypeOfContract
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

    public var showEditInfo: Bool {
        return supportsCoInsured && self.terminationDate == nil
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

    public var terminationMessage: String? {
        if let terminationDate {
            if typeOfContract.showValidUntilInsteadOfTerminatedAt {
                if terminatedToday {
                    return L10n.contractsTrialTerminationDateMessageTomorrow
                } else {
                    return L10n.contractsTrialTerminationDateMessage(terminationDate)
                }
            } else {
                if terminatedToday {
                    return L10n.contractStatusTerminatedToday
                } else {
                    return L10n.contractStatusToBeTerminated(terminationDate)
                }
            }
        }
        return nil
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
        pendingContract: OctopusGraphQL.ContractBundleQuery.Data.CurrentMember.PendingContract,
        firstName: String,
        lastName: String,
        ssn: String?
    ) {
        exposureDisplayName = pendingContract.exposureDisplayName
        id = pendingContract.id
        currentAgreement = .init(
            premium: .init(fragment: pendingContract.premium.fragments.moneyFragment),
            displayItems: pendingContract.displayItems.map({ .init(data: $0.fragments.agreementDisplayItemFragment) }),
            productVariant: .init(data: pendingContract.productVariant.fragments.productVariantFragment),
            coInsured: []
        )
        masterInceptionDate = nil
        terminationDate = nil
        supportsAddressChange = false
        supportsCoInsured = false
        upcomingChangedAgreement = nil
        upcomingRenewal = nil
        selfChangeBlockers = nil
        typeOfContract = TypeOfContract.resolve(for: pendingContract.productVariant.typeOfContract)
        coInsured = []
        self.firstName = firstName
        self.lastName = lastName
        self.ssn = ssn
    }

    init(
        contract: OctopusGraphQL.ContractFragment,
        firstName: String,
        lastName: String,
        ssn: String?
    ) {
        id = contract.id
        currentAgreement =
            .init(agreement: contract.currentAgreement.fragments.agreementFragment)
        exposureDisplayName = contract.exposureDisplayName
        masterInceptionDate = contract.masterInceptionDate
        terminationDate = contract.terminationDate
        selfChangeBlockers = contract.selfChangeBlockers?.coInsured?.reason
        supportsAddressChange = contract.supportsMoving
        supportsCoInsured = contract.supportsCoInsured
        upcomingChangedAgreement = .init(agreement: contract.upcomingChangedAgreement?.fragments.agreementFragment)
        upcomingRenewal = .init(upcoming: contract.upcomingChangedAgreement?.fragments.agreementFragment)
        typeOfContract = TypeOfContract.resolve(for: contract.currentAgreement.productVariant.typeOfContract)
        coInsured = contract.coInsured?.map({ .init(data: $0.fragments.coInsuredFragment) }) ?? []
        self.firstName = firstName
        self.lastName = lastName
        self.ssn = ssn
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
        case seCarTrialFull = "SE_CAR_TRIAL_FULL"
        case seCarTrialHalf = "SE_CAR_TRIAL_HALF"
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

        public var showValidUntilInsteadOfTerminatedAt: Bool {
            switch self {
            case .seCarTrialFull, .seCarTrialHalf, .seGroupApartmentBrf, .seGroupApartmentRent:
                return true
            default:
                return false
            }
        }
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
        case .seCarTrialFull:
            return .car
        case .seCarTrialHalf:
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
        productVariant: ProductVariant,
        coInsured: [CoInsuredModel]
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
        productVariant: ProductVariant,
        coInsured: [CoInsuredModel]
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

extension InsuredPeopleConfig {
    public init(
        contract: Contract
    ) {
        let store: ContractStore = globalPresentableStoreContainer.get()
        self.init(
            contractCoInsured: contract.coInsured,
            contractId: contract.id,
            activeFrom: contract.upcomingChangedAgreement?.activeFrom,
            numberOfMissingCoInsured: contract.nbOfMissingCoInsured,
            displayName: contract.currentAgreement?.productVariant.displayName ?? "",
            preSelectedCoInsuredList: store.state.fetchAllCoInsuredNotInContract(contractId: contract.id),
            contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
            holderFirstName: contract.firstName,
            holderLastName: contract.lastName,
            holderSSN: contract.ssn
        )
    }
}
