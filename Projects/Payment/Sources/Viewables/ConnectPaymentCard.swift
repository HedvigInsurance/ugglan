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
                    hCard(
                        titleIcon: hCoreUIAssets.warningTriangle.image,
                        title: L10n.InfoCardMissingPayment.title,
                        bodyText: L10n.InfoCardMissingPayment.body,
                        backgroundColor: hTintColor.yellowTwo
                    ) {
                        hButton.SmallButtonOutlined {
                            store.send(.connectPayments)

                        } content: {
                            L10n.InfoCardMissingPayment.buttonText.hText()
                        }
                    }
                }
            }
        }
        .onAppear {
            store.send(.fetchPayInMethodStatus)
        }
    }
}
