//
//  GradientView.swift
//  hCoreUI
//
//  Created by Tarik Stafford on 2021-01-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//
import UIKit
import Flow
import hCore

public struct GradientView {
    public init(locations: [NSNumber], startPoint: CGPoint, endPoint: CGPoint, transform: CATransform3D, colors: [UIColor], orbLayer: CALayer? = nil) {
        self.locations = locations
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.transform = transform
        self.colors = colors
        self.orbLayer = orbLayer
    }
    
    public init(gradientOption: GradientOption, signal: ReadWriteSignal<Bool>) {
        self.locations = gradientOption.preset.locations
        self.startPoint = gradientOption.preset.startPoint
        self.endPoint = gradientOption.preset.endPoint
        self.transform = gradientOption.preset.transform
        self.colors = gradientOption.colors
        self.orbLayer = gradientOption.orbLayer
        self._shouldShowGradient = .init(wrappedValue: signal)
    }
    
    public var locations: [NSNumber]
    public var startPoint: CGPoint
    public var endPoint: CGPoint
    public var transform: CATransform3D
    public var colors: [UIColor]
    public var orbLayer: CALayer?
    
    @ReadWriteState public var shouldShowGradient = false
}

extension GradientView: Viewable {
    
    var gradientLayer: CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = colors.map({ $0.cgColor })
        layer.locations = locations
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        layer.transform = transform
        return layer
    }
    
    var shimmerLayer: CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor
          ]
        layer.locations = [0, 0.5, 1]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
        let angle = 15 * CGFloat.pi / 100
        layer.transform = CATransform3DMakeRotation(angle,0 ,0, 1)
        return layer
    }
    
    public func materialize(events: ViewableEvents) -> (UIView, Disposable) {
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
        
        bag += $shouldShowGradient.atOnce().onValueDisposePrevious({ (shouldShow) -> Disposable? in
            let innerBag = DisposeBag()

            let layer = gradientLayer
            let animatedLayer = self.shimmerLayer

            if shouldShow {
                
                let shimmerView = UIView()
                shimmerView.isUserInteractionEnabled = false
                shimmerView.backgroundColor = .clear
                gradientView.addSubview(shimmerView)
                
                shimmerView.snp.makeConstraints { (make) in
                    make.top.equalToSuperview().offset(-40)
                    make.bottom.equalToSuperview().offset(40)
                    make.centerX.equalTo(gradientView.snp.leading)
                    make.width.equalTo(100)
                }

                gradientView.layer.addSublayer(layer)
                shimmerView.layer.addSublayer(animatedLayer)

                if let orbLayer = orbLayer {
                    orbContainerView.layer.addSublayer(orbLayer)
                    gradientView.bringSubviewToFront(orbContainerView)
                    gradientView.bringSubviewToFront(shimmerView)
                }

                innerBag += gradientView.didLayoutSignal.onValue {
                    layer.bounds = gradientView.layer.bounds
                    layer.frame = gradientView.layer.frame
                    layer.position = gradientView.layer.position
                    orbLayer?.frame = orbContainerView.bounds
                    orbLayer?.cornerRadius = orbContainerView.bounds.width / 2
                    animatedLayer.frame = shimmerView.frame
                    animatedLayer.bounds = shimmerView.bounds.insetBy(
                        dx: -0.5 * shimmerView.bounds.size.width,
                        dy: -0.5 * shimmerView.bounds.size.height)
                    animatedLayer.position = shimmerView.layer.position
                }
                
                innerBag += shimmerView.didLayoutSignal.delay(by: 0.1).animated(style: .easeOut(duration: 0.5), animations: {
                    shimmerView.transform = CGAffineTransform(translationX: (gradientView.frame.width + shimmerView.frame.width), y: 0)
                })
                
                innerBag += {
                    layer.removeFromSuperlayer()
                    orbLayer?.removeFromSuperlayer()
                    shimmerView.removeFromSuperview()
                }
            }

            return innerBag
        })
        
        return (gradientView, bag)
    }
}
