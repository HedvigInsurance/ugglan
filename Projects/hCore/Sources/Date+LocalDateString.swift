import Foundation

extension Date {
    public var localDateString: String {
        return DateFormatters.localDateStringFormatter.string(from: self)
    }

    public var localDateStringDayFirst: String? {
        return DateFormatters.localDateStringDayFirstFormatter.string(from: self)
    }

    public var localDateStringWithTime: String? {
        return DateFormatters.localDateStringWithTimeFormatter.string(from: self)
    }

    public var displayDateDotFormat: String? {
        return DateFormatters.displayDateDotFormatFormatter.string(from: self)
    }

    public var displayDateMMMDDYYYYFormat: String? {
        return DateFormatters.displayddMMMMYYYY.string(from: self)
    }

    /// A localDate string where a date of today is replaced with `today`
    public var localDateStringWithToday: String? {
        if Calendar.current.isDateInToday(self) { return L10n.startDateToday } else { return localDateString }
    }
}
private struct DateFormatters {
    static let localDateStringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let localDateStringDayFirstFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    static let localDateStringWithTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return formatter
    }()

    static let displayDateDotFormatFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    static let displayddMMMMYYYY: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        return formatter
    }()
}
