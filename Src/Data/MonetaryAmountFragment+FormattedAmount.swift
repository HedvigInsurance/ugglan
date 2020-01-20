//
//  MonetaryAmountFragment+FormattedAmount.swift
//  production
//
//  Created by Sam Pettersson on 2020-01-15.
//

import Foundation

extension MonetaryAmountFragment {
    /// returns the amount formatted for displaying it to users, for example 100 kr.
    var formattedAmount: String {
        switch currency {
        case "SEK":
            if let floatValue = Float(amount) {
                return "\(Int(floatValue)) kr"
            }
        default:
            return "\(amount) \(currency)"
        }
        
        return "\(amount) \(currency)"
    }
}
