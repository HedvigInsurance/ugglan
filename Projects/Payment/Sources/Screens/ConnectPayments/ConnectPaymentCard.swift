import AppStateContainer
import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ConnectPaymentCardView: View {
    @AppObservedObject var store: PaymentStore
    private let onConnectPayment: () -> Void

    public init(onConnectPayment: @escaping () -> Void) {
        self.onConnectPayment = onConnectPayment
    }

    public var body: some View {
        if let status = store.paymentStatusData?.status {
            statusCard(for: status)
        }
    }

    @ViewBuilder
    private func statusCard(for status: PayinMethodStatus) -> some View {
        if case let .terminatingDueToMissedPayments(date) = status {
            PaymentAttentionCard(
                title: L10n.homeTodoPaymentOverdueTitle,
                subtitle: L10n.homeTodoRequiresActionSubtitle,
                message: L10n.InfoCardMissingPayment.missingPaymentsBody(date),
                buttonTitle: L10n.General.chatButton
            ) {
                NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
            }
        } else if status == .needsSetup || store.showsConnectPayment {
            PaymentAttentionCard(
                title: L10n.homeTodoMissingPaymentMethodTitle,
                subtitle: L10n.homeTodoRequiresActionSubtitle,
                message: L10n.InfoCardMissingPayment.body,
                buttonTitle: L10n.PayInExplainer.buttonText,
                action: onConnectPayment
            )
        }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })

    let store: PaymentStore = globalAppStateContainer.get()
    store.paymentStatusData = .init(
        status: .needsSetup,
        chargingDay: nil,
        defaultPayinMethod: nil,
        payinMethods: [],
        defaultPayoutMethod: nil,
        payoutMethods: [],
        availableMethods: [],
        missingConnection: .payin,
        layout: .other
    )

    return ConnectPaymentCardView(onConnectPayment: {})
}
