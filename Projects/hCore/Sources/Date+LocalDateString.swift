import Foundation

extension Date {
    public var localDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: self)
    }

    public var localDateStringDayFirst: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }

    public var formatFromDashToDot: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }

    /// A localDate string where a date of today is replaced with `today`
    public var localDateStringWithToday: String? {
        if Calendar.current.isDateInToday(self) { return L10n.startDateToday } else { return localDateString }
    }

}
