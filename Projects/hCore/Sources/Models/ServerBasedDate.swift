import Foundation

public typealias ServerBasedDate = String

@MainActor
public extension ServerBasedDate {
    var displayDate: String {
        localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
    }

    var displayDateShort: String {
        localDateToDate?.displayDateDDMMMFormat ?? ""
    }

    var year: Int? {
        Int(localDateToDate?.dateYYYYFormat ?? "")
    }
}
