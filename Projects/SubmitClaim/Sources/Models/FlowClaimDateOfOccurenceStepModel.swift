import Foundation

public struct FlowClaimDateOfOccurenceStepModel: FlowClaimStepModel {
    public internal(set) var dateOfOccurence: String?
    public let maxDate: String?

    public init(
        dateOfOccurence: String? = nil,
        maxDate: String?
    ) {
        self.dateOfOccurence = dateOfOccurence
        self.maxDate = maxDate
    }

    @MainActor
    func getMaxDate() -> Date {
        maxDate?.localDateToDate ?? Date()
    }
}
