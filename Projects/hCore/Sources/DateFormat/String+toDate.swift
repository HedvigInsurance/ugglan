import Foundation

extension String {
    public var localDateToDate: Date? {
        return DateFormatters.localDateStringFormatter.date(from: self)
    }

    public var localDateToIso8601Date: Date? {
        return DateFormatters.localDateToIso8601Date.date(from: self)
    }

    public var localBirthDateStringToDate: Date? {
        if self == "" {
            return nil
        }
        return DateFormatters.localbirthDateStringFormatter.date(from: self)
    }
}
