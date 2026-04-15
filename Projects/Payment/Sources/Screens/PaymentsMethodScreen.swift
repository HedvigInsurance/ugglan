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
                state.paymentStatusData?.paymentChargeData
            }
        ) { paymentChargeData in
            if let paymentChargeData {
                hForm {
                    PaymentMethodView(data: paymentChargeData, withDate: true)
                        .hWithoutHorizontalPadding([.row, .divider])
                }
                .hFormAttachToBottom {
                    if paymentChargeData.chargeMethod == .trustly {
                        ConnectPaymentBottomView(alwaysShowButton: true)
                    } else if paymentChargeData.chargeMethod == .kivra {
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
                        paymentChargeData: .init(
                            paymentMethod: nil,
                            bankName: nil,
                            account: nil,
                            mandate: nil,
                            dueDate: 27,
                            chargeMethod: .kivra
                        )
                    )
                )
            )
            await delay(2)
            store.send(
                .setPaymentStatus(
                    data: .init(
                        status: .active,
                        paymentChargeData: .init(
                            paymentMethod: "method",
                            bankName: "Nordea",
                            account: "*****123",
                            mandate: nil,
                            dueDate: 27,
                            chargeMethod: .trustly
                        )
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
