import Foundation
import hCore

public struct Intent: Sendable {
    public let activationDate: String
    public let currentTotalCost: Premium
    public let newTotalCost: Premium
    public let id: String
    public let newCostBreakdown: [MidtermChangePriceDetailItem]

    public init(
        activationDate: String,
        currentTotalCost: Premium,
        newTotalCost: Premium,
        id: String,
        newCostBreakdown: [MidtermChangePriceDetailItem]
    ) {
        self.activationDate = activationDate
        self.currentTotalCost = currentTotalCost
        self.newTotalCost = newTotalCost
        self.id = id
        self.newCostBreakdown = newCostBreakdown
    }
}

public struct MidtermChangePriceDetailItem: Sendable {
    public let displayTitle: String
    public let displayValue: String

    public init(
        displayTitle: String,
        displayValue: String
    ) {
        self.displayTitle = displayTitle
        self.displayValue = displayValue
    }
}
