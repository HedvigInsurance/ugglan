import Foundation

extension String {
    // converts a YYYY-MM-DD date-string to a Date
    private static let localDateToDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    public var localDateToDate: Date? {
        return String.localDateToDateFormatter.date(from: self)
    }
    public func localDateToIso8601Date(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}
