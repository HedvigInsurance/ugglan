import Foundation

extension Date {
    public var localDateString: String {
        return DateFormatters.localDateStringFormatter.string(from: self)
    }

    public var localBirthDateString: String {
        return DateFormatters.localbirthDateStringFormatter.string(from: self)
    }

    public var displayDateDDMMMFormat: String {
        return DateFormatters.displayddMMM.string(from: self)
    }

    public var dateYYYYFormat: String? {
        return DateFormatters.YYYYFormat.string(from: self)
    }

    public func daysBetween(start: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: self).day!
    }

    public var displayDateDDMMMYYYYFormat: String? {
        return DateFormatters.displayddMMMyyyy.string(from: self).lowercased()
    }
}

public struct DateFormatters {
    static let localDateStringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let localbirthDateStringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        return formatter
    }()

    static let displayddMMM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter
    }()

    static let YYYYFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    static let displayddMMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    static let localDateToIso8601Date: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()

        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = .current
        return formatter
    }()
}
