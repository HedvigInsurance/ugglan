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
        hText("\(amount.formattedAmount)", style: .title2)
    }
}

extension View {
    func animatingAmountOverlay(for amount: MonetaryAmount) -> some View {
        modifier(AnimatableMonetaryAmountModifier(amount: amount))
    }
}

struct PriceSectionView: View {
    @State var grossAmount: MonetaryAmount
    @State var netAmount: MonetaryAmount

    @State private var netAmountAnimate: MonetaryAmount = .init(amount: 0, currency: "")
    @State private var discountAmountAnimate: MonetaryAmount = .init(amount: 0, currency: "")

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                hText(L10n.ReferralsActive.Discount.Per.Month.title, style: .footnote)
                    .foregroundColor(hLabelColor.tertiary)
                Color.clear
                    .animatingAmountOverlay(for: discountAmountAnimate)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                hText(L10n.ReferralsActive.Your.New.Price.title, style: .footnote).foregroundColor(hLabelColor.tertiary)
                Color.clear
                    .animatingAmountOverlay(for: netAmountAnimate)
            }
        }
        .padding(16)
        .onAppear {
            netAmountAnimate = .init(amount: grossAmount.amount, currency: netAmount.currency)
            discountAmountAnimate = .init(amount: 0, currency: netAmount.currency)
            withAnimation(Animation.easeIn(duration: 0.8).delay(0.7)) {
                netAmountAnimate = netAmount
                discountAmountAnimate = MonetaryAmount(
                    amount: netAmount.value - grossAmount.value,
                    currency: netAmount.currency
                )
            }
        }
    }
}
