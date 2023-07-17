import Flow
import Form
import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct HeaderView: View {
    @PresentableStore var store: ForeverStore
    @Binding var scrollTo: (scrollTo: Int, nbOfElements: Int)

    var body: some View {
        hSection {
            VStack(spacing: 16) {
                PresentableStoreLens(
                    ForeverStore.self,
                    getter: { state in
                        state.foreverData
                    }
                ) { data in
                    if let netAmount = data?.netAmount, let grossAmount = data?.grossAmount {
                        let discountValue = MonetaryAmount(
                            amount: grossAmount.value - netAmount.value,
                            currency: netAmount.currency
                        )
                        hText(discountValue.negative.formattedAmount)
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
                            PriceSectionView(netAmount: netAmount, scrollTo: $scrollTo)
                                .padding(.bottom, 65)
                                .padding(.top, 8)
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
                            .padding(.top, 49)
                        }
                    }
                }
            }
            .padding(.top, 72)
        }
        .sectionContainerStyle(.transparent)
    }
}
