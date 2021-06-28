import Flow
import Foundation
import UIKit
import hCore

public struct LoadableButton {
	public let button: Button
	public let isLoadingSignal: ReadWriteSignal<Bool>
	public let onTapSignal: Signal<Void>
	private let onTapCallbacker = Callbacker<Void>()

	public func startLoading() { isLoadingSignal.value = true }

	public func stopLoading() { isLoadingSignal.value = false }

	public init(
		button: Button,
		initialLoadingState: Bool = false
	) {
		onTapSignal = onTapCallbacker.providedSignal
		self.button = button
		isLoadingSignal = ReadWriteSignal<Bool>(initialLoadingState)
	}
}

extension LoadableButton: Viewable {
	public func materialize(events: ViewableEvents) -> (UIButton, Disposable) {
		let bag = DisposeBag()
		let (buttonView, disposable) = button.materialize(events: events)

		bag += button.onTapSignal.withLatestFrom(isLoadingSignal.atOnce().plain()).filter { $1 == false }
			.onValue { _, _ in self.onTapCallbacker.callAll() }

		let spinner = UIActivityIndicatorView()
		buttonView.addSubview(spinner)

		bag += button.type.atOnce()
			.onValue { buttonType in
				if buttonType.backgroundColor.isContrasting(with: .white) {
					spinner.style = .white
					spinner.tintColor = .white
				} else {
					spinner.style = .gray
					spinner.tintColor = .gray
				}
			}

		spinner.snp.makeConstraints { make in make.width.equalToSuperview().multipliedBy(0.7)
			make.height.equalToSuperview().multipliedBy(0.7)
			make.center.equalToSuperview()
		}

		bag += buttonView.didLayoutSignal.onValue { _ in
			buttonView.titleLabel?.frame.size.width = buttonView.titleLabel?.intrinsicContentSize.width ?? 0
		}

		func setLoadingState(isLoading: Bool, animate: Bool) {
			func setButtonWidth() {
				buttonView.snp.updateConstraints { make in
					if isLoading {
						make.width.equalTo(self.button.type.value.height)
					} else {
						make.width.equalTo(
							buttonView.intrinsicContentSize.width
								+ self.button.type.value.extraWidthOffset
						)
					}
				}
			}

			func setLabelAlpha() { buttonView.titleLabel?.alpha = isLoading ? 0 : 1 }

			func setSpinnerAlpha() { spinner.alpha = isLoading ? 1 : 0 }

			if animate {
				let labelDelay = isLoading ? 0 : 0.25
				let layoutDelay = isLoading ? 0.25 : 0

				bag += Signal(after: labelDelay)
					.animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in setLabelAlpha()
					}

				bag += Signal(after: layoutDelay)
					.animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
						setSpinnerAlpha()
					}

				bag += Signal(after: layoutDelay)
					.animated(on: .main, style: AnimationStyle.easeOut(duration: 0.25)) { _ in
						setButtonWidth()
						buttonView.layoutIfNeeded()
						buttonView.layoutSuperviewsIfNeeded()
					}
			} else {
				setLabelAlpha()
				setSpinnerAlpha()

				DispatchQueue.main.async { setButtonWidth() }
			}

			if isLoading { spinner.startAnimating() } else { spinner.stopAnimating() }
		}

		bag += isLoadingSignal.onValue { isLoading in setLoadingState(isLoading: isLoading, animate: true) }

		bag += buttonView.didLayoutSignal.withLatestFrom(isLoadingSignal.atOnce().plain()).take(first: 1)
			.onValue { _, isLoading in setLoadingState(isLoading: isLoading, animate: false) }

		return (
			buttonView,
			Disposer {
				disposable.dispose()
				bag.dispose()
			}
		)
	}
}
