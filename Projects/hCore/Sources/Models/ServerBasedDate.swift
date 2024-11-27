import Foundation

public typealias ServerBasedDate = String

@MainActor
extension ServerBasedDate {
    public var displayDate: String {
        self.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
    }

    public var displayDateShort: String {
        self.localDateToDate?.displayDateDDMMMFormat ?? ""
    }

    public var year: Int? {
        Int(self.localDateToDate?.dateYYYYFormat ?? "")
    }
}
