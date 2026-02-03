import Foundation
import hGraphQL

public struct MonetaryAmount: Equatable, Hashable, Codable, Sendable {
    public init(
        amount: String,
        currency: String
    ) {
        self.amount = amount
        self.currency = currency
    }

    public init(
        amount: Float,
        currency: String
    ) {
        self.amount = String(amount)
        self.currency = currency
    }

    public init(
        fragment: OctopusGraphQL.MoneyFragment
    ) {
        amount = String(fragment.amount)
        currency = fragment.currencyCode.rawValue
    }

    public init?(
        optionalFragment: OctopusGraphQL.MoneyFragment?
    ) {
        guard let optionalFragment else { return nil }
        amount = String(optionalFragment.amount)
        currency = optionalFragment.currencyCode.rawValue
    }

    public var amount: String
    public var currency: String
}

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
        default:
            return Localization.Locale.currentLocale.value.foundation
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
        formatter.minimumFractionDigits = (value.truncatingRemainder(dividingBy: 1) != 0) ? 2 : 0
        formatter.maximumFractionDigits = 2
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
        let formattedString = formatter.string(from: NSNumber(value: alwaysNegativeAmount)) ?? ""
        return formattedString
    }

    public var formattedNegativeAmountPerMonth: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = (value.truncatingRemainder(dividingBy: 1) != 0) ? 2 : 0
        formatter.maximumFractionDigits = 2
        formatter.locale = currencyLocale
        let alwaysNegativeAmount = floatAmount < 0 ? floatAmount : -floatAmount
        let formattedString = formatter.string(from: NSNumber(value: alwaysNegativeAmount)) ?? ""
        return formattedString + L10n.perMonthShort
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

    public var formattedAmountPerMonth: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = (value.truncatingRemainder(dividingBy: 1) != 0) ? 2 : 0
        formatter.maximumFractionDigits = 2
        formatter.locale = currencyLocale
        let formattedString = formatter.string(from: NSNumber(value: floatAmount)) ?? ""
        return formattedString + L10n.perMonthShort
    }
}

extension String {
    public var addPerMonth: String {
        self + "/" + L10n.monthAbbreviationLabel
    }
}

extension MonetaryAmount {
    public static func + (lhs: MonetaryAmount, rhs: MonetaryAmount) -> MonetaryAmount {
        MonetaryAmount(amount: lhs.value + rhs.value, currency: lhs.currency)
    }

    public static func - (lhs: MonetaryAmount, rhs: MonetaryAmount) -> MonetaryAmount {
        MonetaryAmount(amount: lhs.value - rhs.value, currency: lhs.currency)
    }

    public static func zero(currency: String) -> MonetaryAmount {
        .init(amount: 0, currency: currency)
    }
}
