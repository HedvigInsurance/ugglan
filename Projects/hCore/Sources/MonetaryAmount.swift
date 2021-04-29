import Foundation
import hGraphQL

public struct MonetaryAmount: Equatable, Hashable, Codable {
    public init(amount: String, currency: String) {
        self.amount = amount
        self.currency = currency
    }

    public init(amount: Float, currency: String) {
        self.amount = String(amount)
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
    /// returns a MonetaryAmount where amount is converted to a negative amount
    var negative: Self {
        MonetaryAmount(amount: -value, currency: currency)
    }
}

public extension MonetaryAmount {
    var floatAmount: Float {
        if let floatValue = Float(amount) {
            return floatValue
        }
        
        return 0
    }
    
    /// locale for current currency
    var currencyLocale: Locale {
        switch currency {
        case "SEK":
            return Locale(identifier: "sv_SE")
        case "NOK":
            return Locale(identifier: "nb_NO")
        case "DKK":
            return Locale(identifier: "da_DK")
        default:
            return Localization.Locale.currentLocale.foundation
        }
    }
    
    /// symbol according to currency in MonetaryAmount
    var currencySymbol: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = currencyLocale
        return formatter.currencySymbol
    }
    
    /// amount formatted according to currency specifications, ready to be displayed
    var formattedAmountWithoutSymbol: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.currencySymbol = ""
        formatter.minimumFractionDigits = (value.truncatingRemainder(dividingBy: 1) != 0) ? 2 : 0
        formatter.maximumFractionDigits = 2
        formatter.locale = currencyLocale
        return formatter.string(from: NSNumber(value: floatAmount)) ?? ""
    }
    
    /// amount formatted according to currency specifications, ready to be displayed
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = (value.truncatingRemainder(dividingBy: 1) != 0) ? 2 : 0
        formatter.maximumFractionDigits = 2
        formatter.locale = currencyLocale
        return formatter.string(from: NSNumber(value: floatAmount)) ?? ""
    }
}

public extension GraphQL.MonetaryAmountFragment {
    var monetaryAmount: MonetaryAmount {
        .init(amount: amount, currency: currency)
    }
}
