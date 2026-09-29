import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

extension View {
    public func handlePaymentMethods(presented: Binding<Bool>) -> some View {
        detent(
            presented: presented,
            presentationStyle: .detent(style: [.large]),
            options: .constant(.alwaysOpenOnTop)
        ) {
            PaymentMethodsNavigation()
        }
    }
}

private struct PaymentMethodsNavigation: View {
    @StateObject private var paymentsNavigationVm = PaymentsNavigationViewModel()
    @AppObservedObject var store: PaymentStore
    var body: some View {
        hNavigationStack(
            router: paymentsNavigationVm.paymentsRouter,
            options: .extendedNavigationWidth,
            tracking: PaymentMethodsDetentType.paymentMethods
        ) {
            PaymentMethodsScreen()
                .navigationTitle(L10n.paymentMethodsTitle)
                .withDismissButton()
                .routerDestination(for: PaymentsRouterAction.self) { routerAction in
                    paymentsDestination(for: routerAction)
                }
        }
        .withPaymentsPresentations(paymentsNavigationVm)
        .task {
            await store.fetchPaymentStatus()
        }
    }
}

private enum PaymentMethodsDetentType: TrackingViewNameProtocol {
    case paymentMethods

    var nameForTracking: String {
        .init(describing: PaymentMethodsScreen.self)
    }
}
