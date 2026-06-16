import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct ConnectPaymentCardView: View {
    @EnvironmentObject var connectPaymentVm: ConnectPaymentViewModel
    public init() {}
    public var body: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state
            }
        ) { state in
            if let status = state.paymentStatusData?.status {
                getStatusInfoView(from: status, state: state)
            }
        }
    }

    @ViewBuilder
    func getStatusInfoView(from status: PayinMethodStatus, state: PaymentState) -> some View {
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
        } else if status == .needsSetup || state.showsConnectPayment {
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
