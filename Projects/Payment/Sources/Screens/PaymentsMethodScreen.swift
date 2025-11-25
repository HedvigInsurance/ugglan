import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodScreen: View {
    let data: PaymentChargeData
    var body: some View {
        hForm {
            PaymentMethodView(data: data, withDate: true)
                .hWithoutHorizontalPadding([.row, .divider])
        }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    return PaymentMethodScreen(
        data: .init(
            paymentMethod: "method",
            bankName: "bank name",
            account: "account",
            mandate: "mandate",
            chargingDayInTheMonth: 26
        )
    )
}

struct PaymentMethodView: View {
    let data: PaymentChargeData
    let withDate: Bool

    @State var infoText: String?
    var body: some View {
        hSection {
            regularRow(for: L10n.paymentsPaymentMethod, and: data.paymentMethod)
            if withDate, let dueDate = data.chargingDayInTheMonth?.asString.appending(".") {
                infoRow(
                    for: L10n.paymentsPaymentDue,
                    and: L10n.paymentsDueDescription(dueDate),
                    infoText: L10n.paymentsPaymentDueInfo(dueDate)
                )
            }
            regularRow(for: L10n.paymentsAccount, and: data.account)
            regularRow(for: L10n.myPaymentBankRowLabel, and: data.bankName)
            regularRow(for: L10n.paymentsMandate, and: data.mandate)
        }
        .sectionContainerStyle(.transparent)
        .detent(item: $infoText) { text in
            InfoView(title: nil, description: text)
        }
    }

    @ViewBuilder
    private func regularRow(for title: String, and value: String?) -> some View {
        if let value {
            hRow {
                hText(title)
                Spacer()
            }
            .withCustomAccessory {
                hText(value).foregroundColor(hTextColor.Translucent.secondary)
            }
        }
    }

    private func infoRow(for title: String, and value: String, infoText: String) -> some View {
        hRow {
            hText(title)
            Spacer()
        }
        .withCustomAccessory {
            HStack {
                hText(value)
                hCoreUIAssets.infoFilled.view
            }
            .foregroundColor(hTextColor.Translucent.secondary)
        }
        .onTap {
            self.infoText = infoText
        }
    }
}
