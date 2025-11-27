import Combine
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

@MainActor
extension Int {
    public func ordinalDate() -> String {
        Dependencies.dateService.asOrdinal(for: self)
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
    private let locale: Localization.Locale
    public init(locale: Localization.Locale = Localization.Locale.currentLocale.value) {
        self.locale = locale
    }

    lazy private(set) var localDateStringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale.code)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    lazy private(set) var localbirthDateStringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale.code)
        formatter.dateFormat = "yyMMdd"
        return formatter
    }()

    lazy private(set) fileprivate var displayddMMM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale.code)
        formatter.dateFormat = "dd MMM"
        return formatter
    }()

    lazy private(set) fileprivate var displayMMMMddYYYY: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale.code)
        formatter.dateFormat = "MMMM dd YYYY"
        return formatter
    }()

    lazy private(set) fileprivate var YYYYFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale.code)
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    lazy private(set) fileprivate var displayddMMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale.code)
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    lazy private(set) fileprivate var displayddMMMyyyyHHmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale.code)
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter
    }()

    lazy private(set) var localDateToIso8601Date: ISO8601DateFormatter = {
        var formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = .current
        return formatter
    }()

    fileprivate func asOrdinal(for day: Int) -> String {
        let lastDigit = day % 10
        let sufix: String = {
            switch locale {
            case .en_SE:
                switch lastDigit {
                case 1: return "st"
                case 2: return "nd"
                case 3: return "rd"
                default: return "th"
                }
            case .sv_SE:
                switch day {
                case 11, 12: return ":e"
                default:
                    switch lastDigit {
                    case 1, 2: return ":a"
                    default: return ":e"
                    }
                }
            }
        }()
        return "\(day)\(sufix)"
    }
}

extension Dependencies {
    fileprivate static var dateService: DateService {
        Dependencies.shared.resolve()
    }
}
