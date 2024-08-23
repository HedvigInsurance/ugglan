import Foundation
import StoreContainer
import SwiftUI
import hCore
import hCoreUI

public struct ConnectPaymentCardView: View {
    @hPresentableStore var store: PaymentStore
    @EnvironmentObject var connectPaymentVm: ConnectPaymentViewModel
    @EnvironmentObject var router: Router
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
        .onAppear {
            store.send(.fetchPaymentStatus)
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
                            if let url = DeepLink.getUrl(from: .openChat) {
                                router.push(PaymentsRouterAction.openUrl(url: url))
                            }
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
