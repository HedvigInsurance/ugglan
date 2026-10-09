import SwiftUI
import hCore
import hCoreUI

public struct MissedPaymentCardView: View {
    let amountDue: MonetaryAmount
    let buttonType: hButtonConfigurationType
    let onReviewPayment: () -> Void

    public init(
        amountDue: MonetaryAmount,
        buttonType: hButtonConfigurationType = .primary,
        onReviewPayment: @escaping () -> Void
    ) {
        self.amountDue = amountDue
        self.buttonType = buttonType
        self.onReviewPayment = onReviewPayment
    }
    public var body: some View {
        PaymentAttentionCard(
            title: L10n.paymentsPaymentOverdueTitle,
            subtitle: L10n.paymentsPaymentOverdueAmountDue(amountDue.formattedAmount),
            message: L10n.paymentsPaymentOverdueBody,
            buttonTitle: L10n.paymentsPaymentOverdueButton,
            buttonType: buttonType,
            action: onReviewPayment
        )
    }
}

#Preview {
    MissedPaymentCardView(
        amountDue: .sek(200)
    ) {}
}
