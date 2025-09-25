import Foundation
import hCore

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
            dateFormatter.dateFormat = "EEEE ∙ HH:mm"
            return dateFormatter.string(from: date)
        }
    }
}
