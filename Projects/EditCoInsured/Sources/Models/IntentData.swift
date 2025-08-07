import Foundation
import hCore

public struct Intent: Sendable {
    let activationDate: String
    let currentCost: ItemCost
    let newCost: ItemCost
    let id: String
    let state: String

    public init(
        activationDate: String,
        currentCost: ItemCost,
        newCost: ItemCost,
        id: String,
        state: String
    ) {
        self.activationDate = activationDate
        self.currentCost = currentCost
        self.newCost = newCost
        self.id = id
        self.state = state
    }
}

public struct ItemCost: Sendable {
    public let discounts: [ItemDiscount]
    public let monthlyGross: MonetaryAmount
    public let montlyNet: MonetaryAmount

    public init(discounts: [ItemDiscount], monthlyGross: MonetaryAmount, montlyNet: MonetaryAmount) {
        self.discounts = discounts
        self.monthlyGross = monthlyGross
        self.montlyNet = montlyNet
    }
}

public struct ItemDiscount: Sendable {
    let amount: MonetaryAmount
    let campaignCode: String
    let displayName: String
    let displayValue: String
    let explanation: String

    public init(
        amount: MonetaryAmount,
        campaignCode: String,
        displayName: String,
        displayValue: String,
        explanation: String
    ) {
        self.amount = amount
        self.campaignCode = campaignCode
        self.displayName = displayName
        self.displayValue = displayValue
        self.explanation = explanation
    }
}
