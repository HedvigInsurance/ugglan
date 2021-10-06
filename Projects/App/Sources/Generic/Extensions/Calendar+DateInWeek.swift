import Foundation

extension Calendar {
    /// returns a boolean indicating if provided date is in the same week as current week
    func isDateInWeek(from date: Date) -> Bool {
        let currentWeek = component(Calendar.Component.weekOfYear, from: Date())
        let otherWeek = component(Calendar.Component.weekOfYear, from: date)
        return (currentWeek == otherWeek)
    }
}
