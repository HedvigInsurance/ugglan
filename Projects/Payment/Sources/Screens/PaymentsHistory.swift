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
                                hText(element.amount.formattedAbsoluteAmount)
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
                let memberData = OctopusGraphQL.PaymentDataQuery.Data.CurrentMember(
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
