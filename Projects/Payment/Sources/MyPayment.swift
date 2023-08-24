import Adyen
import AdyenDropIn
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
        LoadingViewWithContent(PaymentStore.self, [.getPaymentData, .getActivePayment], vm.getActionsToSendToStore()) {
            hForm {
                PaymentInfoView(urlScheme: vm.urlScheme)
                PaymentView(paymentType: paymentType)
                PayoutView(paymentType: paymentType)
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
                state.paymentData
            }
        ) { paymentData in
            hSection {
                hButton.LargeButtonPrimary {
                    vm.openConnectCard()
                } content: {
                    hText(
                        paymentData?.status == .needsSetup
                            ? L10n.myPaymentDirectDebitButton : L10n.myPaymentDirectDebitReplaceButton
                    )
                }
                .trackLoading(PaymentStore.self, action: .getAdyenAvailableMethods)
            }
            .padding(.vertical, 16)
        }
    }

}

class MyPaymentsViewModel: ObservableObject {
    @PresentableStore var store: PaymentStore
    let urlScheme: String
    let paymentType: PaymentType
    public init(urlScheme: String, paymentType: PaymentType) {
        self.urlScheme = urlScheme
        let store: PaymentStore = globalPresentableStoreContainer.get()
        store.send(.load)
        self.paymentType = paymentType
        for action in getActionsToSendToStore() {
            store.send(action)
        }
    }

    func getActionsToSendToStore() -> [PaymentAction] {
        var actions = [PaymentAction]()
        actions.append(.load)
        switch paymentType {
        case .adyen:
            store.send(.fetchActivePayment)
            store.send(.fetchActivePayout)
        case .trustly:
            break
        }
        return actions
    }

    func openConnectCard() {
        switch paymentType {
        case .adyen:
            store.send(.fetchAdyenAvailableMethods)
        case .trustly:
            store.send(.openConnectBankAccount)
        }

    }
}

struct MyPaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        MyPaymentsView(urlScheme: Bundle.main.urlScheme ?? "")
            .onAppear {
                let store: PaymentStore = globalPresentableStoreContainer.get()
                let myPaymentQueryData = GiraffeGraphQL.MyPaymentQuery.Data(
                    bankAccount: .init(bankName: "NAME", descriptor: "hyehe"),
                    nextChargeDate: "May 26th 2023",
                    payinMethodStatus: .pending,
                    redeemedCampaigns: [.init(code: "CODE")],
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
                let data = PaymentData(myPaymentQueryData)
                store.send(.setPaymentData(data: data))
            }
    }
}
