import AppStateContainer
import Foundation
import SwiftUI
import hCore
import hCoreUI

public struct ConnectPaymentCardView: View {
    @AppObservedObject var store: PaymentStore
    @EnvironmentObject var connectPaymentVm: ConnectPaymentViewModel
    public init() {}
    public var body: some View {
        if let status = store.paymentStatusData?.status {
            getStatusInfoView(from: status)
        }
    }

    @ViewBuilder
    func getStatusInfoView(from status: PayinMethodStatus) -> some View {
        if case let .contactUs(date) = status {
            InfoCard(
                text: L10n.InfoCardMissingPayment.missingPaymentsBody(date),
                type: .attention
            )
            .buttons(
                [
                    .init(
                        buttonTitle: L10n.General.chatButton,
                        buttonAction: {
                            NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                        }
                    )
                ]
            )
        } else if status == .needsSetup || store.showsConnectPayment {
            InfoCard(
                text: L10n.InfoCardMissingPayment.body,
                type: .attention
            )
            .buttons(
                [
                    .init(
                        buttonTitle: L10n.PayInExplainer.buttonText,
                        buttonAction: { [weak connectPaymentVm] in
                            connectPaymentVm?.set()
                        }
                    )
                ]
            )
        }
    }
}
