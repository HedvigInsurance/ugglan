import Flow
import SwiftUI
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
    func createAnimation<T>(for keyPath: KeyPath<CAGradientLayer, T>, from: T, to: T) -> CABasicAnimation {
        let stringKeyPath = keyPath._kvcKeyPathString

        let animation = CABasicAnimation(keyPath: stringKeyPath)
        animation.fromValue = from
        animation.toValue = to
        animation.fillMode = .forwards
        animation.duration = 2

        return animation
    }

    func applySettings(_ layer: CAGradientLayer, _ traitCollection: UITraitCollection) {
        if let gradientOption = gradientOption {
            layer.locations = gradientOption.locations
            layer.startPoint = gradientOption.startPoint
            layer.endPoint = gradientOption.endPoint
            layer.transform = gradientOption.transform
            layer.colors = gradientOption.backgroundColors(traitCollection: traitCollection)
                .map { $0.cgColor }
        }
    }

    func applySettingsWithAnimation(_ layer: CAGradientLayer, _ traitCollection: UITraitCollection) {
        if let gradientOption = gradientOption {
            let groupAnimation = CAAnimationGroup()
            groupAnimation.duration = 2

            let locationsAnimation = createAnimation(
                for: \.locations,
                from: layer.locations,
                to: gradientOption.locations
            )
            let startPointAnimation = createAnimation(
                for: \.startPoint,
                from: layer.startPoint,
                to: gradientOption.startPoint
            )
            let endPointAnimation = createAnimation(
                for: \.endPoint,
                from: layer.endPoint,
                to: gradientOption.endPoint
            )
            let transformAnimation = createAnimation(
                for: \.transform,
                from: layer.transform,
                to: gradientOption.transform
            )

            let colors = gradientOption.backgroundColors(traitCollection: traitCollection)
                .map { $0.cgColor }

            let colorsAnimation = createAnimation(for: \.colors, from: layer.colors, to: colors)

            groupAnimation.animations = [
                locationsAnimation,
                startPointAnimation,
                endPointAnimation,
                transformAnimation,
                colorsAnimation,
            ]

            applySettings(layer, traitCollection)

            layer.add(groupAnimation, forKey: "groupLayerAnimation")
        }
    }

    func createShimmerLayer() -> CAGradientLayer {
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

        let orbLayer = CAGradientLayer()
        orbContainerView.layer.addSublayer(orbLayer)
        gradientView.bringSubviewToFront(orbContainerView)

        let shimmerLayer = self.createShimmerLayer()
        shimmerView.layer.addSublayer(shimmerLayer)
        gradientView.bringSubviewToFront(shimmerView)

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
            orbLayer.frame = orbContainerView.bounds
            orbLayer.cornerRadius = orbContainerView.bounds.width / 2

            shimmerLayer.frame = shimmerView.frame
            shimmerLayer.bounds = shimmerView.bounds.insetBy(
                dx: -0.5 * shimmerView.bounds.size.width,
                dy: -0.5 * shimmerView.bounds.size.height
            )
            CATransaction.commit()
        }

        bag += gradientView.didMoveToWindowSignal.onValue({ _ in
            let signal = $gradientOption.atOnce().filter(predicate: { $0 != nil }).distinct()

            bag += signal.onFirstValue({ gradientOption in
                gradientOption?
                    .applySettings(
                        orbLayer: orbLayer,
                        traitCollection: gradientView.traitCollection
                    )
                applySettings(layer, gradientView.traitCollection)
            })

            bag += signal.skip(first: 1)
                .onValue({ gradientOption in
                    gradientOption?
                        .applySettings(
                            orbLayer: orbLayer,
                            traitCollection: gradientView.traitCollection
                        )
                    applySettingsWithAnimation(layer, gradientView.traitCollection)
                })
        })

        bag += gradientView.traitCollectionSignal
            .distinct({ lhs, rhs in
                lhs.userInterfaceStyle == rhs.userInterfaceStyle
            })
            .onValue({ traitCollection in
                gradientOption?
                    .applySettings(
                        orbLayer: orbLayer,
                        traitCollection: gradientView.traitCollection
                    )
                applySettings(layer, traitCollection)
            })

        gradientView.alpha = shouldShowGradient ? 1 : 0

        bag += $shouldShowGradient.animated(style: .easeOut(duration: 0.5)) { shoulShow in
            gradientView.alpha = shoulShow ? 1 : 0
        }

        bag += $shouldShowGradient.animated(mapStyle: { shouldShow in
            shouldShow
                ? SpringAnimationStyle.heavyBounce(delay: 0.1, duration: 2)
                : SpringAnimationStyle.lightBounce(duration: 0)
        }) { shoulShow in
            if shoulShow {
                shimmerView.transform = CGAffineTransform(
                    translationX: gradientView.frame.width
                        + (shimmerView.frame.width * 1.25),
                    y: 0
                )
            } else {
                shimmerView.transform = .identity
            }
        }

        return (gradientView, bag)
    }
}

public struct hGradientView: UIViewRepresentable {
    public var gradientOption: GradientView.GradientOption?
    public var shouldShowGradient = false

    public init(
        gradientOption: GradientView.GradientOption?,
        shouldShowGradient: Bool
    ) {
        self.gradientOption = gradientOption
        self.shouldShowGradient = shouldShowGradient
    }

    public class Coordinator {
        let bag = DisposeBag()
        let gradientView: GradientView

        init(
            gradientView: GradientView
        ) {
            self.gradientView = gradientView
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            gradientView: GradientView(
                gradientOption: self.gradientOption,
                shouldShowGradientSignal: .init(self.shouldShowGradient)
            )
        )
    }

    func update(context: Context) {
        context.coordinator.gradientView.$shouldShowGradient.value = self.shouldShowGradient
        context.coordinator.gradientView.$gradientOption.value = self.gradientOption
    }

    public func makeUIView(context: Context) -> some UIView {
        let (view, disposable) = context.coordinator.gradientView.materialize(
            events: ViewableEvents(wasAddedCallbacker: .init())
        )
        update(context: context)
        context.coordinator.bag += disposable
        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        update(context: context)
    }
}
