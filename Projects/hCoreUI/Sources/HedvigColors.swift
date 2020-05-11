//
//  HedvigColors.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-07.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import DynamicColor
import hCore

public extension UIColor {
    private struct BrandColorBase {
        static let almostBlack = UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1.0)
        static let offWhite = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
        static let offBlack = UIColor(red: 0.25, green: 0.25, blue: 0.31, alpha: 1.0)
        static let white = UIColor.white
        static let black = UIColor.black
        static let transparent = UIColor.clear
        static let darkGray = UIColor(red: 0.61, green: 0.61, blue: 0.67, alpha: 1.0)
        static let lightGray = UIColor(red: 0.91, green: 0.93, blue: 0.94, alpha: 1.0)
        static let tertiaryText = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ?
                BrandColorBase.lightGray :
                BrandColorBase.darkGray
        })
        static let primaryTextMuted = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ?
                BrandColorBase.lightGray :
                BrandColorBase.darkGray
        })
        static let secondaryText = UIColor(dynamic: { trait -> UIColor in
                   trait.userInterfaceStyle == .dark ?
                    BrandColorBase.white :
                    BrandColorBase.offBlack
        })
        static let lavender = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.75, green: 0.61, blue: 0.95, alpha: 1.00) :
                UIColor(red: 0.79, green: 0.67, blue: 0.96, alpha: 1.00)
        })
        static let coral500 = UIColor(
            red: 255.0 / 255.0,
            green: 138.0 / 255.0,
            blue: 128.0 / 255.0,
            alpha: 1.0
        )
        static var primaryBorder: UIColor = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? BrandColorBase.darkGrayBorder : BrandColorBase.grayBorder
        })
        static let darkGrayBorder = BrandColorBase.darkGray.withAlphaComponent(0.3)
        static let grayBorder = BrandColorBase.darkGray.lighter(amount: 0.15).withAlphaComponent(0.3)
    }
    
    enum BrandColor {
        case primaryBackground(_ negative: Bool = false)
        case secondaryBackground(_ negative: Bool = false)
        case primaryText(_ negative: Bool = false)
        case primaryTextMuted
        case secondaryText
        case tertiaryText
        case primaryTintColor
        case primaryButtonBackgroundColor
        case primaryButtonTextColor
        case primaryShadowColor
        case regularCaution
        case primaryBorderColor
        
        var color: UIColor {
            switch self {
            case let .primaryBackground(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        trait.userInterfaceStyle == .dark ? BrandColorBase.offWhite : BrandColorBase.almostBlack
                    })
                }
                
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBase.almostBlack : BrandColorBase.offWhite
                })
            case let .secondaryBackground(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        trait.userInterfaceStyle == .dark ? BrandColorBase.almostBlack.lighter(amount: 0.10) : BrandColorBase.white
                    })
                }
                
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBase.white : BrandColorBase.almostBlack.lighter(amount: 0.10)
                })
            case let .primaryText(negative):
                if negative {
                    return UIColor(dynamic: { trait -> UIColor in
                        trait.userInterfaceStyle == .dark ? BrandColorBase.black : BrandColorBase.white
                    })
                }
                
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBase.white : BrandColorBase.black
                })
            case .secondaryText:
                return BrandColorBase.secondaryText
            case .primaryTintColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? BrandColorBase.white : BrandColorBase.black
                })
            case .primaryButtonBackgroundColor:
                return BrandColorBase.lavender
            case .primaryButtonTextColor:
                return BrandColorBase.black
            case .primaryShadowColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ?
                        BrandColorBase.transparent :
                        BrandColorBase.darkGray
                })
            case .tertiaryText:
                return BrandColorBase.tertiaryText
            case .primaryTextMuted:
                return BrandColorBase.primaryTextMuted
            case .regularCaution:
                return BrandColorBase.coral500
            case .primaryBorderColor:
                return BrandColorBase.primaryBorder
            }
        }
    }
    
    static func brand(_ color: BrandColor) -> UIColor {
        return color.color
    }
}

