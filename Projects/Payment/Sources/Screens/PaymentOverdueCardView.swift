import SwiftUI
import hCore
import hCoreUI

struct MissedPaymentCardView: View {
    let amountDue: MonetaryAmount
    let onReviewPayment: () -> Void

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: .padding16) {
                VStack(alignment: .leading, spacing: .padding8) {
                    headerRow
                    hText(L10n.paymentsPaymentOverdueBody, style: .label)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                reviewButton
            }
            .padding(.padding16)
        }
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: .padding10) {
            warningIcon
            VStack(alignment: .leading, spacing: .padding2) {
                hText(L10n.paymentsPaymentOverdueTitle, style: .label)
                    .foregroundColor(hTextColor.Opaque.primary)
                hText(L10n.paymentsPaymentOverdueAmountDue(amountDue.formattedAmount), style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }

    private var warningIcon: some View {
        hCoreUIAssets.warningTriangleFilled.view
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(hSignalColor.Red.element)
            .padding(.padding8)
            .background(hSignalColor.Red.fill)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }

    private var reviewButton: some View {
        hButton(
            .small,
            .primary,
            content: .init(title: L10n.paymentsPaymentOverdueButton)
        ) { onReviewPayment() }
        .hButtonTakeFullWidth(true)
    }
}

#Preview {
    MissedPaymentCardView(
        amountDue: .sek(200)
    ) {}
}
