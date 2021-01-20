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
    
    public func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let gradientView = UIView()
        gradientView.isUserInteractionEnabled = false
        
        let orbContainerView = UIView()
        orbContainerView.backgroundColor = .clear
        gradientView.addSubview(orbContainerView)
        orbContainerView.snp.makeConstraints { make in
            make.height.width.equalTo(gradientView.snp.height)
            make.centerX.equalTo(gradientView.snp.trailing)
            make.centerY.equalTo(gradientView.snp.bottom)
        }
        
        bag += $shouldShowGradient.atOnce().onValueDisposePrevious({ (shouldShow) -> Disposable? in
            
            let innerBag = DisposeBag()
            
            let layer = gradientLayer
            
            if shouldShow {
                
                gradientView.layer.addSublayer(layer)
                
                if let orbLayer = orbLayer {
                    gradientView.bringSubviewToFront(orbContainerView)
                    orbContainerView.layer.addSublayer(orbLayer)
                }
    
                innerBag += gradientView.didLayoutSignal.onValue {
                    layer.bounds = gradientView.layer.bounds
                    layer.frame = gradientView.layer.frame
                    layer.position = gradientView.layer.position
                    orbLayer?.frame = orbContainerView.bounds
                    orbLayer?.cornerRadius = orbContainerView.bounds.width / 2
                }
                
                innerBag += {
                    layer.removeFromSuperlayer()
                    orbLayer?.removeFromSuperlayer()
                }
            }
            
            return innerBag
        })
        
        return (gradientView, bag)
    }
}
