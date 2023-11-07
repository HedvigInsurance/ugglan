import Foundation
import SwiftUI
import hCore
import hCoreUI

extension PaymentData: TitleView {
    public func getTitleView() -> UIView {
        let titleView = hText(self.getTitle).foregroundColor(self.titleColor)
        return UIHostingController(rootView: titleView).view
    }
}

extension PaymentData {

    fileprivate var getTitle: String {
        switch status {
        case .upcoming:
            return L10n.paymentsUpcomingPayment
        case .pending, .success, .addedtoFuture, .failedForPrevious:
            return payment.date.displayDate
        }
    }

    @hColorBuilder
    var titleColor: some hColor {
        switch status {
        case .addedtoFuture:
            hSignalColor.redElement
        default:
            hTextColor.primary
        }
    }
}
