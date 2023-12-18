import Apollo
import Foundation
import Home
import TestingUtil
import hCore
import hGraphQL

func addDaysToDate(_ days: Int = 30) -> Date {
    let today = Date()

    var dateComponent = DateComponents()
    dateComponent.day = days
    dateComponent.hour = 0

    let futureDate = Calendar.current.date(byAdding: dateComponent, to: today)

    return futureDate ?? Date()
}
