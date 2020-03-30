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

extension HedvigColor: Decodable {}

extension UIColor {
    static var primaryBackground: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .almostBlack : .offWhite
        })
    }

    static var secondaryBackground: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? UIColor.almostBlack.lighter(amount: 0.10) : .white
        })
    }

    static var primaryText: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .white : .black
        })
    }

    static var primaryTextNeg: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .black : .white
        })
    }

    static let primaryTextMuted: UIColor = UIColor(dynamic: { trait -> UIColor in
        trait.userInterfaceStyle == .dark ? .lightGray : .darkGray
    })

    static var secondaryText: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .white : .offBlack
        })
    }

    static var tertiaryText: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .lightGray : .darkGray
        })
    }

    static var tertiaryBackground: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .lightGray : .darkGray
        })
    }

    static var regularBody: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .lightGray : .darkestGray
        })
    }

    static var decorText: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .offLightGray : .gray
        })
    }

    static var disabledTintColor: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .darkGray : .offBlack
        })
    }

    static var attentionTintColor: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .coral700 : .pink
        })
    }

    static var navigationItemMutedTintColor: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .white : .darkGray
        })
    }

    static var primaryShadowColor: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .transparent : .darkGray
        })
    }

    static var regularCaution: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .coral500 : .coral500
        })
    }
    
    static var boxSecondaryBackground: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .lighterPurple : .darkerPurple
        })
    }
    
    static var boxPrimaryBackground: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .darkerGray : .lighterGray
        })
    }
    
    static var tertiarySecondaryBackground: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .lighterBlack : .offWhite
        })
    }

    static let linksRegular = UIColor.primaryTintColor

    static let violet100 = UIColor(red: 239.0 / 255.0, green: 232.0 / 255.0, blue: 1.0, alpha: 1.0)
    static let violet200 = UIColor(red: 193.0 / 255.0, green: 165.0 / 255.0, blue: 1.0, alpha: 1.0)
    static let violet500 = UIColor(red: 101.0 / 255.0, green: 30.0 / 255.0, blue: 162.0, alpha: 1.0)
    static let coral700 = UIColor(red: 0.80, green: 0.43, blue: 0.40, alpha: 1.0)
    static let coral500 = UIColor(red: 255.0 / 255.0, green: 138.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
    static let midnight700 = UIColor(red: 12.0 / 255.0, green: 0.0, blue: 97.0 / 255.0, alpha: 1.0)
    static let midnight500 = UIColor(red: 15.0 / 255.0, green: 0.0, blue: 122.0 / 255.0, alpha: 1.0)
    static let transparent = UIColor.white.withAlphaComponent(0)
    static let white = UIColor.white
    static let black = UIColor.black
    static let almostBlack = UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1.0)
    static let turquoise = UIColor(red: 0.11, green: 0.91, blue: 0.71, alpha: 1.0)
    static let purple = UIColor(red: 0.40, green: 0.12, blue: 1.00, alpha: 1.0)
    static let blackPurple = UIColor(red: 0.03, green: 0.02, blue: 0.27, alpha: 1.0)
    static let darkPurple = UIColor(red: 0.06, green: 0.00, blue: 0.48, alpha: 1.0)
    static let lighterBlack = UIColor(red: 27.0 / 255.0, green: 27.0 / 255.0, blue: 27.0 / 255.0, alpha: 1.0)
    static let lighterPurple = UIColor(red: 201.0 / 255.0, green: 171.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
    static let darkerPurple = UIColor(red: 190.0 / 255.0, green: 155.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
    static let darkestGray = UIColor(red: 0.34, green: 0.34, blue: 0.34, alpha: 1.0)
    static let darkerGray = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    static let darkGray = UIColor(red: 0.61, green: 0.61, blue: 0.67, alpha: 1.0)
    static let lightGray = UIColor(red: 0.91, green: 0.93, blue: 0.94, alpha: 1.0)
    static let lighterGray = UIColor(red: 234.0 / 255.0, green: 234.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0)
    static let offLightGray = UIColor(red: 0.89, green: 0.90, blue: 0.92, alpha: 1.0)
    static let offBlack = UIColor(red: 0.25, green: 0.25, blue: 0.31, alpha: 1.0)
    static let offWhite = UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
    static let darkGreen = UIColor(red: 0, green: 0.57, blue: 0.46, alpha: 1.0)
    static let pink = UIColor(red: 1.00, green: 0.54, blue: 0.50, alpha: 1.0)
    static let darkPink = UIColor(red: 0.67, green: 0.0, blue: 0.27, alpha: 1.0)
    static let yellow = UIColor(red: 1.00, green: 0.80, blue: 0.30, alpha: 1.0)
    static let grass500 = UIColor(red: 0.0, green: 0.56, blue: 0.45, alpha: 1.0)
    static let sunflower300 = UIColor(red: 251.0 / 255.0, green: 227.0 / 255.0, blue: 86.0 / 255.0, alpha: 1.0)
    static let grass700 = UIColor(red: 0.0, green: 113.0 / 255.0, blue: 91.0 / 255.0, alpha: 1.0)
    static let coral200 = UIColor(red: 1.0, green: 208.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
    static let violet300 = UIColor(red: 0.58, green: 0.38, blue: 1.00, alpha: 1.0)

    static var primaryTintColor: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .violet300 : .purple
        })
    }

    static var secondaryTintColor: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .violet200 : .violet100
        })
    }

    static var primaryBorder: UIColor {
        UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .darkGrayBorder : .grayBorder
        })
    }

    static let darkGrayBorder = UIColor.darkGray.withAlphaComponent(0.3)
    static let grayBorder = UIColor.darkGray.lighter(amount: 0.15).withAlphaComponent(0.3)

    // swiftlint:disable cyclomatic_complexity
    static func from(apollo color: HedvigColor) -> UIColor {
        switch color {
        case .pink:
            return .pink
        case .black:
            return .black
        case .blackPurple:
            return .blackPurple
        case .offBlack:
            return .offBlack
        case .darkGray:
            return .darkGray
        case .turquoise:
            return .turquoise
        case .purple:
            return .purple
        case .lightGray:
            return .lightGray
        case .darkPurple:
            return .darkPurple
        case .white:
            return .white
        case .offWhite:
            return .offWhite
        case .yellow:
            return .yellow
        case .__unknown:
            return .white
        }
    }

    // swiftlint:enable cyclomatic_complexity
}
