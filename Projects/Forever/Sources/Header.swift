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
                TemporaryCampaignBanner {
                    store.send(.showTemporaryCampaignDetail)
                }
                VStack {
                    PresentableStoreLens(
                        ForeverStore.self,
                        getter: { state in
                            state.foreverData?.grossAmount
                        }
                    ) { grossAmount in
                        if let grossAmount = grossAmount {
                            hText(grossAmount.formattedAmount, style: .caption2)
                                .foregroundColor(hLabelColor.tertiary)
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
                        if let grossAmount = data.grossAmount,
                            let netAmount = data.netAmount,
                            let potentialDiscountAmount = data.potentialDiscountAmount
                        {
                            PieChartView(
                                state: .init(
                                    grossAmount: grossAmount,
                                    netAmount: netAmount,
                                    potentialDiscountAmount: potentialDiscountAmount
                                ),
                                newPrice: netAmount.formattedAmount
                            )
                            .frame(width: 250, height: 250, alignment: .center)

                            if grossAmount.amount != netAmount.amount {
                                // Discount present
                                PriceSectionView(grossAmount: grossAmount, netAmount: netAmount)
                            } else {
                                // No discount present
                                VStack(alignment: .center, spacing: 16) {
                                    hText(L10n.ReferralsEmpty.headline, style: .title1)
                                    hText(
                                        L10n.ReferralsEmpty.body(
                                            potentialDiscountAmount.formattedAmount,
                                            MonetaryAmount(amount: 0, currency: potentialDiscountAmount.currency)
                                                .formattedAmount
                                        )
                                    )
                                    .foregroundColor(hLabelColor.secondary).multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 16)
                            }
                        }
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
