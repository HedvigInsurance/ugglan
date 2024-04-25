import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public class ConnectPaymentsNavigationViewModel: ObservableObject {
    @Published public var isConnectPaymentPresented = false
}

public struct ConnectPaymentCardView: View {
    @PresentableStore var store: PaymentStore
    @StateObject var connectPaymentsVm = ConnectPaymentsNavigationViewModel()

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
                                store.send(.navigation(to: .openUrl(url: url, handledBySystem: false)))
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
                            connectPaymentsVm.isConnectPaymentPresented = true
                        }
                    )
                ]
            )
        }
    }

}
