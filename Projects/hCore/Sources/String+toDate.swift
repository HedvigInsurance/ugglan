import Foundation

extension String {
    // converts a YYYY-MM-DD date-string to a Date
    public var localDateToDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
    
    public func localDateToIso8601Date(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}
