import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct ConnectPaymentCardView: View {
    @PresentableStore var store: PaymentStore

    public init() {}

    public var body: some View {
        VStack {
            PresentableStoreLens(
                PaymentStore.self,
                getter: { state in
                    state.paymentStatus
                }
            ) { paymentStatus in
                if paymentStatus == .needsSetup {
                    InfoCard(text: L10n.InfoCardMissingPayment.body, type: .attention)
                        .buttons([
                            .init(
                                buttonTitle: L10n.PayInExplainer.buttonText,
                                buttonAction: {
                                    store.send(.connectPayments)
                                }
                            )
                        ])
                }
            }
        }
        .onAppear {
            store.send(.fetchPayInMethodStatus)
        }
    }
}
