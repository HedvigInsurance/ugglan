import Foundation
import hCore

public struct Intent: Sendable {
    let activationDate: String
    let currentTotalCost: Premium
    let newTotalCost: Premium
    let id: String
    let newCostBreakdown: [MidtermChangePriceDetailItem]

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
    let displayTitle: String
    let displayValue: String

    public init(
        displayTitle: String,
        displayValue: String
    ) {
        self.displayTitle = displayTitle
        self.displayValue = displayValue
    }
}
