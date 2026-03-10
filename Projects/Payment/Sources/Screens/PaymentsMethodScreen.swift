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
        .hFormAttachToBottom {
            if data.chargeMethod == .trustly {
                ConnectPaymentBottomView(alwaysShowButton: true)
            } else if data.chargeMethod == .kivra {
                hSection {
                    InfoCard(
                        text:
                            L10n.kivraPaymentInfo,
                        type: .info
                    )
                    .buttons(
                        [
                            .init(
                                buttonTitle: L10n.openChat,
                                buttonAction: {
                                    NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                                }
                            )
                        ]
                    )
                }
                .sectionContainerStyle(.transparent)
            }
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
            chargingDayInTheMonth: 26,
            chargeMethod: .trustly
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
            if withDate, let dueDate = data.chargingDayInTheMonth?.ordinalDate() {
                infoRow(
                    for: L10n.paymentsPaymentDue,
                    and: L10n.paymentsDueDescription(dueDate),
                    infoText: data.chargeMethod.infoText(for: dueDate)
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

    @ViewBuilder
    private func infoRow(for title: String, and value: String, infoText: String?) -> some View {
        if let infoText {
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
        } else {
            hRow {
                hText(title)
                Spacer()
            }
            .withCustomAccessory {
                HStack {
                    hText(value)
                }
                .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
    }
}
