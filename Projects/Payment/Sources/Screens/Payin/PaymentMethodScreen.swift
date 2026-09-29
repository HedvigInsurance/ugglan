import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodScreen: View {
    @AppObservedObject var store: PaymentStore
    @EnvironmentObject var paymentsNavigationVM: PaymentsNavigationViewModel

    var body: some View {
        if let paymentChargeData = store.paymentStatusData,
            let defaultPayinMethod = paymentChargeData.defaultOrFirstDefaultPayinMethod,
            store.showsChangePayinMethod
        {
            hForm {
                PaymentMethodInfoView(
                    data: defaultPayinMethod,
                    chargingDay: paymentChargeData.chargingDay,
                    withDate: true
                )
                .hWithoutHorizontalPadding([.row, .divider])
            }
            .hFormAttachToBottom {
                if defaultPayinMethod.provider == .trustly {
                    ConnectPaymentBottomView()
                } else if defaultPayinMethod.provider == .invoice {
                    hSection {
                        InfoCard(
                            text:
                                paymentChargeData.payinMethods.hasMethodInProgress
                                ? L10n.myPaymentUpdatingMessage : L10n.kivraNotificationBoxText,
                            type: .info
                        )
                        .buttons(
                            [
                                .init(
                                    buttonTitle: paymentChargeData.payinMethods.hasMethodInProgress
                                        ? paymentChargeData.status.connectButtonTitle
                                        : L10n.profilePaymentConnectDirectDebitButton,
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

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })

    return PaymentMethodScreen()
        .environmentObject(PaymentsNavigationViewModel())
        .task {
            let store: PaymentStore = globalAppStateContainer.get()
            store.paymentStatusData = .init(
                status: .active,
                chargingDay: 27,
                defaultPayinMethod: .init(
                    status: .active,
                    isDefault: true,
                    method: .invoice(delivery: .kivra)
                ),
                payinMethods: [
                    .init(
                        status: .active,
                        isDefault: true,
                        method: .invoice(delivery: .kivra)
                    )
                ],
                defaultPayoutMethod: nil,
                payoutMethods: [],
                availableMethods: [],
                missingConnection: nil,
                layout: .other
            )
            await delay(2)
            store.paymentStatusData = .init(
                status: .active,
                chargingDay: 27,
                defaultPayinMethod: .init(
                    status: .active,
                    isDefault: true,
                    method: .trustly(bankAccount: .init(account: "*****123", bank: "Nordea"))
                ),
                payinMethods: [
                    .init(
                        status: .active,
                        isDefault: true,
                        method: .trustly(bankAccount: .init(account: "*****123", bank: "Nordea"))
                    )
                ],
                defaultPayoutMethod: nil,
                payoutMethods: [],
                availableMethods: [],
                missingConnection: nil,
                layout: .other
            )
        }
}
