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
    public var localDateToIso8601Date: Date? {
        let formatter = ISO8601DateFormatter()

        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = .current
        return formatter.date(from: self)
    }
}
