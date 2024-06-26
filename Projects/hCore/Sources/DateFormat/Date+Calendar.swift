import Foundation

extension Date {
    public var isFirstDayOfMonth: Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self)
        return components.day == 1
    }

    public var isLastDayOfMonth: Bool {
        let calendar = Calendar.current
        if let dayRange = calendar.range(of: .day, in: .month, for: self) {
            return calendar.component(.day, from: self) == dayRange.upperBound - 1
        }
        return false
    }

    public var isToday: Bool {
        if self.daysBetween(start: Date()) == 0 {
            return true
        }
        return false
    }

    public var isYesterday: Bool {
        if self == Date() - 1 {
            return true
        }
        return false
    }
}
