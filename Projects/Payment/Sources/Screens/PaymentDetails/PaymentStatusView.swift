import SwiftUI
import hCore
import hCoreUI

struct PaymentStatusView: View {
    let status: PaymentData.PaymentStatus
    let onAction: (PaymentData.PaymentStatus.PaymentStatusAction) -> Void
    var body: some View {
        switch status {
        case .success:
            HStack(spacing: 8) {
                Spacer()
                Image(uiImage: hCoreUIAssets.tick.image)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(hSignalColor.greenElement)
                hText("Payment successful", style: .standardSmall)
                    .foregroundColor(hSignalColor.greenText)
                Spacer()
            }
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(hSignalColor.greenFill)
                    .border(hBorderColor.translucentOne, width: 0.5)
            )
        case .pending:
            HStack(spacing: 8) {
                Spacer()
                Image(uiImage: hCoreUIAssets.infoIconFilled.image)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(hSignalColor.blueFill)

                hText("Payment in progress", style: .standardSmall)
                    .foregroundColor(hSignalColor.blueText)
                Spacer()
            }
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(hSignalColor.blueFill)
                    .border(hBorderColor.translucentOne, width: 0.5)
            )
        case let .failedForPrevious(from, to):
            InfoCard(
                text:
                    "Your payment from period \(from.displayDateShort) – \(to.displayDateShort) didn’t go through as expected. The amount has been added to this payment.",
                type: .error
            )
        case let .addedtoFuture(date, id):
            InfoCard(
                text: "This payment failed and was added to your payment on \(date.displayDate).",
                type: .error
            )
            .buttons(
                [
                    .init(
                        buttonTitle: "View payment",
                        buttonAction: {
                            onAction(.viewPayment(withId: id))
                        }
                    )
                ]
            )
        }
    }
}

struct PaymentStatusView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentStatusView(status: .pending) { _ in

        }
    }
}
