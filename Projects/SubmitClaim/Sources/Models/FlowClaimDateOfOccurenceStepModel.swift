import Foundation

public struct FlowClaimDateOfOccurenceStepModel: FlowClaimStepModel {
    let id: String
    public internal(set) var dateOfOccurence: String?
    public let maxDate: String?

    public init(
        id: String,
        dateOfOccurence: String? = nil,
        maxDate: String?
    ) {
        self.id = id
        self.dateOfOccurence = dateOfOccurence
        self.maxDate = maxDate
    }

    @MainActor
    func getMaxDate() -> Date {
        maxDate?.localDateToDate ?? Date()
    }
}
