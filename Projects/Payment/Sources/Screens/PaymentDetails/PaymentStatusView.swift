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
            HStack(spacing: 8) {
                Spacer()
                Image(uiImage: hCoreUIAssets.checkmark.image)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(hSignalColor.Green.element)
                hText(L10n.paymentsPaymentSuccessful, style: .standardSmall)
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
            HStack(spacing: 8) {
                Spacer()
                Image(uiImage: hCoreUIAssets.infoFilled.image)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(hSignalColor.Blue.element)

                hText(L10n.paymentsPaymentInProgress, style: .standardSmall)
                    .foregroundColor(hSignalColor.Blue.text)
                Spacer()
            }
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(hSignalColor.Blue.fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(hBorderColor.primary, lineWidth: 0.5)
            )
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

struct PaymentStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .sv_SE
        return VStack {
            PaymentStatusView(status: .pending) { _ in }
            PaymentStatusView(status: .success) { _ in }
            PaymentStatusView(status: .addedtoFuture(date: "2023-10-11")) { _ in }
            PaymentStatusView(status: .failedForPrevious(from: "2023-10-11", to: "2023-11-11")) { _ in }
            Spacer()
        }
    }
}
