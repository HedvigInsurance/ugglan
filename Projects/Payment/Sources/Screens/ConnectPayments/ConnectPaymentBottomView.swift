import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct ConnectPaymentBottomView: View {
    @EnvironmentObject var paymentNavigationVm: PaymentsNavigationViewModel
    let alwaysShowButton: Bool

    var body: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentStatusData
            }
        ) { statusData in
            if let statusData, !statusData.status.showConnectPayment {
                hSection {
                    VStack(spacing: .padding16) {
                        if alwaysShowButton || statusData.paymentChargeData == nil {
                            if statusData.status == .pending {
                                InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                            }
                            hButton(
                                .large,
                                .secondary,
                                content: .init(title: statusData.status.connectButtonTitle),
                                {
                                    paymentNavigationVm.connectPaymentVm.set()
                                }
                            )
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }
}
