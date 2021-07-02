import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct CheckoutButton: Presentable {
	@ReadWriteState var isEnabled: Bool = false
	@ReadWriteState var isLoading: Bool = false

	private let onTapCallbacker = Callbacker<Void>()

	var onTapSignal: Signal<Void> {
		onTapCallbacker.providedSignal
	}

	func materialize() -> (UIView, Disposable) {
		let view = AccessoryBaseView()
		let bag = DisposeBag()

		let safeAreaWrapperView = UIView()
		view.addSubview(safeAreaWrapperView)

		safeAreaWrapperView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		let baseLayoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15)

		let containerView = UIStackView()
		containerView.isLayoutMarginsRelativeArrangement = true
		containerView.insetsLayoutMarginsFromSafeArea = true
		containerView.layoutMargins = baseLayoutMargins
		containerView.axis = .horizontal
		safeAreaWrapperView.addSubview(containerView)

		containerView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		let button = Button(
			title: L10n.offerSignButton,
			type: .standard(
				backgroundColor: .brand(.secondaryButtonBackgroundColor),
				textColor: .brand(.secondaryButtonTextColor)
			)
		)
		bag += $isEnabled.atOnce().bindTo(button.isEnabled)

		let loadableButton = LoadableButton(button: button)
		bag += $isLoading.atOnce().bindTo(loadableButton.isLoadingSignal)

		bag += loadableButton.onTapSignal.onValue { _ in
			onTapCallbacker.callAll()
		}

		bag += containerView.addArranged(
			loadableButton
		)

		bag += view.keyboardSignal(priority: .contentInsets)
			.onValue({ keyboard in
				guard let viewController = view.viewController else {
					return
				}

				let frameWidth = view.frame.width
				let viewControllerWidth = viewController.view.frame.width
				let halfWidth = (frameWidth - viewControllerWidth) / 2

				containerView.layoutMargins =
					baseLayoutMargins
					+ UIEdgeInsets(
						top: 0,
						left: halfWidth,
						bottom: view.safeAreaInsets.bottom == 0 ? 0 : 20,
						right: halfWidth
					)
			})

		return (view, bag)
	}
}
