import SwiftUI
import hCore
import hCoreUI

struct PaymentStatusView: View {
    let status: PaymentData.PaymentStatus
    let onAction: (PaymentData.PaymentStatus.PaymentStatusAction) -> Void
    var body: some View {
        switch status {
        case .upcoming:
            InfoCard(text: L10n.paymentsUpcomingPayment, type: .info)
        case .success:
            HStack(spacing: .padding8) {
                Spacer()
                hCoreUIAssets.checkmark.view
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(hSignalColor.Green.element)
                hText(L10n.paymentsPaymentSuccessful, style: .label)
                    .foregroundColor(hSignalColor.Green.text)
                Spacer()
            }
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(hSignalColor.Green.fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(hBorderColor.primary, lineWidth: 0.5)
            )
        case .pending:
            InfoCard(text: L10n.paymentsInProgress, type: .info)
        case let .failedForPrevious(from, to):
            InfoCard(
                text:
                    L10n.paymentsMissedPayment(from.displayDateShort, to.displayDateShort),
                type: .error
            )
        case let .addedtoFuture(date):
            InfoCard(
                text: L10n.paymentsPaymentFailed(date.displayDate),
                type: .error
            )
            .buttons(
                [
                    .init(
                        buttonTitle: L10n.paymentsViewPayment,
                        buttonAction: {
                            onAction(.viewAddedToPayment)
                        }
                    )
                ]
            )
        case .unknown:
            EmptyView()
        }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.sv_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return VStack {
        PaymentStatusView(status: .pending) { _ in }
        PaymentStatusView(status: .success) { _ in }
        PaymentStatusView(status: .addedtoFuture(date: "2023-10-11")) { _ in }
        PaymentStatusView(status: .failedForPrevious(from: "2023-10-11", to: "2023-11-11")) { _ in }

        let dateFrom: Date? = "2024-05-06".localDateToDate
        let dateTo: Date? = "2024-06-06".localDateToDate

        if let dateFrom, let dateTo {
            let serverDateFrom: ServerBasedDate = dateFrom.localDateString

            let serverDateTo: ServerBasedDate = dateTo.localDateString

            PaymentStatusView(status: .failedForPrevious(from: serverDateFrom, to: serverDateTo)) { _ in }
        }
        Spacer()
    }
}
