import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct EmbarkSelectActionOption {
	let state: EmbarkState
	let data: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction.SelectActionDatum.Option
	@ReadWriteState var isLoading = false
}

extension EmbarkSelectActionOption: Viewable {
	func materialize(events _: ViewableEvents) -> (UIControl, Signal<ActionResponseData>) {
		let bag = DisposeBag()
		let control = UIControl()
		control.backgroundColor = .brand(.secondaryBackground())
		control.layer.cornerRadius = 8
		bag += control.applyShadow { _ -> UIView.ShadowProperties in .embark }

		if data.keys.enumerated()
            .allSatisfy({ offset, key in !data.values[offset].isEmpty && state.store.getPrefillValue(key: key) == data.values[offset] })
		{
			control.layer.borderWidth = 2
			bag += control.applyBorderColor { _ in UIColor.tint(.lavenderOne) }
		}

		control.snp.makeConstraints { make in make.height.greaterThanOrEqualTo(80) }

		let stackView = UIStackView()
		stackView.isUserInteractionEnabled = false
		stackView.alignment = .center
		stackView.axis = .vertical
		stackView.spacing = 6
		stackView.layoutMargins = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
		stackView.isLayoutMarginsRelativeArrangement = true
		stackView.insetsLayoutMarginsFromSafeArea = false
		control.addSubview(stackView)

		stackView.snp.makeConstraints { make in make.top.bottom.trailing.leading.equalToSuperview() }

		bag += $isLoading.atOnce().filter(predicate: { $0 })
			.onValueDisposePrevious { _ in let overlayView = UIView()
				overlayView.alpha = 0
				overlayView.layer.cornerRadius = 8
				overlayView.backgroundColor = control.backgroundColor

				stackView.addSubview(overlayView)

				overlayView.snp.makeConstraints { make in make.edges.equalToSuperview() }

				let activityIndicator = UIActivityIndicatorView()
				activityIndicator.startAnimating()

				overlayView.addSubview(activityIndicator)

				activityIndicator.snp.makeConstraints { make in make.center.equalToSuperview() }

				let innerBag = DisposeBag()

				bag += { overlayView.removeFromSuperview() }

				innerBag += Animated.now.animated(style: .easeOut(duration: 0.25)) {
					overlayView.alpha = 1
				}

				return innerBag
			}

		return (
			control,
			Signal { callback in
				let valueLabel = MultilineLabel(
					value: data.link.fragments.embarkLinkFragment.label,
					style: TextStyle.brand(.headline(color: .primary)).centerAligned
				)

				bag += stackView.addArranged(valueLabel)

				bag += control.signal(for: .touchDown)
					.animated(style: SpringAnimationStyle.lightBounce()) { _ in
						control.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
					}

				bag += control.delayedTouchCancel(delay: 0.1)
					.animated(style: SpringAnimationStyle.lightBounce()) { _ in
						control.transform = CGAffineTransform.identity
					}

				bag += control.signal(for: .touchUpInside).feedback(type: .impactLight)

				bag += control.signal(for: .touchUpInside)
					.onValue { _ in
						let textValue = self.data.link.fragments.embarkLinkFragment.label
						callback(
							ActionResponseData(
								keys: self.data.keys,
								values: self.data.values,
								textValue: textValue
							)
						)
					}

				return bag
			}
		)
	}
}
