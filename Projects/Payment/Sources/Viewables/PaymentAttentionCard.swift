import SwiftUI
import hCore
import hCoreUI

/// The red-flagged card the payments tab and Home show when something needs the member's
/// attention: a warning icon, a two-line header, a body, and one full-width button. The
/// overdue-payment and missing-pay-in-method cards are the same card with different copy.
struct PaymentAttentionCard: View {
    let title: String
    let subtitle: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: .padding16) {
                VStack(alignment: .leading, spacing: .padding8) {
                    headerRow
                    hText(message, style: .label)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                hButton(.small, .primary, content: .init(title: buttonTitle)) { action() }
                    .hButtonTakeFullWidth(true)
            }
            .padding(.padding16)
        }
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: .padding10) {
            warningIcon
            VStack(alignment: .leading, spacing: .padding2) {
                hText(title, style: .label)
                    .foregroundColor(hTextColor.Opaque.primary)
                hText(subtitle, style: .label)
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
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    return PaymentAttentionCard(
        title: "Payment overdue",
        subtitle: "Requires action",
        message: "We could not charge your account.",
        buttonTitle: "Review payment",
        action: {}
    )
}
