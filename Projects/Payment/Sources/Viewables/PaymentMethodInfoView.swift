import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodInfoView: View {
    private let items: [PaymentInfoItem]

    private struct PaymentInfoItem: Identifiable {
        var id: String { title }
        let title: String
        let value: String
        let info: String?
    }

    init(data: ConnectedPaymentMethod, chargingDay: Int? = nil, withDate: Bool) {
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

            switch data.method {
            case .trustly(let bankAccount), .nordea(let bankAccount):
                if let bankAccount {
                    rows.append(PaymentInfoItem(title: L10n.paymentsAccount, value: bankAccount.account, info: nil))
                    rows.append(PaymentInfoItem(title: L10n.myPaymentBankRowLabel, value: bankAccount.bank, info: nil))
                }
            case .swish(let phoneNumber):
                if let phoneNumber {
                    rows.append(PaymentInfoItem(title: L10n.paymentsSwishNumber, value: phoneNumber, info: nil))
                }
            case .invoice(let delivery):
                switch delivery {
                case .kivra:
                    rows.append(PaymentInfoItem(title: L10n.paymentsAccount, value: "Kivra", info: nil))
                case .email(let email):
                    if let email {
                        rows.append(PaymentInfoItem(title: L10n.paymentsAccount, value: email, info: nil))
                    }
                case .unknown, nil:
                    break
                }
            case .unknown:
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
            InfoView(infoViewModel: .init(title: nil, description: text))
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
