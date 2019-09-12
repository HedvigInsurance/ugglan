//
//  UIKeyboardType+Apollo.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-12.
//

import Foundation
import Apollo
import UIKit

extension UIKeyboardType {
    static func from(_ keyboardType: KeyboardType?) -> UIKeyboardType? {
        guard let keyboardType = keyboardType else {
            return nil
        }
        
        switch keyboardType {
        case .default:
            return .default
        case .email:
            return .emailAddress
        case .decimalpad:
            return .decimalPad
        case .numberpad:
            return .numberPad
        case .numeric:
            return .numeric
        case .phone:
            return .phonePad
        case .__unknown(_):
            return .default
        }
    }
}
