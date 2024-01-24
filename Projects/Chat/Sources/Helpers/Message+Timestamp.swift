import Foundation

extension Message {
    var timeStampString: String {
        let dateFormatter = DateFormatter()
        let date = sentAt
        if !Calendar.current.isDateInWeek(from: date) {
            dateFormatter.dateFormat = "MMM d, yyyy - HH:mm"
            return dateFormatter.string(from: date)
        } else if Calendar.current.isDateInToday(date) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "EEEE HH:mm"
            return dateFormatter.string(from: date)
        }
    }
}
extension Calendar {
    /// returns a boolean indicating if provided date is in the same week as current week
    func isDateInWeek(from date: Date) -> Bool {
        let currentWeek = component(Calendar.Component.weekOfYear, from: Date())
        let otherWeek = component(Calendar.Component.weekOfYear, from: date)
        return (currentWeek == otherWeek)
    }
}
