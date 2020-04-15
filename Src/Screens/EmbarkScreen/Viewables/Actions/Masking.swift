//
//  Masking.swift
//  Ugglan
//
//  Created by Axel Backlund on 2020-02-28.
//

import Foundation

enum MaskType: String {
    case personalNumber = "PersonalNumber"
    case postalCode = "PostalCode"
    case email = "Email"
}

struct Masking {
    func getRegexFor(maskType: MaskType) -> String {
        switch maskType {
        case .personalNumber:
            return ""
        default:
            return ""
        }
    }
    
    func isValid(text: String, type: MaskType) -> String {
        return ""
    }
    
    func maskValue(text: String, type: MaskType, removedChar: String) -> String {
        switch type {
        case .personalNumber:
            if text.range(of: "^[0-9]{6}", options: .regularExpression) != nil {
                let formattedText = removedChar == "-" ? text.dropLast() : text + "-"
                return text + "-"
            }
            return ""
        default:
            return text
        }
    }
}
