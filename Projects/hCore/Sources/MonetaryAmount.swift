//
//  MonetaryAmount.swift
//  hCore
//
//  Created by sam on 8.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation

public struct MonetaryAmount: Equatable, Hashable, Codable {
    public init(amount: String, currency: String) {
        self.amount = amount
        self.currency = currency
    }
    
    public var amount: String
    public var currency: String
    /// amount parsed as a float
    public var value: Float {
        if let floatValue = Float(amount) {
            return floatValue
        }
        
        return 0
    }
    
    public static func sek(_ value: Float) -> Self {
        self.init(amount: String(value), currency: "SEK")
    }
}

public extension MonetaryAmount {
    /// amount formatted according to currency specifications, ready to be displayed
     var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = (value.truncatingRemainder(dividingBy: 1) != 0) ? 2 : 0
        formatter.maximumFractionDigits = 2
        
        switch currency {
        case "SEK":
            if let floatValue = Float(amount) {
                formatter.locale = Locale(identifier: "sv_SE")
                return formatter.string(from: NSNumber(value: floatValue)) ?? ""
            }
        case "NOK":
            if let floatValue = Float(amount) {
                formatter.locale = Locale(identifier: "nb_NO")
                return formatter.string(from: NSNumber(value: floatValue)) ?? ""
            }
        default:
            if let floatValue = Float(amount) {
                return formatter.string(from: NSNumber(value: floatValue)) ?? ""
            }
        }

        return "\(amount) \(currency)"
    }
}
extension MonetaryAmountFragment {
    public var monetaryAmount: MonetaryAmount {
        .init(amount: amount, currency: currency)
    }
}
