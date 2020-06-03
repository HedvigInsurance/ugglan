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

    func isValid(text _: String, type _: MaskType) -> String {
        return ""
    }

    func maskValue(text: String, type: MaskType, oldText: String) -> String {
        switch type {
        case .personalNumber:
            if text.count <= 11 {
                let sanitizedString = text.replacingOccurrences(of: "-", with: "")

                if sanitizedString.range(of: "^[0-9]{6}", options: .regularExpression) != nil {
                    print(oldText, text)
                    if oldText.count >= text.count, oldText.last == "-" {
                        return String(text.dropLast())
                    } else {
                        var formattedString = sanitizedString
                        formattedString.insert("-", at: sanitizedString.index(sanitizedString.startIndex, offsetBy: 6))
                        return formattedString
                    }
                }

                return sanitizedString
            } else {
                return oldText
            }
        default:
            return text
        }
    }
}
