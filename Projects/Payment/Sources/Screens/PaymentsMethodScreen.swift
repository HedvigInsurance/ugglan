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
                            L10n.kivraNotificationBoxText,
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
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })

    return PaymentMethodScreen(
        data: .init(
            paymentMethod: "method",
            bankName: "bank name",
            account: "account",
            mandate: nil,
            dueDate: 26,
            chargeMethod: .trustly
        )
    )
}

struct PaymentMethodView: View {
    private let items: [PaymentInfoItem]

    private struct PaymentInfoItem: Identifiable {
        var id: String { title }
        let title: String
        let value: String
        let info: String?
    }

    init(data: PaymentChargeData, withDate: Bool) {
        self.items = {
            var rows: [PaymentInfoItem] = []
            if let paymentMethod = data.paymentMethod {
                rows.append(PaymentInfoItem(title: L10n.paymentsPaymentMethod, value: paymentMethod, info: nil))
            }
            if withDate, let dueDate = data.dueDate?.ordinalDate() {
                rows.append(
                    .init(
                        title: L10n.paymentsPaymentDue,
                        value: L10n.paymentsDueDescription(dueDate),
                        info: data.chargeMethod.infoText(for: dueDate)
                    )
                )
            }

            if let account = data.account {
                rows.append(PaymentInfoItem(title: L10n.paymentsAccount, value: account, info: nil))
            }
            if let bankName = data.bankName {
                rows.append(PaymentInfoItem(title: L10n.myPaymentBankRowLabel, value: bankName, info: nil))
            }
            if let mandate = data.mandate {
                rows.append(PaymentInfoItem(title: L10n.paymentsMandate, value: mandate, info: nil))
            }
            return rows
        }()
    }
    @State var infoText: String?
    var body: some View {
        hSection(items) { item in
            if let info = item.info {
                infoRow(title: item.title, value: item.value, infoText: info)
            } else {
                regularRow(title: item.title, value: item.value)
            }
        }
        .sectionContainerStyle(.transparent)
        .detent(item: $infoText) { text in
            InfoView(title: nil, description: text)
        }
    }

    private func regularRow(title: String, value: String) -> some View {
        hRow {
            hText(title)
            Spacer()
        }
        .withCustomAccessory {
            hText(value).foregroundColor(hTextColor.Translucent.secondary)
        }
    }

    private func infoRow(title: String, value: String, infoText: String) -> some View {
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
