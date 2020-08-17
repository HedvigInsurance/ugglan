//
//  ContextGradient.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2020-08-12.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import UIKit
import hCore

public struct ContextGradient {
    public enum Option {
        case home
        case insurance
        case forever
        case profile
        
        public func tabBarColor(for traitCollection: UITraitCollection) -> UIColor {
            return colors(for: traitCollection).last!.withAlphaComponent(0.2)
        }
        
        public func navigationBarColor(for traitCollection: UITraitCollection) -> UIColor {
            return colors(for: traitCollection).first!.withAlphaComponent(0.2)
        }
        
        public func locations(for traitCollection: UITraitCollection) -> [NSNumber] {
            switch self {
            case .home:
                if traitCollection.userInterfaceStyle == .dark {
                    return [
                        0,
                        0.52,
                        1
                    ]
                }
                
                return [
                    0,
                    0.49,
                    1
                ]
            case .insurance:
                if traitCollection.userInterfaceStyle == .dark {
                    return [
                        0,
                        0.51,
                        1
                    ]
                }
                
                return [
                    0,
                    1
                ]
            case .forever:
                if traitCollection.userInterfaceStyle == .dark {
                    return [
                        0,
                        1
                    ]
                }
                
                return [
                    0,
                    1
                ]
            case .profile:
                if traitCollection.userInterfaceStyle == .dark {
                    return [
                        0,
                        1
                    ]
                }
                
                return [
                    0,
                    1
                ]
            }
        }
        
        public func colors(for traitCollection: UITraitCollection) -> [UIColor] {
            switch self {
            case .home:
                if traitCollection.userInterfaceStyle == .dark {
                    return [
                        UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00),
                        UIColor(red: 0.11, green: 0.15, blue: 0.19, alpha: 1.00),
                        UIColor(red: 0.20, green: 0.13, blue: 0.12, alpha: 1.00)
                    ]
                }
                
                return [
                    UIColor(red: 0.75, green: 0.79, blue: 0.85, alpha: 1.00),
                    UIColor(red: 0.93, green: 0.80, blue: 0.67, alpha: 1.00),
                    UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
                ]
            case .insurance:
                if traitCollection.userInterfaceStyle == .dark {
                    return [
                        UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00),
                        UIColor(red: 0.04, green: 0.09, blue: 0.10, alpha: 1.00),
                        UIColor(red: 0.10, green: 0.18, blue: 0.20, alpha: 1.00)
                    ]
                }
                
                return [
                    UIColor(red: 0.95, green: 0.85, blue: 0.75, alpha: 1.00),
                    UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
                ]
            case .forever:
                if traitCollection.userInterfaceStyle == .dark {
                    return [
                        UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00),
                        UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00)
                    ]
                }
                
                return [
                    UIColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 1.00),
                    UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
                ]
            case .profile:
                if traitCollection.userInterfaceStyle == .dark {
                    return [
                        UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00),
                        UIColor(red: 0.12, green: 0.11, blue: 0.04, alpha: 1.00)
                    ]
                }
                
                return [
                    UIColor(red: 0.77, green: 0.87, blue: 0.93, alpha: 1.00),
                    UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
                ]
            }
        }
    }
        
    @ReadWriteState public static var currentOption: Option = .home
    
    public static func animateTabBarColor(_ view: UIView) -> Disposable {
        $currentOption.atOnce().animated(style: .easeOut(duration: 1)) { option in
            view.backgroundColor = option.tabBarColor(for: view.traitCollection)
        }.nil()
    }
    
    public static func animateNavigationBarColor(_ view: UIView) -> Disposable {
        $currentOption.atOnce().animated(style: .easeOut(duration: 1)) { option in
            view.backgroundColor = option.navigationBarColor(for: view.traitCollection)
        }.nil()
    }
}
