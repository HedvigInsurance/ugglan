import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodsScreen: View {
    @AppObservedObject private var store: PaymentStore
    @EnvironmentObject private var paymentsNavigationVM: PaymentsNavigationViewModel
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        if let statusData = store.paymentStatusData {
            let paymentMethods = statusData.payinMethods
            if paymentMethods.isEmpty {
                StateView(
                    type: .empty,
                    title: L10n.paymentMethodsTitle,
                    bodyText: L10n.paymentMethodsEmpty,
                    formPosition: .center
                )
                .hStateViewButtonConfig(
                    .init(
                        actionButtonAttachedToBottom: .init(
                            buttonTitle: L10n.paymentAddMethodButton,
                            buttonStyle: .secondary,
                            buttonAction: {
                                paymentsNavigationVM.showAddPaymentMethod = true
                            }
                        )
                    )
                )
            } else {
                hForm {
                    hSection {
                        hRadioOptionList(paymentMethods, spacing: .padding8) { method in
                            PaymentMethodRow(method) {
                                router.push(PaymentsRouterAction.paymentMethod(provider: method.provider))
                            }
                        }
                    }
                    .sectionContainerStyle(.transparent)
                    .padding(.top, .padding8)
                }
                .hFormAttachToBottom {
                    hSection {
                        VStack(spacing: .padding8) {
                            hButton(.large, .secondary, content: .init(title: L10n.paymentAddMethodButton)) {
                                paymentsNavigationVM.showAddPaymentMethod = true
                            }
                            if statusData.canChooseDefaultPayinMethod {
                                hButton(.large, .ghost, content: .init(title: L10n.paymentChoosePrimaryButton)) {
                                    paymentsNavigationVM.showChooseDefaultPaymentMethod = true
                                }
                            }
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
        }
    }
}

#Preview {
    let store: PaymentStore = globalAppStateContainer.get()
    store.paymentStatusData = .init(
        status: .active,
        chargingDay: 27,
        defaultPayinMethod: .init(
            status: .active,
            isDefault: true,
            method: .trustly(bankAccount: .init(account: "account", bank: "bank"))
        ),
        payinMethods: [
            .init(
                status: .active,
                isDefault: true,
                method: .trustly(bankAccount: .init(account: "account", bank: "bank"))
            ),
            .init(
                status: .active,
                isDefault: false,
                method: .swish(phoneNumber: "0701231231")
            ),
        ],
        defaultPayoutMethod: nil,
        payoutMethods: [],
        availableMethods: [],
        missingConnection: nil,
        layout: .other
    )
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return PaymentMethodsScreen()
        .environmentObject(PaymentsNavigationViewModel())
        .task {
            await delay(3)
            store.paymentStatusData = .init(
                status: .active,
                chargingDay: 27,
                defaultPayinMethod: .init(
                    status: .active,
                    isDefault: true,
                    method: .swish(phoneNumber: "0701231231")
                ),
                payinMethods: [
                    .init(
                        status: .active,
                        isDefault: false,
                        method: .trustly(bankAccount: .init(account: "account", bank: "bank"))
                    ),
                    .init(
                        status: .active,
                        isDefault: true,
                        method: .swish(phoneNumber: "0701231231")
                    ),
                ],
                defaultPayoutMethod: nil,
                payoutMethods: [],
                availableMethods: [],
                missingConnection: nil,
                layout: .other
            )
        }
}
