import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI

struct MultiActionValueRow: Hashable, Equatable {
	let didTapRow = ReadWriteSignal<Bool>(false)
	let values: [String: MultiActionValue]
	let title: String
	let id = UUID()

	func hash(into hasher: inout Hasher) { hasher.combine(id) }

	static func == (lhs: MultiActionValueRow, rhs: MultiActionValueRow) -> Bool { lhs.id == rhs.id }
}

extension MultiActionValueRow: Reusable {
	static func makeAndConfigure() -> (make: UIView, configure: (MultiActionValueRow) -> Disposable) {
		let bag = DisposeBag()

		let view = UIView()
		view.backgroundColor = .clear

		let stylingView = UIView()
		bag += stylingView.applyShadow { _ in
			UIView.ShadowProperties(
				opacity: 0.05,
				offset: CGSize(width: 0, height: 6),
				blurRadius: 3,
				color: .brand(.primaryShadowColor),
				path: nil,
				radius: 8
			)
		}
		stylingView.layer.cornerRadius = 8
		stylingView.alpha = 0
		stylingView.backgroundColor = .brand(.embarkMessageBubble(false))

		view.addSubview(stylingView)
		stylingView.snp.makeConstraints { make in make.edges.equalToSuperview() }
		let title = UILabel(value: "", style: .brand(.body(color: .primary)))
		title.textAlignment = .center

		let values = UILabel(value: "", style: .brand(.footnote(color: .secondary)))
		values.textAlignment = .center
		values.numberOfLines = 0
		values.lineBreakMode = .byWordWrapping

		view.addSubview(title)
		view.addSubview(values)

		title.snp.makeConstraints { make in make.leading.trailing.equalTo(view).inset(16)
			make.bottom.equalTo(view.snp.centerY).inset(5)
		}

		values.snp.makeConstraints { make in make.leading.trailing.equalTo(view).inset(16)
			make.top.equalTo(view.snp.centerY).offset(5)
		}

		let button = UIButton()
		button.setImage(hCoreUIAssets.close.image, for: .normal)
		button.tintColor = .brand(.secondaryText)
		button.isUserInteractionEnabled = true

		view.addSubview(button)
		button.snp.makeConstraints { make in make.top.right.equalToSuperview().inset(8)
			make.height.width.equalTo(30)
		}

		return (
			view,
			{ `self` in title.text = self.title
				values.text = self.values.compactMap { _, value in value.displayValue }
					.filter { $0 != self.title }.joined(separator: " \u{00B7} ")

				bag += button.onValue { self.didTapRow.value = true }

				bag += view.didLayoutSignal.take(first: 1)
					.onValue { _ in view.transform = CGAffineTransform.identity
						view.transform = CGAffineTransform(translationX: 0, y: 40)
						view.alpha = 0

						bag += Signal(after: 0.4)
							.animated(
								style: .lightBounce(),
								animations: { _ in
									view.transform = CGAffineTransform.identity
									view.alpha = 1
									stylingView.alpha = 1
								}
							)
					}

				return bag
			}
		)
	}
}
