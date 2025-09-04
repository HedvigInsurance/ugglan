import Foundation
import hCore

public struct Intent: Sendable {
    let activationDate: String
    let currentTotalCost: TotalCost
    let newTotalCost: TotalCost
    let id: String
    let newCostBreakdown: [MidtermChangePriceDetailItem]

    public init(
        activationDate: String,
        currentTotalCost: TotalCost,
        newTotalCost: TotalCost,
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

public struct TotalCost: Sendable {
    public let monthlyGross: MonetaryAmount
    public let montlyNet: MonetaryAmount

    public init(
        monthlyGross: MonetaryAmount,
        montlyNet: MonetaryAmount
    ) {
        self.monthlyGross = monthlyGross
        self.montlyNet = montlyNet
    }
}
