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
            if let nextChargeDate = paymentStatusData?.nextChargeDate?.displayDate,
                paymentStatusData?.status == .needsSetup
            {
                InfoCard(
                    text: L10n.InfoCardMissingPayment.bodyWithDate(nextChargeDate),
                    type: .attention
                )
                .buttons([
                    .init(
                        buttonTitle: L10n.PayInExplainer.buttonText,
                        buttonAction: {
                            connectPaymentsVm.isConnectPaymentPresented = true
                        }
                    )
                ])
            } else if paymentStatusData?.status == .needsSetup {
                NavigationStack {
                    InfoCard(
                        text: L10n.InfoCardMissingPayment.body,
                        type: .attention
                    )
                    .buttons([
                        .init(
                            buttonTitle: L10n.PayInExplainer.buttonText,
                            buttonAction: {
                                connectPaymentsVm.isConnectPaymentPresented = true
                            }
                        )
                    ]
                    )
                    .sheet(isPresented: $connectPaymentsVm.isConnectPaymentPresented) {
                        DirectDebitSetup()
                            .presentationDetents([.medium])
                    }
                }
            }
        }
        .onAppear {
            store.send(.fetchPaymentStatus)
        }
    }
}
