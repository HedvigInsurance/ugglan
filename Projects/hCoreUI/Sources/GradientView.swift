//
//  GradientView.swift
//  hCoreUI
//
//  Created by Tarik Stafford on 2021-01-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//
import Flow
import hCore
import UIKit

public struct GradientView {
    public init(gradientOption: GradientOption, shouldShowGradientSignal: ReadWriteSignal<Bool>) {
        self.gradientOption = gradientOption
        _shouldShowGradient = .init(wrappedValue: shouldShowGradientSignal)
    }

    public let gradientOption: GradientOption

    @ReadWriteState public var shouldShowGradient = false
}

extension GradientView: Viewable {
    public func gradientLayer(traitCollection: UITraitCollection) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = gradientOption.backgroundColors(traitCollection: traitCollection).map { $0.cgColor }
        layer.locations = gradientOption.locations
        layer.startPoint = gradientOption.startPoint
        layer.endPoint = gradientOption.endPoint
        layer.transform = gradientOption.transform
        return layer
    }

    var shimmerLayer: CAGradientLayer {
        let layer = CAGradientLayer()
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

        bag += combineLatest(
            $shouldShowGradient.atOnce(),
            gradientView.traitCollectionSignal.atOnce()
        )
        .onValueDisposePrevious { (shouldShow, traitCollection) -> Disposable? in

            let innerBag = DisposeBag()

            let layer = gradientLayer(traitCollection: traitCollection)
            let animatedLayer = self.shimmerLayer

            if shouldShow {
                gradientView.layer.addSublayer(layer)
                shimmerView.layer.addSublayer(animatedLayer)

                let orbLayer = gradientOption.orbLayer(traitCollection: traitCollection)
                orbContainerView.layer.addSublayer(orbLayer)
                gradientView.bringSubviewToFront(orbContainerView)
                gradientView.bringSubviewToFront(shimmerView)

                layer.bounds = gradientView.layer.bounds
                layer.frame = gradientView.layer.frame
                layer.position = gradientView.layer.position

                orbLayer.frame = orbContainerView.bounds
                orbLayer.cornerRadius = orbContainerView.bounds.width / 2

                animatedLayer.frame = shimmerView.frame
                animatedLayer.bounds = shimmerView.bounds.insetBy(
                    dx: -0.5 * shimmerView.bounds.size.width,
                    dy: -0.5 * shimmerView.bounds.size.height
                )

                innerBag += shimmerView.didLayoutSignal.delay(by: 0.1).animated(style: .easeOut(duration: 0.5), animations: {
                    shimmerView.transform = CGAffineTransform(translationX: gradientView.frame.width + shimmerView.frame.width, y: 0)
                })

                innerBag += {
                    layer.removeFromSuperlayer()
                    orbLayer.removeFromSuperlayer()
                    animatedLayer.removeFromSuperlayer()
                    shimmerView.transform = .identity
                }
            }

            return innerBag
        }

        return (gradientView, bag)
    }
}
