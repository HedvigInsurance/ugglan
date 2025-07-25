import Addons
import EditCoInsuredShared
import Foundation
import PresentableStore
import TerminateContracts
import hCore
import hCoreUI

public struct Contract: Codable, Hashable, Equatable, Identifiable, Sendable {
    public init(
        id: String,
        currentAgreement: Agreement?,
        exposureDisplayName: String,
        masterInceptionDate: String?,
        terminationDate: String?,
        supportsAddressChange: Bool,
        supportsCoInsured: Bool,
        supportsTravelCertificate: Bool,
        supportsChangeTier: Bool,
        upcomingChangedAgreement: Agreement?,
        upcomingRenewal: ContractRenewal?,
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
        self.supportsCoInsured = supportsCoInsured
        self.supportsAddressChange = supportsAddressChange
        self.supportsTravelCertificate = supportsTravelCertificate
        self.supportsChangeTier = supportsChangeTier
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
    public let supportsAddressChange: Bool
    public let supportsChangeTier: Bool
    public let supportsCoInsured: Bool
    public let supportsTravelCertificate: Bool
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

    public var nbOfMissingCoInsuredWithoutTermination: Int {
        return self.coInsured.filter({ $0.hasMissingInfo && $0.terminatesOn == nil }).count
    }

    public var showEditCoInsuredInfo: Bool {
        return supportsCoInsured && self.terminationDate == nil
    }

    @MainActor
    public var showEditInfo: Bool {
        return EditType.getTypes(for: self).count > 0 && self.terminationDate == nil
    }

    @MainActor
    func onlyCoInsured() -> Bool {
        let editTypes: [EditType] = EditType.getTypes(for: self)
        return editTypes.count == 1 && editTypes.first == .coInsured
    }

    public var canTerminate: Bool {
        return terminationDate == nil
    }

    public var isTerminated: Bool {
        return terminationDate != nil
    }

    @MainActor
    public var terminatedToday: Bool {
        if terminationDate == Date().localDateString {
            return true
        }
        return false
    }

    @MainActor
    public var terminatedInPast: Bool {
        if let terminationDate = self.terminationDate?.localDateToDate,
            let localDate = Date().localDateString.localDateToDate
        {
            let daysBetween = terminationDate.daysBetween(start: localDate) < 0
            if daysBetween {
                return true
            }
        }
        return false
    }

    @MainActor
    public var terminationMessage: String? {
        let terminationDateDisplayValue = terminationDate?.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
        if terminationDate != nil {
            if typeOfContract.showValidUntilInsteadOfTerminatedAt {
                if terminatedToday {
                    return L10n.contractsTrialTerminationDateMessageTomorrow
                } else {
                    return L10n.contractsTrialTerminationDateMessage(terminationDateDisplayValue)
                }
            } else {
                if terminatedInPast {
                    return L10n.contractTerminatedOn(terminationDateDisplayValue)
                } else if terminatedToday {
                    return L10n.contractStatusTerminatedToday
                } else {
                    return L10n.contractStatusToBeTerminated(terminationDateDisplayValue)
                }
            }
        }
        return nil
    }

    @MainActor
    public var activeInFuture: Bool {
        if let inceptionDate = masterInceptionDate?.localDateToDate,
            let localDate = Date().localDateString.localDateToDate,
            inceptionDate.daysBetween(start: localDate) > 0
        {
            return true
        }
        return false
    }

    @MainActor
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

    public var isNonPayingMember: Bool {
        if typeOfContract == .seQasaShortTermRental || typeOfContract == .seQasaLongTermRental {
            return true
        }
        return false
    }
}

extension TypeOfContract {
    public var showValidUntilInsteadOfTerminatedAt: Bool {
        switch self {
        case .seCarTrialFull, .seCarTrialHalf, .seGroupApartmentBrf, .seGroupApartmentRent:
            return true
        default:
            return false
        }
    }
}

extension TypeOfContract {
    var isHomeInsurance: Bool {
        switch self {
        case .seHouse, .seHouseBas, .seHouseMax:
            return true
        case .seApartmentBrf, .seApartmentBrfBas, .seApartmentBrfMax:
            return true
        case .seApartmentRent, .seApartmentRentBas, .seApartmentRentMax:
            return true
        case .seApartmentStudentBrf:
            return true
        case .seApartmentStudentRent:
            return true
        case .seAccident:
            return false
        case .seAccidentStudent:
            return false
        case .seCarTraffic:
            return false
        case .seCarHalf:
            return false
        case .seCarFull:
            return false
        case .seCarTrialFull:
            return false
        case .seCarTrialHalf:
            return false
        case .seGroupApartmentBrf:
            return true
        case .seGroupApartmentRent:
            return true
        case .seQasaShortTermRental:
            return true
        case .seQasaLongTermRental:
            return true
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
        case .unknown:
            return false
        }
    }
}

public struct ContractRenewal: Codable, Hashable, Sendable {
    public let renewalDate: String
    public let certificateUrl: String?

    public init(
        renewalDate: String,
        certificateUrl: String?
    ) {
        self.renewalDate = renewalDate
        self.certificateUrl = certificateUrl
    }
}

public struct Agreement: Codable, Hashable, Sendable {
    public init(
        certificateUrl: String?,
        activeFrom: String?,
        activeTo: String?,
        premium: MonetaryAmount,
        displayItems: [AgreementDisplayItem],
        productVariant: hCore.ProductVariant,
        addonVariant: [AddonVariant]
    ) {
        self.certificateUrl = certificateUrl
        self.activeFrom = activeFrom
        self.activeTo = activeTo
        self.premium = premium
        self.displayItems = displayItems
        self.productVariant = productVariant
        self.addonVariant = addonVariant
    }

    public let certificateUrl: String?
    public let activeFrom: String?
    public let activeTo: String?
    public let premium: MonetaryAmount
    public let displayItems: [AgreementDisplayItem]
    public let productVariant: hCore.ProductVariant
    public let addonVariant: [AddonVariant]

    public init(
        premium: MonetaryAmount,
        displayItems: [AgreementDisplayItem],
        productVariant: hCore.ProductVariant,
        addonVariant: [AddonVariant]
    ) {
        self.premium = premium
        self.displayItems = displayItems
        self.productVariant = productVariant
        self.addonVariant = addonVariant
        self.certificateUrl = nil
        self.activeFrom = nil
        self.activeTo = nil
    }
}

public struct AgreementDisplayItem: Codable, Hashable, Sendable {
    let displayTitle: String
    let displayValue: String

    public init(
        title displayTitle: String,
        value displayValue: String
    ) {
        self.displayTitle = displayTitle
        self.displayValue = displayValue
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

@MainActor
extension InsuredPeopleConfig {
    public init(
        contract: Contract,
        fromInfoCard: Bool
    ) {
        let store: ContractStore = globalPresentableStoreContainer.get()
        self.init(
            id: contract.id,
            contractCoInsured: contract.coInsured,
            contractId: contract.id,
            activeFrom: contract.upcomingChangedAgreement?.activeFrom,
            numberOfMissingCoInsured: contract.nbOfMissingCoInsured,
            numberOfMissingCoInsuredWithoutTermination: contract.nbOfMissingCoInsuredWithoutTermination,
            displayName: contract.currentAgreement?.productVariant.displayName ?? "",
            exposureDisplayName: contract.exposureDisplayName,
            preSelectedCoInsuredList: store.state.fetchAllCoInsuredNotInContract(contractId: contract.id),
            contractDisplayName: contract.currentAgreement?.productVariant.displayName ?? "",
            holderFirstName: contract.firstName,
            holderLastName: contract.lastName,
            holderSSN: contract.ssn,
            fromInfoCard: fromInfoCard
        )
    }
}

extension Contract {
    public var asTerminationConfirmConfig: TerminationConfirmConfig {
        return .init(
            contractId: id,
            contractDisplayName: currentAgreement?.productVariant.displayName ?? "",
            contractExposureName: exposureDisplayName,
            activeFrom: currentAgreement?.activeFrom,
            typeOfContract: TypeOfContract.resolve(for: currentAgreement?.productVariant.typeOfContract ?? "")
        )
    }
}

extension Sequence where Iterator.Element == Contract {
    public var hasMissingCoInsured: Bool {
        let contractsWithMissingCoInsured =
            self
            .filter { contract in
                if !contract.supportsCoInsured {
                    return false
                } else if contract.coInsured.isEmpty {
                    return false
                } else if contract.terminationDate != nil {
                    return false
                } else {
                    return contract.coInsured.first(where: { $0.hasMissingData }) != nil
                }
            }
        let show = !contractsWithMissingCoInsured.isEmpty
        return show
    }
}

extension Contract: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: ContractDetail.self)
    }

}
