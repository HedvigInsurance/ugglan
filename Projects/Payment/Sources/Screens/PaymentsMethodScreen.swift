import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodScreen: View {
    let data: PaymentMethodData
    var chargingDay: Int?

    var body: some View {
        hForm {
            PaymentMethodView(data: data, chargingDay: chargingDay, withDate: true)
                .hWithoutHorizontalPadding([.row, .divider])
        }
        .hFormAttachToBottom {
            if data.provider == .trustly {
                ConnectPaymentBottomView(alwaysShowButton: true)
            } else if data.provider == .invoice {
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
            id: "payin-1",
            provider: .trustly,
            status: .active,
            isDefault: true,
            details: .bankAccount(account: "****1234", bank: "Nordea")
        ),
        chargingDay: 26
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

    init(data: PaymentMethodData, chargingDay: Int? = nil, withDate: Bool) {
        self.items = {
            var rows: [PaymentInfoItem] = []
            if let paymentMethodLabel = data.provider.paymentMethodLabel {
                rows.append(PaymentInfoItem(title: L10n.paymentsPaymentMethod, value: paymentMethodLabel, info: nil))
            }
            if withDate, let dueDate = chargingDay?.ordinalDate() {
                rows.append(
                    .init(
                        title: L10n.paymentsPaymentDue,
                        value: L10n.paymentsDueDescription(dueDate),
                        info: data.provider.infoText(for: dueDate)
                    )
                )
            }

            switch data.details {
            case .bankAccount(let account, let bank):
                rows.append(PaymentInfoItem(title: L10n.paymentsAccount, value: account, info: nil))
                rows.append(PaymentInfoItem(title: L10n.myPaymentBankRowLabel, value: bank, info: nil))
            case .swish(let phoneNumber):
                rows.append(PaymentInfoItem(title: L10n.paymentsAccount, value: phoneNumber, info: nil))
            case .invoice(_, let email):
                if let email {
                    rows.append(PaymentInfoItem(title: L10n.paymentsAccount, value: email, info: nil))
                }
            case nil:
                break
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
