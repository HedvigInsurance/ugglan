import Flow
import Foundation
import hCore
import UIKit

struct PickerButton: Viewable {
	let icon: UIImage

	func materialize(events _: ViewableEvents) -> (UIView, Signal<Void>) {
		let bag = DisposeBag()
		let button = UIControl()
		button.backgroundColor = .brand(.secondaryBackground())
		bag += button.applyBorderColor { _ in .brand(.primaryBorderColor) }
		button.layer.borderWidth = UIScreen.main.hairlineWidth
		button.layer.cornerRadius = 5

		let imageView = UIImageView()
		imageView.image = icon
		imageView.tintColor = .brand(.primaryText())

		button.addSubview(imageView)

		imageView.snp.makeConstraints { make in make.height.width.equalTo(45)
			make.center.equalToSuperview()
		}

		return (
			button,
			Signal<Void> { callback in bag += button.signal(for: .touchUpInside).onValue(callback)
				return bag
			}
		)
	}
}
