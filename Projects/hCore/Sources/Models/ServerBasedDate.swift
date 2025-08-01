import Foundation

public typealias ServerBasedDate = String

@MainActor
extension ServerBasedDate {
    public var displayDate: String {
        localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
    }

    public var displayDateShort: String {
        localDateToDate?.displayDateDDMMMFormat ?? ""
    }

    public var year: Int? {
        Int(localDateToDate?.dateYYYYFormat ?? "")
    }
}
