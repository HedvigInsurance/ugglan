import Foundation
import SwiftUI
import hCore
import hCoreUI

extension PaymentData: TitleView {
    public func getTitleView() -> UIView {
        let titleView = hText(self.getTitle).foregroundColor(self.titleColor)
        let view: UIView = UIHostingController(rootView: titleView).view
        view.backgroundColor = .clear
        return view
    }
}

@MainActor
extension PaymentData {

    fileprivate var getTitle: String {
        switch status {
        case .upcoming, .failedForPrevious:
            return L10n.paymentsUpcomingPayment
        case .pending, .success, .addedtoFuture, .unknown:
            return payment.date.displayDate
        }
    }

    @hColorBuilder
    var titleColor: some hColor {
        switch status {
        case .addedtoFuture:
            hSignalColor.Red.element
        default:
            hTextColor.Opaque.primary
        }
    }
}
