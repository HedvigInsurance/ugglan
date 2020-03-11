//
//  HedvigColor+Apollo.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2020-03-11.
//

import Foundation
import Space
import ComponentKit
import UIKit

extension UIColor {
    // swiftlint:disable cyclomatic_complexity
    static func from(apollo color: HedvigColor) -> UIColor {
           switch color {
           case .pink:
               return .hedvig(.pink)
           case .black:
               return .hedvig(.black)
           case .blackPurple:
               return .hedvig(.blackPurple)
           case .offBlack:
               return .hedvig(.offBlack)
           case .darkGray:
               return .hedvig(.darkGray)
           case .turquoise:
               return .hedvig(.turquoise)
           case .purple:
               return .hedvig(.purple)
           case .lightGray:
                return .hedvig(.lightGray)
           case .darkPurple:
               return .hedvig(.darkPurple)
           case .white:
               return .hedvig(.white)
           case .offWhite:
               return .hedvig(.offWhite)
           case .yellow:
               return .hedvig(.yellow)
           case .__unknown:
               return .hedvig(.white)
           }
       }

       // swiftlint:enable cyclomatic_complexity
}
