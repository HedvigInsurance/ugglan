import SwiftUI
import hCore
import hCoreUI

struct MissedPaymentCardView: View {
    let amountDue: MonetaryAmount
    let onReviewPayment: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .padding16) {
            VStack(alignment: .leading, spacing: .padding8) {
                HStack(alignment: .center, spacing: .padding10) {
                    hCoreUIAssets.warningTriangleFilled.view
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hSignalColor.Red.element)
                        .padding(.padding8)
                        .background(hSignalColor.Red.fill)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: .padding2) {
                        hText(L10n.paymentsPaymentOverdueTitle, style: .label)
                            .foregroundColor(hTextColor.Opaque.primary)
                        hText(L10n.paymentsPaymentOverdueAmountDue(amountDue.formattedAmount), style: .label)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                    Spacer()
                }
                hText(L10n.paymentsPaymentOverdueBody, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            hButton(
                .small,
                .primary,
                content: .init(title: L10n.paymentsPaymentOverdueButton),
                {
                    onReviewPayment()
                }
            )
            .hButtonTakeFullWidth(true)
        }
        .padding(.padding16)
        .background(hFillColor.Opaque.negative)
        .cornerRadius(.cornerRadiusXL)
        .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
        .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadiusXL)
                .inset(by: 0.5)
                .stroke(hBorderColor.primary, lineWidth: 1)
        )
    }
}

#Preview {
    MissedPaymentCardView(
        amountDue: .sek(200)
    ) {}
}
