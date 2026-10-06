import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodDetailScreen: View {
    @AppObservedObject private var store: PaymentStore
    @EnvironmentObject private var router: NavigationRouter
    @State private var providerToSetUp: PaymentProvider?
    @State private var methodToRemove: ConnectedPaymentMethod?
    @State private var cantRemoveInfo: InfoViewModel?

    let paymentProvider: PaymentProvider

    var body: some View {
        if let statusData = store.paymentStatusData,
            let method = statusData.connectedPaymentMethod(for: paymentProvider)
        {
            hForm {
                hSection {
                    PaymentMethodRow(method, accessory: .none)
                }
                PaymentMethodInfoView(
                    data: method,
                    chargingDay: statusData.chargingDay,
                    withDate: true
                )
                .hWithoutHorizontalPadding([.row, .divider])
            }
            .hFormAlwaysAttachToBottom {
                hSection {
                    actions(for: method)
                }
                .sectionContainerStyle(.transparent)
            }
            .handlePayinSetup(
                for: $providerToSetUp,
                completion: .showConfirmation
            )
            .hSetScrollBounce(to: true)
            .onPullToRefresh {
                await store.fetchPaymentStatus()
            }
            .detent(
                item: $methodToRemove,
                presentationStyle: .detent(style: [.height])
            ) { method in
                RemovePaymentMethodScreen(method: method) {
                    methodToRemove = nil
                    // The method is gone, so this screen has nothing left to show.
                    router.pop()
                    PaymentStore.refreshStatusDetached()
                }
            }
            .detent(
                item: $cantRemoveInfo,
                presentationStyle: .detent(style: [.height]),
                options: .constant(.withoutGrabber)
            ) { infoViewModel in
                InfoView(infoViewModel: infoViewModel)
            }
        }
    }

    @ViewBuilder
    private func actions(for method: ConnectedPaymentMethod) -> some View {
        switch paymentProvider {
        case .trustly:
            changeableMethod(method) {
                hButton(.large, .secondary, content: .init(title: L10n.myPaymentDirectDebitReplaceButton)) {
                    providerToSetUp = paymentProvider
                }
            }
        case .swish:
            changeableMethod(method) {
            }
        case .invoice:
            // Invoices are delivered by Kivra and cannot be changed here, only removed.
            changeableMethod(method) {}
        case .nordea, .unknown:
            EmptyView()
        }
    }

    private func changeableMethod<Change: View>(
        _ method: ConnectedPaymentMethod,
        @ViewBuilder change: () -> Change
    ) -> some View {
        VStack(spacing: .padding8) {
            change()
            removeButton(for: method)
        }
    }

    private func removeButton(for method: ConnectedPaymentMethod) -> some View {
        hButton(.large, .ghost, content: .init(title: L10n.General.remove)) {
            // The default method keeps the payments running, so it can't be removed from here.
            if method.isDefault {
                cantRemoveInfo = .init(
                    title: L10n.paymentRemovePrimaryTitle,
                    description: L10n.paymentRemovePrimarySubtitle
                )
            } else {
                methodToRemove = method
            }
        }
        .hUseButtonTextColor(.red)
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
    return PaymentMethodDetailScreen(paymentProvider: .invoice)
        .environmentObject(store)
        .environmentObject(PaymentsNavigationViewModel())
        .environmentObject(NavigationRouter())
}

#Preview("Trustly") {
    let store = PreviewData()
        .getStoreAndInitiateDependancies(for: .trustly(bankAccount: .init(account: "account", bank: "bank")))
    return PaymentMethodDetailScreen(paymentProvider: .trustly)
        .environmentObject(store)
        .environmentObject(PaymentsNavigationViewModel())
        .environmentObject(NavigationRouter())
}

#Preview("Swish") {
    let store = PreviewData().getStoreAndInitiateDependancies(for: .swish(phoneNumber: "0700123456"))
    return PaymentMethodDetailScreen(paymentProvider: .swish)
        .environmentObject(store)
        .environmentObject(PaymentsNavigationViewModel())
        .environmentObject(NavigationRouter())
}

#Preview("Nordea") {
    let store = PreviewData()
        .getStoreAndInitiateDependancies(for: .nordea(bankAccount: .init(account: "Nordea Account", bank: "Nordea")))
    return PaymentMethodDetailScreen(paymentProvider: .nordea)
        .environmentObject(store)
        .environmentObject(PaymentsNavigationViewModel())
        .environmentObject(NavigationRouter())
}

#Preview("Unknown") {
    let store = PreviewData().getStoreAndInitiateDependancies(for: .unknown)
    return PaymentMethodDetailScreen(paymentProvider: .unknown)
        .environmentObject(store)
        .environmentObject(PaymentsNavigationViewModel())
        .environmentObject(NavigationRouter())
}
