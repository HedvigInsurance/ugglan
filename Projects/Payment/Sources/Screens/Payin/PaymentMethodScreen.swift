import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodScreen: View {
    @AppObservedObject private var store: PaymentStore
    @EnvironmentObject private var paymentsNavigationVM: PaymentsNavigationViewModel
    @State private var providerToSetUp: PaymentProvider?
    @State private var methodToRemove: ConnectedPaymentMethod?
    @State private var cantRemoveInfo: InfoViewModel?

    let paymentProvider: PaymentProvider

    var body: some View {
        if let statusData = store.paymentStatusData,
            let (method, isProcessing) = statusData.payinMethod(for: paymentProvider)
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
            .hFormAttachToBottom {
                hSection {
                    actions(for: method, isProcessing: isProcessing)
                }
                .sectionContainerStyle(.transparent)
            }
            .handlePaymentSetup(for: $providerToSetUp, phoneNumber: statusData.memberPhoneNumber)
            .detent(
                item: $methodToRemove,
                presentationStyle: .detent(style: [.height])
            ) { method in
                PaymentRemoveMethodScreen(method: method) {
                    methodToRemove = nil
                    // The method is gone, so this screen has nothing left to show.
                    paymentsNavigationVM.paymentsRouter.pop()
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
    private func actions(for method: ConnectedPaymentMethod, isProcessing: Bool) -> some View {
        switch paymentProvider {
        case .trustly:
            changeableMethod(method, isProcessing: isProcessing) {
                ConnectPaymentBottomView()
            }
        case .swish:
            changeableMethod(method, isProcessing: isProcessing) {
                hButton(.large, .secondary, content: .init(title: L10n.paymentSwishChangeNumber)) {
                    providerToSetUp = paymentProvider
                }
            }
        case .invoice:
            // Invoices are delivered by Kivra and cannot be changed here, only removed.
            changeableMethod(method, isProcessing: isProcessing) {}
        case .nordea, .unknown:
            EmptyView()
        }
    }

    private func changeableMethod<Change: View>(
        _ method: ConnectedPaymentMethod,
        isProcessing: Bool,
        @ViewBuilder change: () -> Change
    ) -> some View {
        VStack(spacing: .padding16) {
            if isProcessing {
                InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
            }
            VStack(spacing: .padding8) {
                change()
                removeButton(for: method)
            }
        }
    }

    private func removeButton(for method: ConnectedPaymentMethod) -> some View {
        hButton(.large, .ghost, content: .init(title: L10n.General.remove)) {
            // The default method keeps the payments running, so it can't be removed from here.
            if method.isDefault {
                cantRemoveInfo = .init(
                    //L10n.paymentRemovePrimaryTitle
                    title: "This is your primary payment method",
                    //L10n.paymentRemovePrimarySubtitle
                    description: "Choose another primary method before removing it."
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
    return PaymentMethodScreen(paymentProvider: .invoice)
        .environmentObject(store)
        .environmentObject(PaymentsNavigationViewModel())
}

#Preview("Trustly") {
    let store = PreviewData()
        .getStoreAndInitiateDependancies(for: .trustly(bankAccount: .init(account: "account", bank: "bank")))
    return PaymentMethodScreen(paymentProvider: .trustly)
        .environmentObject(store)
        .environmentObject(PaymentsNavigationViewModel())
}

#Preview("Swish") {
    let store = PreviewData().getStoreAndInitiateDependancies(for: .swish(phoneNumber: "0700123456"))
    return PaymentMethodScreen(paymentProvider: .swish)
        .environmentObject(store)
        .environmentObject(PaymentsNavigationViewModel())
}

#Preview("Nordea") {
    let store = PreviewData()
        .getStoreAndInitiateDependancies(for: .nordea(bankAccount: .init(account: "Nordea Account", bank: "Nordea")))
    return PaymentMethodScreen(paymentProvider: .nordea)
        .environmentObject(store)
        .environmentObject(PaymentsNavigationViewModel())
}

#Preview("Unknown") {
    let store = PreviewData().getStoreAndInitiateDependancies(for: .unknown)
    return PaymentMethodScreen(paymentProvider: .unknown)
        .environmentObject(store)
        .environmentObject(PaymentsNavigationViewModel())
}
