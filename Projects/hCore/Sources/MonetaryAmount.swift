//
//  MonetaryAmount.swift
//  hCore
//
//  Created by sam on 8.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation

public protocol MonetaryAmount {
    var amount: String { get }
    var currency: String { get }
    /// amount parsed as a float
    var value: Float { get }
}

public extension MonetaryAmount {
    /// amount formatted according to currency specifications, ready to be displayed
     var formattedAmount: String {
        switch currency {
        case "SEK":
            if let floatValue = Float(amount) {
                return "\(Int(floatValue)) kr"
            }
        case "NOK":
            if let floatValue = Float(amount) {
                return "\(Int(floatValue)) kr"
            }
        default:
            return "\(amount) \(currency)"
        }

        return "\(amount) \(currency)"
    }
}

extension MonetaryAmount {
    public static func == (lhs: MonetaryAmount, rhs: MonetaryAmount) -> Bool {
        lhs.amount == rhs.amount
    }
}

extension Float: MonetaryAmount {
    public var amount: String {
        String(self)
    }
    
    public var value: Float {
        self
    }
    
    public var currency: String {
        ""
    }
}

extension Double: MonetaryAmount {
    public var amount: String {
        String(self)
    }
    
    public var value: Float {
        Float(self)
    }
    
    public var currency: String {
        ""
    }
}

extension MonetaryAmountFragment: MonetaryAmount {
    public var value: Float {
        if let floatValue = Float(amount) {
            return floatValue
        }
        
        return 0
    }
}
