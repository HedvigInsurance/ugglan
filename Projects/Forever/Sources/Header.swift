import Foundation
import PresentableStore
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
                    if let monthlyDiscount = data?.monthlyDiscount, monthlyDiscount.value == 0 {
                        hText(monthlyDiscount.negative.formattedAmount)
                            .foregroundColor(hTextColor.Opaque.secondary)
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
                                referredBy: .init(name: "", activeDiscount: nil, status: .active),
                                monthlyDiscountPerReferral: .init(amount: 0, currency: "")
                            )
                    }
                ) { data in
                    if let grossAmount = data?.grossAmount,
                        let netAmount = data?.netAmount,
                        let monthlyDiscountPerReferral = data?.monthlyDiscountPerReferral,
                        let monthlyDiscount = data?.monthlyDiscount
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

                        if monthlyDiscount.value > 0 {
                            // Discount present
                            PriceSectionView(monthlyDiscount: monthlyDiscount, didPressInfo: didPressInfo)
                                .padding(.bottom, 65)
                                .padding(.top, .padding8)
                        } else {
                            // No discount present
                            hText(
                                L10n.ReferralsEmpty.body(
                                    monthlyDiscountPerReferral.formattedAmount
                                )
                            )
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, .padding8)
                        }
                    }
                }
            }
            .padding(.top, .padding64)
        }
        .sectionContainerStyle(.transparent)
    }
}
struct HeaderView_Previews: PreviewProvider {
    @PresentableStore static var store: ForeverStore
    static var previews: some View {
        HeaderView {}
            .onAppear {
                Dependencies.shared.add(module: Module { () -> ForeverClient in ForeverClientDemo() })
            }
    }
}

struct HeaderView_Previews2: PreviewProvider {
    @PresentableStore static var store: ForeverStore
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return HeaderView {}
            .onAppear {

                let foreverData = ForeverData(
                    grossAmount: .sek(200),
                    netAmount: .sek(160),
                    otherDiscounts: .sek(40),
                    discountCode: "CODE2",
                    monthlyDiscount: .sek(10),
                    referrals: [],
                    referredBy: .init(name: "", activeDiscount: nil, status: .active),
                    monthlyDiscountPerReferral: .sek(10)
                )
                store.send(.setForeverData(data: foreverData))
            }
    }
}
