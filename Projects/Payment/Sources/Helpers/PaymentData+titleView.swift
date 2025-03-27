import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
extension PaymentData {
    var getTitle: String {
        switch status {
        case .upcoming, .failedForPrevious:
            return L10n.paymentsUpcomingPayment
        case .pending:
            return L10n.paymentsProcessingPayment
        case .success, .addedtoFuture, .unknown:
            return payment.date.displayDate
        }
    }

    var titleColor: TitleColor {
        switch status {
        case .addedtoFuture:
            return .red
        default:
            return .default
        }
    }
}
