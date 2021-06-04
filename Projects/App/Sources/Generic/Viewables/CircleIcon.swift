import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct CircleIcon {
	let iconAsset: ImageAsset
	let iconWidth: CGFloat
	let spacing: CGFloat
	let backgroundColor: UIColor
}

extension CircleIcon: Viewable {
	func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let view = UIView()
		let circleView = UIView()
		circleView.backgroundColor = backgroundColor

		let bag = DisposeBag()

		bag += circleView.didLayoutSignal.onValue { _ in
			circleView.layer.cornerRadius = circleView.frame.width / 2
		}

		let icon = Icon(frame: .zero, icon: iconAsset.image, iconWidth: iconWidth)
		circleView.addSubview(icon)

		circleView.layer.shadowOpacity = 0.2
		circleView.layer.shadowOffset = CGSize(width: 10, height: 10)
		circleView.layer.shadowRadius = 16
		circleView.layer.shadowColor = UIColor.brand(.primaryShadowColor).cgColor

		view.addSubview(circleView)

		icon.snp.makeConstraints { make in make.width.equalTo(self.iconWidth)
			make.height.equalTo(self.iconWidth)
			make.center.equalToSuperview()
		}

		circleView.snp.makeConstraints { make in make.width.equalTo(self.iconWidth + self.spacing)
			make.height.equalTo(self.iconWidth + self.spacing)
			make.center.equalToSuperview()
		}

		bag += view.didLayoutSignal.onFirstValue {
			view.snp.makeConstraints { make in make.height.equalTo(self.iconWidth + self.spacing) }
		}

		return (view, bag)
	}
}
