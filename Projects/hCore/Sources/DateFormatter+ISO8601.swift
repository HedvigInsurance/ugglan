import Foundation

extension DateFormatter {
    public static func withIso8601Format(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = format
        return formatter
    }
}
