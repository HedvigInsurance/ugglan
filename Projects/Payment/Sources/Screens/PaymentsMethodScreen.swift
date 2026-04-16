import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodScreen: View {
    @EnvironmentObject var paymentsNavigationVM: PaymentsNavigationViewModel

    var body: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentStatusData
            }
        ) { paymentChargeData in
            if let paymentChargeData, let defaultPayinMethod = paymentChargeData.defaultPayinMethod {
                hForm {
                    PaymentMethodView(
                        data: defaultPayinMethod,
                        chargingDay: paymentChargeData.chargingDay,
                        withDate: true
                    )
                    .hWithoutHorizontalPadding([.row, .divider])
                }
                .hFormAttachToBottom {
                    if defaultPayinMethod.provider == .trustly {
                        ConnectPaymentBottomView(alwaysShowButton: true)
                    } else if defaultPayinMethod.provider == .invoice {
                        hSection {
                            InfoCard(
                                text:
                                    L10n.kivraNotificationBoxText,
                                type: .info
                            )
                            .buttons(
                                [
                                    .init(
                                        buttonTitle: L10n.profilePaymentConnectDirectDebitButton,
                                        buttonAction: {
                                            paymentsNavigationVM.connectPaymentVm.set()
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
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })

    return PaymentMethodScreen()
        .environmentObject(PaymentsNavigationViewModel())
        .task {
            let store: PaymentStore = globalPresentableStoreContainer.get()
            store.send(
                .setPaymentStatus(
                    data: .init(
                        status: .active,
                        chargingDay: 27,
                        defaultPayinMethod: .init(
                            id: "id",
                            provider: .invoice,
                            status: .active,
                            isDefault: true,
                            details: .invoice(delivery: .kivra, email: nil)
                        ),
                        payinMethods: [
                            .init(
                                id: "id",
                                provider: .invoice,
                                status: .active,
                                isDefault: true,
                                details: .invoice(delivery: .kivra, email: nil)
                            )
                        ],
                        defaultPayoutMethod: nil,
                        payoutMethods: [],
                        availableMethods: []
                    )
                )
            )
            await delay(2)
            store.send(
                .setPaymentStatus(
                    data: .init(
                        status: .active,
                        chargingDay: 27,
                        defaultPayinMethod: .init(
                            id: "id",
                            provider: .trustly,
                            status: .active,
                            isDefault: true,
                            details: .bankAccount(account: "*****123", bank: "Nordea")
                        ),
                        payinMethods: [
                            .init(
                                id: "id",
                                provider: .trustly,
                                status: .active,
                                isDefault: true,
                                details: .bankAccount(account: "*****123", bank: "Nordea")
                            )
                        ],
                        defaultPayoutMethod: nil,
                        payoutMethods: [],
                        availableMethods: []
                    )
                )
            )
        }
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
