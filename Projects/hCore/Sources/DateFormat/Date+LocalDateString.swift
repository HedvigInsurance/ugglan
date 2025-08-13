import Foundation

@MainActor
extension Date {
    public var localDateString: String {
        Dependencies.dateService.localDateStringFormatter.string(from: self)
    }

    public var localDateToIso8601Date: String? {
        Dependencies.dateService.localDateToIso8601Date.string(from: self)
    }
    public var localBirthDateString: String {
        Dependencies.dateService.localbirthDateStringFormatter.string(from: self)
    }

    public var displayDateDDMMMFormat: String {
        Dependencies.dateService.displayddMMM.string(from: self)
    }

    public var displayDateMMMMDDYYYYFormat: String {
        Dependencies.dateService.displayMMMMddYYYY.string(from: self)
    }

    public var dateYYYYFormat: String? {
        Dependencies.dateService.YYYYFormat.string(from: self)
    }

    public func daysBetween(start: Date) -> Int {
        Calendar.current.dateComponents([.day], from: start, to: self).day!
    }

    public var displayDateDDMMMYYYYFormat: String {
        Dependencies.dateService.displayddMMMyyyy.string(from: self).lowercased()
    }

    public var displayDateWithTimeStamp: String {
        Dependencies.dateService.displayddMMMyyyyHHmm.string(from: self).lowercased()
    }

    public var displayTimeStamp: String {
        let dateFormatter = DateFormatter()
        if !Calendar.current.isDateInWeek(from: self) {
            dateFormatter.dateFormat = "dd MMMM YYYY"
            return displayDateDDMMMYYYYFormat
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

extension Calendar {
    /// returns a boolean indicating if provided date is in the same week as current week
    public func isDateInWeek(from date: Date) -> Bool {
        let currentWeek = component(Calendar.Component.weekOfYear, from: Date())
        let otherWeek = component(Calendar.Component.weekOfYear, from: date)
        return currentWeek == otherWeek
    }
}

@MainActor
public class DateService {
    public init() {}
    let localDateStringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Localization.Locale.currentLocale.value.code)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    let localbirthDateStringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Localization.Locale.currentLocale.value.code)
        formatter.dateFormat = "yyMMdd"
        return formatter
    }()

    let displayddMMM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Localization.Locale.currentLocale.value.code)
        formatter.dateFormat = "dd MMM"
        return formatter
    }()

    let displayMMMMddYYYY: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Localization.Locale.currentLocale.value.code)
        formatter.dateFormat = "MMMM dd YYYY"
        return formatter
    }()

    let YYYYFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Localization.Locale.currentLocale.value.code)
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    let displayddMMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Localization.Locale.currentLocale.value.code)
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    let displayddMMMyyyyHHmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Localization.Locale.currentLocale.value.code)
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter
    }()

    let localDateToIso8601Date: ISO8601DateFormatter = {
        var formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = .current
        return formatter
    }()
}

extension Dependencies {
    fileprivate static var dateService: DateService {
        Dependencies.shared.resolve()
    }
}
