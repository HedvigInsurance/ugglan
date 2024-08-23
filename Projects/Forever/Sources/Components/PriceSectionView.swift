import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct AnimatableMonetaryAmountModifier: AnimatableModifier {
    var amount: MonetaryAmount

    var animatableData: Float {
        get { amount.value }
        set { amount.amount = String(Int(newValue)) }
    }

    func body(content: Content) -> some View {
        hText("\(amount.formattedAmount)", style: .heading2)
    }
}

extension View {
    func animatingAmountOverlay(for amount: MonetaryAmount) -> some View {
        modifier(AnimatableMonetaryAmountModifier(amount: amount))
    }
}

struct PriceSectionView: View {
    @State var monthlyDiscount: MonetaryAmount
    let didPressInfo: () -> Void

    @State private var monthlyDiscountAnimate: MonetaryAmount = .init(amount: 0, currency: "")

    var body: some View {
        VStack(spacing: 0) {
            hText(L10n.foreverTabMonthlyDiscount)
            HStack(spacing: 4) {
                hText(monthlyDiscountAnimate.negative.formattedAmount + "/" + L10n.monthAbbreviationLabel)
                Image(uiImage: hCoreUIAssets.infoFilled.image)
                    .resizable()
                    .frame(width: 16, height: 16)
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
