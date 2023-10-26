import Apollo
import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct MyPaymentsView: View {
    @ObservedObject private var vm: MyPaymentsViewModel

    let paymentType: PaymentType
    public init(urlScheme: String) {
        vm = .init(urlScheme: urlScheme, paymentType: hAnalyticsExperiment.paymentType)
        self.paymentType = hAnalyticsExperiment.paymentType
    }
    public var body: some View {
        LoadingViewWithContent(PaymentStore.self, [.getPaymentData, .getPaymentStatus], [.load]) {
            hForm {
                PaymentInfoView(urlScheme: vm.urlScheme)
                    .padding(.top, 8)
                PaymentView(paymentType: paymentType)
                bottomButtonView
            }
            .sectionContainerStyle(.transparent)
        }
        .presentableStoreLensAnimation(.easeInOut(duration: 0.2))
    }

    private var bottomButtonView: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentStatusData
            }
        ) { statusData in
            hSection {
                hButton.LargeButton(type: .primary) {
                    vm.openConnectCard()
                } content: {
                    hText(
                        statusData?.status == .needsSetup
                            ? L10n.myPaymentDirectDebitButton : L10n.myPaymentDirectDebitReplaceButton
                    )
                }
            }
            .padding(.vertical, 16)
        }
    }

}

class MyPaymentsViewModel: ObservableObject {
    @PresentableStore var store: PaymentStore
    @Inject var adyenService: AdyenService
    let urlScheme: String
    let paymentType: PaymentType
    public init(urlScheme: String, paymentType: PaymentType) {
        self.urlScheme = urlScheme
        let store: PaymentStore = globalPresentableStoreContainer.get()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            store.send(.load)
            store.send(.fetchPaymentStatus)
        }
        self.paymentType = paymentType
    }
    func openConnectCard() {
        store.send(.openConnectBankAccount)
    }

    private func getPayment() {

    }
}

struct MyPaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        MyPaymentsView(urlScheme: Bundle.main.urlScheme ?? "")
            .onAppear {
                let store: PaymentStore = globalPresentableStoreContainer.get()
                let myPaymentQueryData = GiraffeGraphQL.MyPaymentQuery.Data(
                    nextChargeDate: "May 26th 2023",
                    payinMethodStatus: .pending,
                    balance: .init(currentBalance: .init(amount: "20", currency: "SEK")),
                    chargeHistory: [.init(amount: .init(amount: "2220", currency: "SEKF"), date: "DATE 1")],
                    chargeEstimation: .init(
                        charge: .init(amount: "20", currency: "SEK"),
                        discount: .init(amount: "20", currency: "SEK"),
                        subscription: .init(amount: "20", currency: "SEK")
                    ),
                    activeContractBundles: [
                        .init(id: "1", contracts: [.init(id: "1", typeOfContract: .seHouse, displayName: "name")])
                    ]
                )
                let octopusData = OctopusGraphQL.PaymentDataQuery.Data(currentMember: .init(redeemedCampaigns: []))
                let data = PaymentData(myPaymentQueryData, octopusData: octopusData)
                store.send(.setPaymentData(data: data))
            }
    }
}
