import Foundation
import UIKit
import hCore

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
        contract.currentAgreement.status == .active
    }

    var statusPills: [String] {
        return []
    }

    private var coversHowManyPill: String {
        return ""
    }

    var detailPills: [String] {
        return []
    }
}
