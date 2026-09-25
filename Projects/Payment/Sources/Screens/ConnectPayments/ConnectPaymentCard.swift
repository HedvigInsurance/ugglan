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
            card(
                title: L10n.homeTodoPaymentOverdueTitle,
                message: L10n.InfoCardMissingPayment.missingPaymentsBody(date),
                buttonTitle: L10n.General.chatButton
            ) {
                NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
            }
        } else if status == .needsSetup || store.showsConnectPayment {
            card(
                title: L10n.homeTodoMissingPaymentMethodTitle,
                message: L10n.InfoCardMissingPayment.body,
                buttonTitle: L10n.PayInExplainer.buttonText,
                action: onConnectPayment
            )
        }
    }

    private func card(
        title: String,
        message: String,
        buttonTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: .padding16) {
                VStack(alignment: .leading, spacing: .padding8) {
                    headerRow(title: title)
                    hText(message, style: .label)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                hButton(
                    .small,
                    .primary,
                    content: .init(title: buttonTitle)
                ) { action() }
                .hButtonTakeFullWidth(true)
            }
            .padding(.padding16)
        }
    }

    private func headerRow(title: String) -> some View {
        HStack(alignment: .center, spacing: .padding10) {
            warningIcon
            VStack(alignment: .leading, spacing: .padding2) {
                hText(title, style: .label)
                    .foregroundColor(hTextColor.Opaque.primary)
                hText(L10n.homeTodoRequiresActionSubtitle, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }

    private var warningIcon: some View {
        hCoreUIAssets.warningTriangleFilled.view
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(hSignalColor.Red.element)
            .padding(.padding8)
            .background(hSignalColor.Red.fill)
            .clipShape(Circle())
            .accessibilityHidden(true)
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
