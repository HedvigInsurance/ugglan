import Apollo
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct PaymentHistory: View {
    @PresentableStore var store: PaymentStore
    public var body: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData?.paymentHistory
            }
        ) { history in
            if let history {
                if history.isEmpty {
                    RetryView(title: "No charge history", subtitle: "", retryTitle: "Go Back") {
                        store.send(.goBack)
                    }
                } else {
                    hForm {
                        hSection(history, id: \.date) { element in
                            hRow {
                                hText(element.date)
                                Spacer()
                                hText(element.amount.formattedAmount)
                            }
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
        }
    }
}

extension PaymentHistory {
    public static var journey: some JourneyPresentation {
        HostingJourney(
            PaymentStore.self,
            rootView: PaymentHistory()
        ) { action in
            if case .goBack = action {
                PopJourney()
            }
        }
        .configureTitle(L10n.paymentHistoryTitle)
    }
}

struct PaymentHistory_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .sv_SE
        return PaymentHistory()
            .onAppear {

                let store: PaymentStore = globalPresentableStoreContainer.get()
                let myPaymentQueryData = GiraffeGraphQL.MyPaymentQuery.Data(
                    nextChargeDate: "May 26th 2023",
                    payinMethodStatus: .active,
                    balance: .init(currentBalance: .init(amount: "100", currency: "SEK")),
                    chargeHistory: [
                        .init(amount: .init(amount: "2220", currency: "SEK"), date: "2023-10-12"),
                        .init(amount: .init(amount: "222", currency: "SEK"), date: "2023-11-12"),
                        .init(amount: .init(amount: "2120", currency: "SEK"), date: "2023-12-12"),
                    ],
                    chargeEstimation: .init(
                        charge: .init(amount: "20", currency: "SEKF"),
                        discount: .init(amount: "20", currency: "SEK"),
                        subscription: .init(amount: "20", currency: "SEK")
                    ),
                    activeContractBundles: [
                        .init(id: "1", contracts: [.init(id: "1", typeOfContract: .seHouse, displayName: "NAME")])
                    ]
                )
                let octopusData = OctopusGraphQL.PaymentDataQuery.Data(currentMember: .init(redeemedCampaigns: []))
                let paymentData = PaymentData(myPaymentQueryData, octopusData: octopusData)
                store.send(.setPaymentData(data: paymentData))
            }
    }
}
