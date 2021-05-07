import Flow
import Foundation
import UIKit
import hCore
import hCoreUI

struct AttachGIFButton { let isOpenSignal: ReadSignal<Bool> }

extension AttachGIFButton: Viewable {
	func materialize(events _: ViewableEvents) -> (UIControl, Signal<Void>) {
		let bag = DisposeBag()
		let control = UIControl()
		control.backgroundColor = .brand(.primaryBackground())
		control.layer.cornerRadius = 8

		control.snp.makeConstraints { make in make.width.height.equalTo(40) }

		let icon = Icon(icon: Asset.gif.image, iconWidth: 20)
		control.addSubview(icon)

		icon.snp.makeConstraints { make in make.width.height.equalTo(20)
			make.center.equalToSuperview()
		}

		bag += isOpenSignal.atOnce().animated(style: AnimationStyle.linear(duration: 0.1)) { isOpen in
			if isOpen {
				icon.transform = CGAffineTransform(rotationAngle: CGFloat(radians(45)))
				icon.icon = Asset.attachFile.image
				icon.iconWidth = 15
			} else {
				icon.transform = CGAffineTransform(rotationAngle: CGFloat(radians(0)))
				icon.icon = Asset.gif.image
				icon.iconWidth = 20
			}
		}

		let touchUpInside = control.signal(for: .touchUpInside)

		bag += touchUpInside.feedback(type: .impactLight)

		bag += control.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
			control.backgroundColor = UIColor.brand(.primaryBackground()).darkened(amount: 0.1)
		}

		bag += merge(touchUpInside, control.signal(for: .touchCancel), control.signal(for: .touchUpOutside))
			.animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
				control.backgroundColor = .brand(.primaryBackground())
			}

		return (
			control,
			Signal { callback in bag += touchUpInside.onValue(callback)
				return bag
			}
		)
	}
}
