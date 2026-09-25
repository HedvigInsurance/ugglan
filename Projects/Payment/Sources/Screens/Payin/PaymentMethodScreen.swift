import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct PaymentMethodScreen: View {
    @AppObservedObject private var store: PaymentStore
    @EnvironmentObject private var paymentsNavigationVM: PaymentsNavigationViewModel
    @State private var providerToSetUp: PaymentProvider?

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
                    actions(isProcessing: isProcessing, status: statusData.status)
                }
                .sectionContainerStyle(.transparent)
            }
            .handlePaymentSetup(for: $providerToSetUp, phoneNumber: statusData.memberPhoneNumber)
        }
    }

    @ViewBuilder
    private func actions(isProcessing: Bool, status: PayinMethodStatus) -> some View {
        switch paymentProvider {
        case .trustly:
            changeableMethod(isProcessing: isProcessing) {
                ConnectPaymentBottomView()
            }
        case .swish:
            changeableMethod(isProcessing: isProcessing) {
                hButton(.large, .secondary, content: .init(title: L10n.paymentSwishChangeNumber)) {
                    providerToSetUp = paymentProvider
                }
            }
        case .invoice:
            kivraCard(isProcessing: isProcessing, status: status)
        case .nordea, .unknown:
            EmptyView()
        }
    }

    private func changeableMethod<Change: View>(
        isProcessing: Bool,
        @ViewBuilder change: () -> Change
    ) -> some View {
        VStack(spacing: .padding16) {
            if isProcessing {
                InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
            }
            VStack(spacing: .padding8) {
                change()
                removeButton
            }
        }
    }

    /// Invoices are delivered by Kivra and cannot be changed here, so the card offers direct
    /// debit as the way out.
    private func kivraCard(isProcessing: Bool, status: PayinMethodStatus) -> some View {
        InfoCard(
            text: isProcessing ? L10n.myPaymentUpdatingMessage : L10n.kivraNotificationBoxText,
            type: .info
        )
        .buttons([
            .init(
                buttonTitle: isProcessing ? status.connectButtonTitle : L10n.profilePaymentConnectDirectDebitButton,
                buttonAction: {
                    paymentsNavigationVM.connectPaymentVm.set()
                }
            )
        ])
    }

    // TODO: removing a method is not wired up yet — the API does not expose it.
    private var removeButton: some View {
        hButton(.large, .ghost, content: .init(title: L10n.General.remove)) {}
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
