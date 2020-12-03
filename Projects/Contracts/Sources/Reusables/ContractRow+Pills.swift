import Foundation
import hCore
import UIKit

extension Date {
    var localized: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Foundation.Locale(identifier: Localization.Locale.currentLocale.rawValue)
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

extension ContractRow {
    var isContractActivated: Bool {
        contract.status.asActiveStatus != nil || contract.status.asTerminatedTodayStatus != nil || contract.status.asTerminatedInFutureStatus != nil
    }

    var statusPills: [String] {
        if let status = contract.status.asActiveInFutureAndTerminatedInFutureStatus {
            let futureInceptionDate = status.futureInception?.localDateToDate ?? Date()
            let futureTerminationDate = status.futureTermination?.localDateToDate ?? Date()

            return [
                L10n.dashboardInsuranceStatusInactiveStartdate(futureInceptionDate.localized),
                L10n.dashboardInsuranceStatusActiveTerminationdate(futureTerminationDate.localized),
            ]
        } else if contract.status.asTerminatedTodayStatus != nil {
            return [
                L10n.dashboardInsuranceStatusTerminatedToday,
            ]
        } else if let status = contract.status.asActiveInFutureStatus {
            let futureInceptionDate = status.futureInception?.localDateToDate ?? Date()

            return [
                L10n.dashboardInsuranceStatusInactiveStartdate(futureInceptionDate.localized),
            ]
        } else if contract.status.asPendingStatus != nil {
            return [
                L10n.dashboardInsuranceStatusInactiveNoStartdate,
            ]
        } else if contract.status.asTerminatedStatus != nil {
            return [
                L10n.dashboardInsuranceStatusTerminated,
            ]
        }

        return []
    }

    private var coversHowManyPill: String {
        func getPill(numberCoinsured: Int) -> String {
            numberCoinsured > 0 ?
                L10n.InsuranceTab.coversYouPlusTag(numberCoinsured) :
                L10n.InsuranceTab.coversYouTag
        }

        switch type {
        case .swedishApartment:
            let numberCoinsured = contract.currentAgreement.asSwedishApartmentAgreement?.numberCoInsured ?? 0
            return getPill(numberCoinsured: numberCoinsured)
        case .swedishHouse:
            let numberCoinsured = contract.currentAgreement.asSwedishHouseAgreement?.numberCoInsured ?? 0
            return getPill(numberCoinsured: numberCoinsured)
        case .norwegianHome:
            let numberCoinsured = contract.currentAgreement.asNorwegianHomeContentAgreement?.numberCoInsured ?? 0
            return getPill(numberCoinsured: numberCoinsured)
        case .norwegianTravel:
            let numberCoinsured = contract.currentAgreement.asNorwegianHomeContentAgreement?.numberCoInsured ?? 0
            return getPill(numberCoinsured: numberCoinsured)
        case .danishHome:
            let numberCoinsured = contract.currentAgreement.asDanishHomeContentAgreement?.numberCoInsured ?? 0
            return getPill(numberCoinsured: numberCoinsured)
        case .danishTravel:
            let numberCoinsured = contract.currentAgreement.asDanishTravelAgreement?.numberCoInsured ?? 0
            return getPill(numberCoinsured: numberCoinsured)
        }
    }

    var detailPills: [String] {
        switch type {
        case .swedishApartment:
            return [
                contract.currentAgreement.asSwedishApartmentAgreement?.address.street,
                coversHowManyPill,
            ].compactMap { $0 }
        case .swedishHouse:
            return [
                contract.currentAgreement.asSwedishHouseAgreement?.address.street,
                coversHowManyPill,
            ].compactMap { $0 }
        case .norwegianHome:
            return [
                contract.currentAgreement.asNorwegianHomeContentAgreement?.address.street,
                coversHowManyPill,
            ].compactMap { $0 }
        case .norwegianTravel:
            return [
                coversHowManyPill,
            ]
        case .danishHome:
            return [
                contract.currentAgreement.asDanishHomeContentAgreement?.address.street,
                coversHowManyPill,
            ].compactMap { $0 }
        case .danishTravel:
            return [
                coversHowManyPill,
            ]
        }
    }
}
