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

public struct ContextGradient {
    public enum Option {
        case blue
        case orange
        
        public var barColor: UIColor {
            return colors.first!.withAlphaComponent(0.2)
        }
        
        public var colors: [UIColor] {
            switch self {
            case .blue:
                return [
                    UIColor(dynamic: { trait -> UIColor in
                        if trait.userInterfaceStyle == .dark {
                            return UIColor(red: 0.745, green: 0.608, blue: 0.953, alpha: 0.55)
                        }
                        
                        return UIColor(red: 0.745, green: 0.608, blue: 0.953, alpha: 0.55)
                    }),
                    UIColor(dynamic: { trait -> UIColor in
                        if trait.userInterfaceStyle == .dark {
                            return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0)
                        }
                        
                        return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0)
                    })
                ]
            case .orange:
                return [
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.988, green: 0.729, blue: 0.553, alpha: 1).darkened(amount: 0.1)
                    }
                    
                    return UIColor(red: 0.988, green: 0.729, blue: 0.553, alpha: 1)
                }),
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.988, green: 0.729, blue: 0.553, alpha: 0).darkened(amount: 0.1)
                    }
                    
                    return UIColor(red: 0.988, green: 0.729, blue: 0.553, alpha: 0)
                }),
                ]
            }
        }
    }
    
    public static let currentOption = ReadWriteSignal<Option>(.blue).distinct()
    
    public static func animateBarColor(_ view: UIView) -> Disposable {
        currentOption.atOnce().animated(style: .easeOut(duration: 1)) { option in
            view.backgroundColor = option.barColor
        }.nil()
    }
}
