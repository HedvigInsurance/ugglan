import Foundation
import hCore

public struct Intent: Sendable {
    let activationDate: String
    let currentTotalCost: ItemCost
    let newTotalCost: ItemCost
    let id: String
    let quote: MidtermChangeQuote

    public init(
        activationDate: String,
        currentTotalCost: ItemCost,
        newTotalCost: ItemCost,
        id: String,
        quote: MidtermChangeQuote
    ) {
        self.activationDate = activationDate
        self.currentTotalCost = currentTotalCost
        self.newTotalCost = newTotalCost
        self.id = id
        self.quote = quote
    }
}

public struct MidtermChangeQuote: Sendable {
    let id: String
    let currentCost: ItemCost
    let newCost: ItemCost
    let exposureName: String
    let displayItems: [MidtermQuoteDisplayItem]
    let productVariant: ProductVariant
    let addons: [MidtermChangeAddonQuote]

    public init(
        id: String,
        currentCost: ItemCost,
        newCost: ItemCost,
        exposureName: String,
        displayItems: [MidtermQuoteDisplayItem],
        productVariant: ProductVariant,
        addons: [MidtermChangeAddonQuote]
    ) {
        self.id = id
        self.currentCost = currentCost
        self.newCost = newCost
        self.exposureName = exposureName
        self.displayItems = displayItems
        self.productVariant = productVariant
        self.addons = addons
    }
}

public struct MidtermQuoteDisplayItem: Sendable {
    let displayTitle: String
    let displaySubtitle: String?
    let displayValue: String

    public init(displayTitle: String, displaySubtitle: String?, displayValue: String) {
        self.displayTitle = displayTitle
        self.displaySubtitle = displaySubtitle
        self.displayValue = displayValue
    }
}

public struct MidtermChangeAddonQuote: Sendable {
    let addonId: String
    let currentCost: ItemCost
    let newCost: ItemCost
    let displayName: String
    let coverageDisplayName: String
    let displayItems: [MidtermQuoteDisplayItem]
    let addonVariant: AddonVariant
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
