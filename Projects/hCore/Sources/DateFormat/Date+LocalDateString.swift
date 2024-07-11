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

    public var displayDateMMMMDDYYYYFormat: String {
        return DateFormatters.displayMMMMddYYYY.string(from: self)
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

    public var displayDateDDMMMMYYYYFormat: String? {
        return DateFormatters.displayddMMMMyyyy.string(from: self).lowercased()
    }

    public var displayTimeStamp: String {
        let dateFormatter = DateFormatter()
        if !Calendar.current.isDateInWeek(from: self) {
            dateFormatter.dateFormat = "dd MMMM YYYY"
            return dateFormatter.string(from: self)
        } else if Calendar.current.isDateInToday(self) {
            dateFormatter.dateFormat = "HH:mm"
            return "\(L10n.generalToday) " + dateFormatter.string(from: self)
        } else if Calendar.current.isDateInYesterday(self) {
            dateFormatter.dateFormat = "HH:mm"
            return "\(L10n.generalYesterday) " + dateFormatter.string(from: self)
        } else {
            dateFormatter.dateFormat = "EEEE HH:mm"
            return dateFormatter.string(from: self)
        }
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

    static let displayMMMMddYYYY: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd YYYY"
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

    static let displayddMMMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()

    static let localDateToIso8601Date: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()

        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = .current
        return formatter
    }()
}

extension Calendar {
    /// returns a boolean indicating if provided date is in the same week as current week
    public func isDateInWeek(from date: Date) -> Bool {
        let currentWeek = component(Calendar.Component.weekOfYear, from: Date())
        let otherWeek = component(Calendar.Component.weekOfYear, from: date)
        return (currentWeek == otherWeek)
    }
}
