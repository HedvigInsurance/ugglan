import Foundation

public typealias ServerBasedDate = String
extension ServerBasedDate {
    public var displayDate: String {
        self.localDateToDate?.displayDateMMMDDYYYYFormat ?? ""
    }

    public var displayDateShort: String {
        self.localDateToDate?.displayDateDDMMMFormat ?? ""
    }
}
