import Foundation
import hGraphQL

extension MonetaryAmount {
    /// returns a MonetaryAmount where amount is converted to a negative amount
    public var negative: Self {
        MonetaryAmount(amount: -value, currency: currency)
    }

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

extension MonetaryAmount {
    public var floatAmount: Float {
        if let floatValue = Float(amount) {
            return floatValue
        }

        return 0
    }

    /// locale for current currency
    public var currencyLocale: Locale {
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
    public var currencySymbol: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = currencyLocale
        return formatter.currencySymbol
    }

    /// amount formatted according to currency specifications, ready to be displayed
    public var formattedAmountWithoutSymbol: String {
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
    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = (value.truncatingRemainder(dividingBy: 1) != 0) ? 2 : 0
        formatter.maximumFractionDigits = 2
        formatter.locale = currencyLocale
        return formatter.string(from: NSNumber(value: floatAmount)) ?? ""
    }

    public var formattedNegativeAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = (value.truncatingRemainder(dividingBy: 1) != 0) ? 2 : 0
        formatter.maximumFractionDigits = 2
        formatter.locale = currencyLocale
        let alwaysNegativeAmount = floatAmount < 0 ? floatAmount : -floatAmount
        return formatter.string(from: NSNumber(value: alwaysNegativeAmount)) ?? ""
    }

    public var formattedAbsoluteAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = (value.truncatingRemainder(dividingBy: 1) != 0) ? 2 : 0
        formatter.maximumFractionDigits = 2
        formatter.locale = currencyLocale
        return formatter.string(from: NSNumber(value: abs(floatAmount))) ?? ""
    }

    public var formattedAmountWithoutDecimal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.locale = currencyLocale
        return formatter.string(from: NSNumber(value: floatAmount)) ?? ""
    }
}

extension GiraffeGraphQL.MonetaryAmountFragmentGiraffe {
    public var monetaryAmount: MonetaryAmount {
        .init(amount: amount, currency: currency)
    }
}

extension String {
    public var addPerMonth: String {
        return self + "/" + L10n.monthAbbreviationLabel
    }
}
