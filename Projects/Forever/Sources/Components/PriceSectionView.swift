import Foundation
import SwiftUI
import hCore
import hCoreUI

struct PriceSectionView: View {
    @State var monthlyDiscount: MonetaryAmount
    let didPressInfo: () -> Void

    @State private var monthlyDiscountAnimate: MonetaryAmount = .init(amount: 0, currency: "")

    var body: some View {
        VStack(spacing: 0) {
            hText(L10n.foreverTabMonthlyDiscount)
            HStack(spacing: 4) {
                hText(monthlyDiscountAnimate.negative.formattedAmount + "/" + L10n.monthAbbreviationLabel)
                hCoreUIAssets.infoFilled.view
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        didPressInfo()
                    }
            }
            .foregroundColor(hTextColor.Opaque.secondary)
        }
        .onAppear {
            monthlyDiscount = .init(amount: monthlyDiscount.amount, currency: monthlyDiscount.currency)
            withAnimation(Animation.easeIn(duration: 0.8).delay(0.7)) {
                monthlyDiscountAnimate = monthlyDiscount
            }
        }
    }
}
