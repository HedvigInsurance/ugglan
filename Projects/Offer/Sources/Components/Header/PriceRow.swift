import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct PriceRow {
    enum Placement {
        case header
        case checkout

        var alignment: UIStackView.Alignment {
            switch self {
            case .header:
                return .center
            case .checkout:
                return .leading
            }
        }

        var perMonthTextStyle: TextStyle {
            switch self {
            case .header:
                return TextStyle.brand(.subHeadline(color: .primary)).centerAligned
            case .checkout:
                return TextStyle.brand(.subHeadline(color: .secondary)).leftAligned
            }
        }
    }

    let placement: Placement
}

extension PriceRow: Presentable {
    func materialize() -> (RowView, Disposable) {
        let row = RowView()
        let bag = DisposeBag()
        
        let store: OfferStore = self.get()
        
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 5

        let priceContainer = UIStackView()
        priceContainer.axis = .vertical
        priceContainer.distribution = .equalCentering
        priceContainer.alignment = placement.alignment
        view.addArrangedSubview(priceContainer)

        let priceHorizontalContainer = UIStackView()
        priceHorizontalContainer.axis = .horizontal
        priceHorizontalContainer.distribution = .equalSpacing
        priceHorizontalContainer.alignment = .center
        priceHorizontalContainer.spacing = 2
        priceContainer.addArrangedSubview(priceHorizontalContainer)

        let grossPriceLabel = UILabel(
            value: "",
            style: TextStyle.brand(.callout(color: .tertiary)).centerAligned
                .restyled { (style: inout TextStyle) in
                    style.setParagraphAttribute(
                        2,
                        for: NSAttributedString.Key.strikethroughStyle,
                        update: { _ in }
                    )
                }
        )
        priceHorizontalContainer.addArrangedSubview(grossPriceLabel)

        let netPriceLabel = UILabel(
            value: "",
            style: TextStyle.brand(.largeTitle(color: .primary)).centerAligned
        )
        priceHorizontalContainer.addArrangedSubview(netPriceLabel)

        let perMonthLabel = UILabel(
            value: "",
            style: placement.perMonthTextStyle
        )
        view.addArrangedSubview(perMonthLabel)

        bag += store.stateSignal.map { $0.offerData?.quoteBundle }
            .onValue { quoteBundle in
                guard let quoteBundle = quoteBundle else { return }

                if quoteBundle.appConfiguration.ignoreCampaigns {
                    grossPriceLabel.isHidden = true
                    grossPriceLabel.value = ""
                    netPriceLabel.value =
                        quoteBundle.bundleCost.monthlyGross
                        .formattedAmountWithoutSymbol
                } else {
                    grossPriceLabel.isHidden =
                        quoteBundle.bundleCost.monthlyDiscount
                        .floatAmount == 0
                    netPriceLabel.value =
                        quoteBundle.bundleCost.monthlyNet
                        .formattedAmountWithoutSymbol
                    grossPriceLabel.value =
                        quoteBundle.bundleCost.monthlyGross
                        .formattedAmountWithoutSymbol
                }

                perMonthLabel.value =
                    "\(quoteBundle.bundleCost.monthlyNet.currencySymbol)\(L10n.perMonth)"
            }

        row.append(view)

        return (row, bag)
    }
}
