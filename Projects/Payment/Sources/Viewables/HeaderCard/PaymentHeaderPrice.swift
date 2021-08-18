import Flow
import Form
import Foundation
import UIKit
import hCore

struct PaymentHeaderPrice {
	let grossPriceSignal: ReadSignal<Int>
	let discountSignal: ReadSignal<Int>
	let monthlyNetPriceSignal: ReadSignal<Int>
}

extension PaymentHeaderPrice: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let bag = DisposeBag()

		let stackView = UIStackView()
		stackView.distribution = .fillProportionally
		stackView.axis = .vertical
		stackView.alignment = .leading

		let priceLabel = UILabel(value: "", style: TextStyle.brand(.largeTitle(color: .primary)))
		stackView.addArrangedSubview(priceLabel)

		let grossPriceLabel = UILabel(
			value: "",
			style: TextStyle.brand(.title3(color: .tertiary))
				.restyled { (style: inout TextStyle) in
					style.setParagraphAttribute(
						2,
						for: NSAttributedString.Key.strikethroughStyle,
						update: { _ in }
					)
				}
		)
		grossPriceLabel.animationSafeIsHidden = true

		stackView.addArrangedSubview(grossPriceLabel)

		bag += combineLatest(discountSignal, grossPriceSignal)
			.animated(
				style: SpringAnimationStyle.mediumBounce(),
				animations: { monthlyDiscount, monthlyGross in
					grossPriceLabel.value = "\(monthlyGross) kr"
					grossPriceLabel.animationSafeIsHidden = monthlyDiscount == 0
					grossPriceLabel.alpha = monthlyDiscount == 0 ? 0 : 1
				}
			)

		bag += monthlyNetPriceSignal.onValue { amount in priceLabel.value = "\(String(Int(amount))) kr"
			priceLabel.layoutIfNeeded()
		}

		return (stackView, bag)
	}
}
