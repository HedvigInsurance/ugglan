import Flow
import Form
import Foundation
import SwiftUI
import UIKit
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

struct Header { let service: ForeverService }

extension Header: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        stackView.axis = .vertical

        let bag = DisposeBag()

        let temporaryCampaignBannerView = HostingView(
            rootView: TemporaryCampaignBanner {
                stackView.viewController?.present(TemporaryCampaignDetail().journey).onValue {}
            }
        )
        stackView.addArrangedSubview(temporaryCampaignBannerView)

        bag += stackView.traitCollectionSignal.atOnce()
            .onValue { trait in let style = DynamicFormStyle.brandInset.style(from: trait)
                let insets = style.insets
                stackView.layoutMargins = UIEdgeInsets(
                    top: insets.top,
                    left: insets.left,
                    bottom: 24,
                    right: insets.right
                )
            }

        stackView.isLayoutMarginsRelativeArrangement = true

        let piePrice = UILabel(
            value: "\u{00a0}",
            style: TextStyle.brand(.footnote(color: .tertiary)).aligned(to: .center)
        )
        piePrice.alpha = 0
        stackView.addArrangedSubview(piePrice)

        bag += service.dataSignal.compactMap { $0?.grossAmount }
            .animated(style: SpringAnimationStyle.lightBounce()) { amount in
                piePrice.value = amount.formattedAmount
                piePrice.alpha = 1
            }

        //let pieChart = PieChart(stateSignal: .init(.init(percentagePerSlice: 0, slices: 0)))
        //bag += stackView.addArranged(pieChart)

        let emptyStateHeader = EmptyStateHeader(
            potentialDiscountAmountSignal: service.dataSignal.map { $0?.potentialDiscountAmount }.atOnce()
        )
        emptyStateHeader.isHiddenSignal.value = true

        bag += stackView.addArranged(emptyStateHeader)

        let priceSection = PriceSection(
            grossAmountSignal: service.dataSignal.map { $0?.grossAmount }.atOnce(),
            netAmountSignal: service.dataSignal.map { $0?.netAmount }.atOnce()
        )
        priceSection.isHiddenSignal.value = true
        bag += stackView.addArranged(priceSection)

        bag += stackView.addArranged(Spacing(height: 20))

        let discountCodeSection = DiscountCodeSection(service: service)
        bag += stackView.addArranged(discountCodeSection)

        bag += combineLatest(
            service.dataSignal.map { $0?.grossAmount }.atOnce().compactMap { $0 },
            service.dataSignal.map { $0?.netAmount }.atOnce().compactMap { $0 },
            service.dataSignal.map { $0?.potentialDiscountAmount }.atOnce().compactMap { $0 }
        )
        .onValue { grossAmount, netAmount, potentialDiscountAmount in
            /*bag += Signal(after: 0.8)
                .onValue { _ in
                    pieChart.stateSignal.value = .init(
                        grossAmount: grossAmount,
                        netAmount: netAmount,
                        potentialDiscountAmount: potentialDiscountAmount
                    )
                }*/

            emptyStateHeader.isHiddenSignal.value = grossAmount.amount != netAmount.amount
            priceSection.isHiddenSignal.value = grossAmount.amount == netAmount.amount
        }

        return (stackView, bag)
    }
}
