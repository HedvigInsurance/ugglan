import Flow
import Form
import Foundation
import UIKit
import hCore

struct DiscountTerms {}

extension DiscountTerms: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let bag = DisposeBag()
		let view = UIControl()

		bag += view.signal(for: .touchUpInside).compactMap { URL(string: L10n.referralsReceiverTermsLink) }
			.onValue { url in UIApplication.shared.open(url, options: [:], completionHandler: nil) }

		let containerStackView = UIStackView()
		containerStackView.isLayoutMarginsRelativeArrangement = true
		containerStackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 8)
		containerStackView.isUserInteractionEnabled = false
		view.addSubview(containerStackView)

		containerStackView.snp.makeConstraints { make in make.top.bottom.leading.trailing.equalToSuperview() }

		return (view, bag)
	}
}
