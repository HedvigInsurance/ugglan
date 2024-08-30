import Foundation

extension String {
    public var localDateToDate: Date? {
        return Dependencies.dateService.localDateStringFormatter.date(from: self)
    }

    public var localDateToIso8601Date: Date? {
        return Dependencies.dateService.localDateToIso8601Date.date(from: self)
    }

    public var localBirthDateStringToDate: Date? {
        if self == "" {
            return nil
        }
        return Dependencies.dateService.localbirthDateStringFormatter.date(from: self)
    }
}

extension Dependencies {
    fileprivate static var dateService: DateService {
        Dependencies.shared.resolve()
    }
}
