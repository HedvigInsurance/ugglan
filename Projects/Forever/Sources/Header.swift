import Flow
import Form
import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct HeaderView: View {
    @PresentableStore var store: ForeverStore

    var body: some View {
        hSection {
            VStack {
                TemporaryCampaignBanner { /* TODO - can we remove this? */
                    store.send(.showTemporaryCampaignDetail)
                }
                VStack(spacing: 24) {
                    PresentableStoreLens(
                        ForeverStore.self,
                        getter: { state in
                            state.foreverData?.grossAmount
                        }
                    ) { grossAmount in
                        if let grossAmount = grossAmount {
                            hText(grossAmount.formattedAmount)
                                .foregroundColor(hTextColorNew.secondary)
                        }
                    }
                    PresentableStoreLens(
                        ForeverStore.self,
                        getter: { state in
                            state.foreverData
                                ?? ForeverData.init(
                                    grossAmount: .init(amount: 0, currency: ""),
                                    netAmount: .init(amount: 0, currency: ""),
                                    potentialDiscountAmount: .init(amount: 0, currency: ""),
                                    discountCode: "",
                                    invitations: []
                                )
                        }
                    ) { data in
                        if let grossAmount = data?.grossAmount,
                            let netAmount = data?.netAmount,
                            let potentialDiscountAmount = data?.potentialDiscountAmount
                        {
                            PieChartView(
                                state: .init(
                                    grossAmount: grossAmount,
                                    netAmount: netAmount,
                                    potentialDiscountAmount: potentialDiscountAmount
                                ),
                                newPrice: netAmount.formattedAmount
                            )
                            .frame(width: 215, height: 215, alignment: .center)

                            if grossAmount.amount != netAmount.amount {
                                // Discount present
                                PriceSectionView(grossAmount: grossAmount, netAmount: netAmount)
                            } else {
                                // No discount present
                                hText(
                                    L10n.ReferralsEmpty.body(
                                        potentialDiscountAmount.formattedAmount,
                                        MonetaryAmount(amount: 0, currency: potentialDiscountAmount.currency)
                                            .formattedAmount
                                    )
                                )
                                .foregroundColor(hTextColorNew.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 42)
                            }
                        }
                    }
                }
            }
            .padding(.top, 72)
        }
        .sectionContainerStyle(.transparent)
    }
}
