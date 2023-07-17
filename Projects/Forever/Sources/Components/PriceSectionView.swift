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
    @State var netAmount: MonetaryAmount
    @Binding var scrollTo: (scrollTo: Int, nbOfElements: Int)

    @State private var netAmountAnimate: MonetaryAmount = .init(amount: 0, currency: "")

    var body: some View {
        VStack(spacing: 0) {
            hText(L10n.foreverTabMontlyCostLabel)
            HStack(spacing: 4) {
                hText(netAmountAnimate.formattedAmount + "/" + L10n.monthAbbreviationLabel)
                Image(uiImage: hCoreUIAssets.infoIconFilled.image)
                    .onTapGesture {
                        scrollTo.scrollTo = scrollTo.nbOfElements - 1
                    }
            }
            .foregroundColor(hTextColorNew.secondary)
        }
        .onAppear {
            netAmount = .init(amount: netAmount.amount, currency: netAmount.currency)
            withAnimation(Animation.easeIn(duration: 0.8).delay(0.7)) {
                netAmountAnimate = netAmount
            }
        }
    }
}
