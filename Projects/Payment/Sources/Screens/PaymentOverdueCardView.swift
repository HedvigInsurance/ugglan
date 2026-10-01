import SwiftUI
import hCore
import hCoreUI

struct MissedPaymentCardView: View {
    let amountDue: MonetaryAmount
    let onReviewPayment: () -> Void

    var body: some View {
        PaymentAttentionCard(
            title: L10n.paymentsPaymentOverdueTitle,
            subtitle: L10n.paymentsPaymentOverdueAmountDue(amountDue.formattedAmount),
            message: L10n.paymentsPaymentOverdueBody,
            buttonTitle: L10n.paymentsPaymentOverdueButton,
            action: onReviewPayment
        )
    }
}

#Preview {
    MissedPaymentCardView(
        amountDue: .sek(200)
    ) {}
}
