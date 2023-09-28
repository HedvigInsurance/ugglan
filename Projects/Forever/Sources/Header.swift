import Flow
import Form
import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct HeaderView: View {
    @PresentableStore var store: ForeverStore
    let didPressInfo: () -> Void

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
                                otherDiscounts: .init(amount: 0, currency: ""),
                                discountCode: "",
                                monthlyDiscount: .init(amount: 0, currency: ""),
                                referrals: [],
                                monthlyDiscountPerReferral: .init(amount: 0, currency: "")
                            )
                    }
                ) { data in
                    if let grossAmount = data?.grossAmount,
                        let netAmount = data?.netAmount,
                        let monthlyDiscountPerReferral = data?.monthlyDiscountPerReferral
                    {
                        PieChartView(
                            state: .init(
                                grossAmount: grossAmount,
                                netAmount: netAmount,
                                monthlyDiscountPerReferral: monthlyDiscountPerReferral
                            ),
                            newPrice: netAmount.formattedAmount
                        )
                        .frame(width: 215, height: 215, alignment: .center)

                        if grossAmount.amount != netAmount.amount {
                            // Discount present
                            PriceSectionView(netAmount: netAmount, didPressInfo: didPressInfo)
                                .padding(.bottom, 65)
                                .padding(.top, 8)
                        } else {
                            // No discount present
                            hText(
                                L10n.ReferralsEmpty.body(
                                    monthlyDiscountPerReferral.formattedAmount,
                                    MonetaryAmount(amount: 0, currency: monthlyDiscountPerReferral.currency)
                                        .formattedAmount
                                )
                            )
                            .foregroundColor(hTextColorNew.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .padding(.top, 64)
        }
        .sectionContainerStyle(.transparent)
    }
}
struct HeaderView_Previews: PreviewProvider {
    @PresentableStore static var store: ForeverStore
    static var previews: some View {
        HeaderView {}
            .onAppear {
                let foreverData = ForeverData.mock()
                store.send(.setForeverData(data: foreverData))
            }
    }
}

struct HeaderView_Previews2: PreviewProvider {
    @PresentableStore static var store: ForeverStore
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return HeaderView {}
            .onAppear {

                let foreverData = ForeverData(
                    grossAmount: .sek(200),
                    netAmount: .sek(160),
                    otherDiscounts: .sek(40),
                    discountCode: "CODE2",
                    monthlyDiscount: .sek(10),
                    referrals: [],
                    monthlyDiscountPerReferral: .sek(10)
                )
                store.send(.setForeverData(data: foreverData))
            }
    }
}
