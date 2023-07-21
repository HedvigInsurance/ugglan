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

    public var body: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData?.paymentHistory
            }
        ) { history in
            if let history {
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

extension PaymentHistory {
    public static var journey: some JourneyPresentation {
        HostingJourney(
            rootView: PaymentHistory()
        )
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
                    chargeEstimation: .init(
                        subscription: .init(amount: "20", currency: "SEK"),
                        charge: .init(amount: "30", currency: "SEK"),
                        discount: .init(amount: "10", currency: "SEK")
                    ),
                    bankAccount: .init(bankName: "NAME", descriptor: "hyehe"),
                    nextChargeDate: "May 26th 2023",
                    payinMethodStatus: .active,
                    redeemedCampaigns: [.init(code: "CODE")],
                    balance: .init(currentBalance: .init(amount: "100", currency: "SEK")),
                    chargeHistory: [
                        .init(amount: .init(amount: "2220", currency: "SEK"), date: "2023-10-12"),
                        .init(amount: .init(amount: "222", currency: "SEK"), date: "2023-11-12"),
                        .init(amount: .init(amount: "2120", currency: "SEK"), date: "2023-12-12"),
                    ]
                )
                let data = PaymentData(myPaymentQueryData)
                store.send(.setPaymentData(data: data))
            }
    }
}
