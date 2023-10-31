import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI

public struct ConnectPaymentCardView: View {
    @PresentableStore var store: PaymentStore

    public var hasActiveInfoCard: Bool {
        return store.state.paymentStatusData?.status == .needsSetup
    }
    public init() {}
    public var body: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentStatusData
            }
        ) { paymentStatusData in
            if let infoMessage = paymentStatusData?.getNeedSetupInfoMessage {
                InfoCard(
                    text: infoMessage,
                    type: .attention
                )
                .buttons([
                    .init(
                        buttonTitle: L10n.PayInExplainer.buttonText,
                        buttonAction: {
                            store.send(.connectPayments)
                        }
                    )
                ]
                )
            }
        }
        .onAppear {
            store.send(.fetchPaymentStatus)
        }
    }
}
