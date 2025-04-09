import Foundation
import SwiftUI
import hCore
import hCoreUI

struct HeaderView: View {
    @EnvironmentObject var foreverNavigationVm: ForeverNavigationViewModel
    let didPressInfo: () -> Void

    var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                if let monthlyDiscount = foreverNavigationVm.foreverData?.monthlyDiscount, monthlyDiscount.value == 0 {
                    hText(monthlyDiscount.negative.formattedAmount)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .accessibilityLabel(L10n.foreverTabMonthlyDiscount + monthlyDiscount.negative.formattedAmount)
                }
                let data = foreverNavigationVm.foreverData
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
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.top, .padding8)
                    }
                }
            }
            .padding(.top, .padding64)
        }
        .sectionContainerStyle(.transparent)
        .accessibilityElement(children: .combine)
    }
}
struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView {}
            .onAppear {
                Dependencies.shared.add(module: Module { () -> ForeverClient in ForeverClientDemo() })
            }
    }
}

struct HeaderView_Previews2: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return HeaderView {}
    }
}
