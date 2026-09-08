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
                hSection {
                    PaymentMethodRow(defaultPayinMethod, accessory: .none)
                }
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

@MainActor
fileprivate struct PreviewData {
    func getStoreAndInitiateDependancies(for method: PaymentMethod) -> PaymentStore {
        let store: PaymentStore = globalAppStateContainer.get()
        store.paymentStatusData = .init(
            status: .active,
            chargingDay: 27,
            defaultPayinMethod: .init(
                status: .active,
                isDefault: true,
                method: method
            ),
            payinMethods: [
                .init(
                    status: .active,
                    isDefault: true,
                    method: method
                )
            ],
            defaultPayoutMethod: nil,
            payoutMethods: [],
            availableMethods: [],
            missingConnection: nil,
            layout: .other
        )
        Localization.Locale.currentLocale.send(.en_SE)
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        return store
    }
}

#Preview("Invoice") {
    let store = PreviewData().getStoreAndInitiateDependancies(for: .invoice(delivery: .kivra))
    return PaymentMethodScreen()
        .environmentObject(store)
}

#Preview("Trustly") {
    let store = PreviewData()
        .getStoreAndInitiateDependancies(for: .trustly(bankAccount: .init(account: "account", bank: "bank")))
    return PaymentMethodScreen()
        .environmentObject(store)
        .environmentObject(PaymentsNavigationViewModel())
}

#Preview("Swish") {
    let store = PreviewData().getStoreAndInitiateDependancies(for: .swish(phoneNumber: "0700123456"))
    return PaymentMethodScreen().environmentObject(store)
}

#Preview("Nordea") {
    let store = PreviewData()
        .getStoreAndInitiateDependancies(for: .nordea(bankAccount: .init(account: "Nordea Account", bank: "Nordea")))
    return PaymentMethodScreen().environmentObject(store)
}

#Preview("Unknown") {
    let store = PreviewData().getStoreAndInitiateDependancies(for: .unknown)
    return PaymentMethodScreen().environmentObject(store)
}
