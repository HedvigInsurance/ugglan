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
        
        var colors: [UIColor] {
            switch self {
            case .blue:
                return [
                    UIColor(dynamic: { trait -> UIColor in
                        if trait.userInterfaceStyle == .dark {
                            return UIColor(red: 0.863, green: 0.871, blue: 0.961, alpha: 1)
                        }
                        
                        return UIColor(red: 0.745, green: 0.608, blue: 0.953, alpha: 0.55)
                    }),
                    UIColor(dynamic: { trait -> UIColor in
                        if trait.userInterfaceStyle == .dark {
                            return UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 0)
                        }
                        
                        return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 0)
                    })
                ]
            case .orange:
                return [
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.863, green: 0.871, blue: 0.961, alpha: 1)
                    }
                    
                    return UIColor(red: 0.98, green: 0.93, blue: 0.87, alpha: 1.00)
                }),
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 0)
                    }
                    
                    return UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 0)
                })
                ]
            }
        }
    }
    
    public static let currentOption = ReadWriteSignal<Option>(.blue).distinct()
}
