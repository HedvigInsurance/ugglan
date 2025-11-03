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
                state.paymentStatusData
            }
        ) { paymentStatusData in
            if let status = paymentStatusData?.status {
                getStatusInfoView(from: status)
            }
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
        } else if case .needsSetup = status {
            InfoCard(
                text: L10n.InfoCardMissingPayment.body,
                type: .attention
            )
            .buttons(
                [
                    .init(
                        buttonTitle: L10n.PayInExplainer.buttonText,
                        buttonAction: {
                            connectPaymentVm.set(for: .initial)
                        }
                    )
                ]
            )
        }
    }
}
