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
                let memberData = OctopusGraphQL.PaymentDataQuery.Data.CurrentMember(
                    activeContracts: [
                        .init(
                            id: "id",
                            currentAgreement: .init(
                                productVariant: .init(
                                    typeOfContract: "SE_ACCIDENT",
                                    displayName: "display name"
                                )
                            )
                        )
                    ],
                    redeemedCampaigns: [],
                    chargeHistory: [
                        .init(
                            amount: .init(amount: 100, currencyCode: .sek),
                            date: "2020-11-10",
                            status: .success
                        )
                    ],
                    insuranceCost: .init(
                        monthlyDiscount: .init(amount: 20, currencyCode: .sek),
                        monthlyGross: .init(amount: 100, currencyCode: .sek),
                        monthlyNet: .init(amount: 80, currencyCode: .sek)
                    )
                )
                let octopusData = OctopusGraphQL.PaymentDataQuery.Data(currentMember: memberData)
                let paymentData = PaymentData(octopusData)
                store.send(.setPaymentData(data: paymentData))
            }
    }
}
