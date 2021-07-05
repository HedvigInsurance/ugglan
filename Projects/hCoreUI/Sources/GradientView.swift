import Flow
import UIKit
import hCore

public struct GradientView {
	public init(
		gradientOption: GradientOption?,
		shouldShowGradientSignal: ReadWriteSignal<Bool>
	) {
		self.gradientOption = gradientOption
		_shouldShowGradient = .init(wrappedValue: shouldShowGradientSignal)
	}

    @ReadWriteState public var gradientOption: GradientOption?
	@ReadWriteState public var shouldShowGradient = false
}

extension GradientView: Viewable {
	func applySettings(_ layer: CAGradientLayer, _ traitCollection: UITraitCollection) {
        if let gradientOption = gradientOption {
            layer.locations = gradientOption.locations
            layer.startPoint = gradientOption.startPoint
            layer.endPoint = gradientOption.endPoint
            layer.transform = gradientOption.transform
            layer.colors = gradientOption.backgroundColors(traitCollection: traitCollection).map { $0.cgColor }
        }
	}

	var shimmerLayer: CAGradientLayer {
		let layer = CAGradientLayer()
		layer.isHidden = !(self.gradientOption?.shouldShimmer ?? false)
		layer.colors = [
			UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor,
			UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor,
			UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor,
		]
		layer.locations = [0, 0.5, 1]
		layer.startPoint = CGPoint(x: 0.25, y: 0.5)
		layer.endPoint = CGPoint(x: 0.75, y: 0.5)
		let angle = 15 * CGFloat.pi / 100
		layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
		return layer
	}

	public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
		let bag = DisposeBag()

		let gradientView = UIView()
		gradientView.isUserInteractionEnabled = false

		let orbContainerView = UIView()
		orbContainerView.backgroundColor = .clear
		orbContainerView.isUserInteractionEnabled = false

		gradientView.addSubview(orbContainerView)
		orbContainerView.snp.makeConstraints { make in
			make.height.width.equalTo(200)
			make.centerX.equalTo(gradientView.snp.trailing)
			make.centerY.equalTo(gradientView.snp.bottom)
		}

		let shimmerView = UIView()
		shimmerView.isUserInteractionEnabled = false
		shimmerView.backgroundColor = .clear
		gradientView.addSubview(shimmerView)

		shimmerView.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(-40)
			make.bottom.equalToSuperview().offset(40)
			make.centerX.equalTo(gradientView.snp.leading)
			make.width.equalTo(100)
		}

        let layer = CAGradientLayer()
        layer.masksToBounds = true
		gradientView.layer.addSublayer(layer)

		bag += gradientView.didLayoutSignal.onValue { _ in
			CATransaction.begin()
			if let animation = gradientView.layer.animation(forKey: "position") {
				CATransaction.setAnimationDuration(animation.duration)
				CATransaction.setAnimationTimingFunction(animation.timingFunction)
			} else {
				CATransaction.disableActions()
			}
			layer.bounds = gradientView.layer.bounds
			layer.frame = gradientView.layer.frame
			layer.position = gradientView.layer.position
			CATransaction.commit()
		}

		bag += combineLatest(
			$shouldShowGradient.atOnce(),
			gradientView.traitCollectionSignal.atOnce(),
            $gradientOption.atOnce()
		)
		.onValueDisposePrevious { (shouldShow, traitCollection, _) -> Disposable? in
			let innerBag = DisposeBag()

			let animatedLayer = self.shimmerLayer
			applySettings(layer, traitCollection)

			if shouldShow, let gradientOption = gradientOption {
				shimmerView.layer.addSublayer(animatedLayer)

				let orbLayer = gradientOption.orbLayer(traitCollection: traitCollection)
				orbContainerView.layer.addSublayer(orbLayer)
				gradientView.bringSubviewToFront(orbContainerView)
				gradientView.bringSubviewToFront(shimmerView)

				orbLayer.frame = orbContainerView.bounds
				orbLayer.cornerRadius = orbContainerView.bounds.width / 2

				animatedLayer.frame = shimmerView.frame
				animatedLayer.bounds = shimmerView.bounds.insetBy(
					dx: -0.5 * shimmerView.bounds.size.width,
					dy: -0.5 * shimmerView.bounds.size.height
				)

				innerBag += shimmerView.didLayoutSignal.delay(by: 0.1)
					.animated(
						style: .easeOut(duration: 0.5),
						animations: {
							shimmerView.transform = CGAffineTransform(
								translationX: gradientView.frame.width
									+ shimmerView.frame.width,
								y: 0
							)
						}
					)

				func remove() {
					orbLayer.removeFromSuperlayer()
					animatedLayer.removeFromSuperlayer()
					shimmerView.transform = .identity
				}

				if gradientOption.shouldAnimate {
					let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
					fadeInAnimation.fromValue = 0
					fadeInAnimation.toValue = 1
					fadeInAnimation.duration = 0.25
					fadeInAnimation.fillMode = .forwards

					layer.add(fadeInAnimation, forKey: "fadeInAnimation")

					innerBag += {
						CATransaction.begin()

						let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
						fadeOutAnimation.fromValue = 1
						fadeOutAnimation.toValue = 0
						fadeOutAnimation.duration = 0.25
						fadeOutAnimation.fillMode = .forwards

						layer.opacity = 0

						CATransaction.setCompletionBlock {
							remove()
						}

						layer.add(fadeOutAnimation, forKey: "fadeOutAnimation")

						CATransaction.commit()
					}
				} else {
					innerBag += remove
				}
			}

			return innerBag
		}

		return (gradientView, bag)
	}
}
