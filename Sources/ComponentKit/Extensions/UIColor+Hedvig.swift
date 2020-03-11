//
//  Colors.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-11.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import DynamicColor
import Foundation
import UIKit

public extension UIColor {
    static var hedvig = Hedvig.self
    
    static func hedvig(_ color: Hedvig) -> UIColor {
        return color.color
    }

    enum Hedvig {
        case primaryBackground
        case secondaryBackground
        case primaryText
        case primaryTextNeg
        case primaryTextMuted
        case secondaryText
        case tertiaryText
        case tertiaryBackground
        case regularBody
        case decorText
        case disabledTintColor
        case attentionTintColor
        case navigationItemMutedTintColor
        case primaryShadowColor
        case regularCaution
        case linksRegular
        case violet100
        case violet200
        case violet500
        case coral700
        case coral500
        case midnight700
        case midnight500
        case transparent
        case white
        case black
        case gray
        case almostBlack
        case turquoise
        case purple
        case blackPurple
        case darkPurple
        case darkerGray
        case darkGray
        case lightGray
        case offLightGray
        case offBlack
        case offWhite
        case darkGreen
        case pink
        case darkPink
        case yellow
        case grass500
        case sunflower300
        case grass700
        case coral200
        case violet300
        case primaryTintColor
        case secondaryTintColor
        case primaryBorder
        case darkGrayBorder
        case grayBorder
        
        var color: UIColor {
            switch self {
            case .primaryBackground:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.almostBlack) : .hedvig(.offWhite)
                })
            case .secondaryBackground:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? UIColor.hedvig(.almostBlack).lighter(amount: 0.10) : .hedvig(.white)
                })
            case .primaryText:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.white) : .hedvig(.black)
                })
            case .primaryTextNeg:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.black) : .hedvig(.white)
                })
            case .primaryTextMuted:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.lightGray) : .hedvig(.darkGray)
                })
            case .secondaryText:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.white) : .hedvig(.offBlack)
                })
            case .tertiaryText:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.lightGray) : .hedvig(.darkGray)
                })
            case .tertiaryBackground:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.lightGray) : .hedvig(.darkGray)
                })
            case .regularBody:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.lightGray) : .hedvig(.darkerGray)
                })
            case .decorText:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.offLightGray) : .hedvig(.gray)
                })
            case .disabledTintColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.darkGray) : .hedvig(.offBlack)
                })
            case .attentionTintColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.coral700) : .hedvig(.pink)
                })
            case .navigationItemMutedTintColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.white) : .hedvig(.darkGray)
                })
            case .primaryShadowColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.transparent) : .hedvig(.darkGray)
                })
            case .regularCaution:
                return .hedvig(.coral500)
            case .linksRegular:
                return .hedvig(.primaryTintColor)
            case .violet100:
                return UIColor(red: 239.0 / 255.0, green: 232.0 / 255.0, blue: 1.0, alpha: 1.0)
            case .violet200:
                return UIColor(red: 193.0 / 255.0, green: 165.0 / 255.0, blue: 1.0, alpha: 1.0)
            case .violet500:
                return UIColor(red: 101.0 / 255.0, green: 30.0 / 255.0, blue: 162.0, alpha: 1.0)
            case .coral700:
                return UIColor(red: 0.80, green: 0.43, blue: 0.40, alpha: 1.0)
            case .coral500:
                return UIColor(red: 255.0 / 255.0, green: 138.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
            case .midnight700:
                return UIColor(red: 12.0 / 255.0, green: 0.0, blue: 97.0 / 255.0, alpha: 1.0)
            case .midnight500:
                return UIColor(red: 15.0 / 255.0, green: 0.0, blue: 122.0 / 255.0, alpha: 1.0)
            case .transparent:
                return UIColor.white.withAlphaComponent(0)
            case .white:
                return UIColor.white
            case .black:
                return UIColor.black
            case .gray:
                return UIColor.gray
            case .almostBlack:
                return UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1.0)
            case .turquoise:
                return UIColor(red: 0.11, green: 0.91, blue: 0.71, alpha: 1.0)
            case .purple:
                return UIColor(red: 0.40, green: 0.12, blue: 1.00, alpha: 1.0)
            case .blackPurple:
                return UIColor(red: 0.03, green: 0.02, blue: 0.27, alpha: 1.0)
            case .darkPurple:
                return UIColor(red: 0.06, green: 0.00, blue: 0.48, alpha: 1.0)
            case .darkerGray:
                return UIColor(red: 0.34, green: 0.34, blue: 0.34, alpha: 1.0)
            case .darkGray:
                return UIColor(red: 0.61, green: 0.61, blue: 0.67, alpha: 1.0)
            case .lightGray:
                return UIColor(red: 0.91, green: 0.93, blue: 0.94, alpha: 1.0)
            case .offLightGray:
                return UIColor(red: 0.89, green: 0.90, blue: 0.92, alpha: 1.0)
            case .offBlack:
                return UIColor(red: 0.25, green: 0.25, blue: 0.31, alpha: 1.0)
            case .offWhite:
                return UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
            case .darkGreen:
                return UIColor(red: 0, green: 0.57, blue: 0.46, alpha: 1.0)
            case .pink:
                return UIColor(red: 1.00, green: 0.54, blue: 0.50, alpha: 1.0)
            case .darkPink:
                return UIColor(red: 1.00, green: 0.54, blue: 0.50, alpha: 1.0)
            case .yellow:
                return UIColor(red: 1.00, green: 0.80, blue: 0.30, alpha: 1.0)
            case .grass500:
                return UIColor(red: 0.0, green: 0.56, blue: 0.45, alpha: 1.0)
            case .sunflower300:
                return UIColor(red: 251.0 / 255.0, green: 227.0 / 255.0, blue: 86.0 / 255.0, alpha: 1.0)
            case .grass700:
                return UIColor(red: 0.0, green: 113.0 / 255.0, blue: 91.0 / 255.0, alpha: 1.0)
            case .coral200:
                return UIColor(red: 1.0, green: 208.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
            case .violet300:
                return UIColor(red: 0.58, green: 0.38, blue: 1.00, alpha: 1.0)
            case .primaryTintColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.violet300) : .hedvig(.purple)
                })
            case .secondaryTintColor:
                return UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.violet200) : .hedvig(.violet100)
                })
            case .primaryBorder:
                return  UIColor(dynamic: { trait -> UIColor in
                    trait.userInterfaceStyle == .dark ? .hedvig(.darkGrayBorder) : .hedvig(.grayBorder)
                           })
            case .darkGrayBorder:
                return UIColor.darkGray.withAlphaComponent(0.3)
            case .grayBorder:
                return UIColor.darkGray.lighter(amount: 0.15).withAlphaComponent(0.3)
            }
        }
    }
}
